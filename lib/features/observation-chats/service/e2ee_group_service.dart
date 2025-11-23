import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart' as signal;
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/gcm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'key_manager.dart';
import 'package:pointycastle/api.dart' as pc;

class E2EGroupService {
  final SupabaseClient _supabase;
  final KeyManager _keyManager;
  final FlutterSecureStorage _storage;

  E2EGroupService({required SupabaseClient supabase, required KeyManager keyManager})
      : _supabase = supabase,
        _keyManager = keyManager,
        _storage = const FlutterSecureStorage();

  String _senderKeyStorageKey(int groupId, String senderDeviceId) => 'senderkey_${groupId}_$senderDeviceId';
  String _senderKeyIdIndexKey(int groupId) => 'senderkey_id_${groupId}';

  Future<String> ensureSenderKeyForGroup(int groupId) async {
    final myDeviceId = await _keyManager.getDeviceId();
    final existingId = await _storage.read(key: _senderKeyIdIndexKey(groupId));
    print("ensureSenderKeyForGroup: existingId for group $groupId = $existingId");
    if (existingId != null) return existingId;

    final secret = signal.generateRandomBytes(32);
    final keyId = const Uuid().v4();

    final payloadLocal = {'id': keyId, 'secret': base64Encode(secret), 'created_at': DateTime.now().toIso8601String()};
    await _storage.write(key: _senderKeyStorageKey(groupId, myDeviceId), value: jsonEncode(payloadLocal));
    await _storage.write(key: _senderKeyIdIndexKey(groupId), value: keyId);

    final response = await _supabase.rpc('get_group_member_devices', params: {'p_group_id': groupId});
    List devices = [];
    if (response is List) devices = response;

    print("ensureSenderKeyForGroup: group $groupId devices length=${devices.length}");

    for (final device in devices) {
      final recipientDeviceId = device['id_device'] as String?;
      if (recipientDeviceId == null) continue;
      if (recipientDeviceId == myDeviceId) continue;

      final bundleResp = await _supabase.from('user_devices').select().eq('id_device', recipientDeviceId).maybeSingle();
      if (bundleResp == null) continue;

      try {
        final registrationId = bundleResp['registration_id'] as int? ?? 1;
        final identityKeyPub = base64Decode(bundleResp['identity_key'] as String);
        final signedPreKeyPub = base64Decode(bundleResp['signed_prekey'] as String);
        final signedPreKeySig = bundleResp['signed_prekey_signature'] != null
            ? base64Decode(bundleResp['signed_prekey_signature'] as String)
            : Uint8List(0);

        final oneTimePrekeys = (bundleResp['one_time_prekeys'] as List?) ?? [];
        final prekeyEntry = oneTimePrekeys.isNotEmpty ? oneTimePrekeys.first : null;
        final preKeyId = prekeyEntry != null ? (prekeyEntry['id'] as int) : 0;
        final preKeyPub = prekeyEntry != null ? base64Decode(prekeyEntry['pub'] as String) : Uint8List(0);

        final preKeyBundle = signal.PreKeyBundle(
          registrationId,
          1,
          preKeyId,
          signal.Curve.decodePoint(preKeyPub, 0),
          (bundleResp['signed_prekey_id'] as int?) ?? 0,
          signal.Curve.decodePoint(signedPreKeyPub, 0),
          signedPreKeySig,
          signal.IdentityKey(signal.Curve.decodePoint(identityKeyPub, 0)),
        );

        final sessionStore = signal.InMemorySessionStore();
        final preKeyStore = signal.InMemoryPreKeyStore();
        final signedPreKeyStore = signal.InMemorySignedPreKeyStore();
        final identityPairSerialized = await _keyManager.getIdentityPairSerialized();
        final registrationIdLocal = await _keyManager.getRegistrationId() ?? 1;
        if (identityPairSerialized == null) throw Exception('No identity pair found locally');
        final localIdentity = signal.IdentityKeyPair.fromSerialized(identityPairSerialized);
        final identityStore = signal.InMemoryIdentityKeyStore(localIdentity, registrationIdLocal);

        final remoteAddress = signal.SignalProtocolAddress(recipientDeviceId, 1);
        final builder = signal.SessionBuilder(sessionStore, preKeyStore, signedPreKeyStore, identityStore, remoteAddress);
        await builder.processPreKeyBundle(preKeyBundle);

        final sessionCipher = signal.SessionCipher(sessionStore, preKeyStore, signedPreKeyStore, identityStore, remoteAddress);

        final encrypted = await sessionCipher.encrypt(Uint8List.fromList(utf8.encode(base64Encode(secret))));
        final encryptedBase64 = base64Encode(encrypted.serialize());

        final insertResp = await _supabase.from('group_key_distribution').insert({
          'id_grupo': groupId,
          'sender_device': myDeviceId,
          'sender_key_id': keyId,
          'recipient_device': recipientDeviceId,
          'encrypted_sender_key': encryptedBase64,
          'created_at': DateTime.now().toIso8601String(),
        }).select().maybeSingle(); 

        print("ensureSenderKeyForGroup: insertResp for recipient $recipientDeviceId => $insertResp");
      } catch (e, st) {
        debugPrint('Error distribuyendo sender key al device $recipientDeviceId: $e\n$st');
      }
    }

    return keyId;
  }

  Future<String> encryptGroupMessage(int groupId, String plaintext) async {
    final myDeviceId = await _keyManager.getDeviceId();
    final local = await _storage.read(key: _senderKeyStorageKey(groupId, myDeviceId));
    if (local == null) throw Exception('Sender key not present locally');

    final parsed = jsonDecode(local) as Map<String, dynamic>;
    final secret = base64Decode(parsed['secret'] as String);

    final nonce = signal.generateRandomBytes(12);
    final cipherAndTag = _aesGcmEncrypt(secret, Uint8List.fromList(utf8.encode(plaintext)), nonce);
    final packaged = nonce + cipherAndTag;
    return base64Encode(packaged);
  }

  Future<String?> decryptGroupMessageRow(Map<String, dynamic> msgRow) async {
    final ciphertextB64 = msgRow['ciphertext'] as String?;
    final senderDevice = msgRow['sender_device'] as String?;
    final senderKeyId = msgRow['sender_key_id'] as String?;
    final groupId = msgRow['id_grupo'] as int?;

    debugPrint('decryptGroupMessageRow: incoming msgRow keys: ${msgRow.keys}');
    debugPrint('ciphertextB64 length: ${ (msgRow['ciphertext'] as String?)?.length } sender_device: ${msgRow['sender_device']} sender_key_id: ${msgRow['sender_key_id']} id_grupo: ${msgRow['id_grupo']}');

    if (ciphertextB64 == null || senderDevice == null || senderKeyId == null || groupId == null) return null;

    final localVal = await _storage.read(key: _senderKeyStorageKey(groupId, senderDevice));
    debugPrint('local senderkey for ${_senderKeyStorageKey(groupId, senderDevice)} = ${localVal != null ? "FOUND" : "NOT FOUND"}');

    if (localVal != null) {
      final parsed = jsonDecode(localVal) as Map<String, dynamic>;
      debugPrint('local payload id=${parsed['id']} secret_len=${(parsed['secret'] as String).length}');

      if (parsed['id'] == senderKeyId) {
        final secret = base64Decode(parsed['secret'] as String);
        try {
          final plaintextBytes = _aesGcmDecryptFromPackaged(secret, base64Decode(ciphertextB64));
          return utf8.decode(plaintextBytes);
        } catch (e) {
          return null;
        }
      }
    }

    final myDeviceId = await _keyManager.getDeviceId();
    debugPrint('myDeviceId=$myDeviceId message.senderDevice=$senderDevice');

    final dist = await _supabase
        .from('group_key_distribution')
        .select()
        .eq('id_grupo', groupId)
        .eq('sender_key_id', senderKeyId)
        .eq('sender_device', senderDevice)
        .eq('recipient_device', myDeviceId)
        .maybeSingle();

    if (dist != null && dist['encrypted_sender_key'] != null) {
      final encryptedSenderKeyB64 = dist['encrypted_sender_key'] as String;
      try {
        final decryptedSenderKey = await _decryptSenderKeyForDistribution(encryptedSenderKeyB64, dist);
        final payloadLocal = {'id': senderKeyId, 'secret': base64Encode(decryptedSenderKey), 'created_at': DateTime.now().toIso8601String()};
        await _storage.write(key: _senderKeyStorageKey(groupId, senderDevice), value: jsonEncode(payloadLocal));

        final plaintextBytes = _aesGcmDecryptFromPackaged(decryptedSenderKey, base64Decode(ciphertextB64));
        return utf8.decode(plaintextBytes);
      } catch (e, st) {
        debugPrint('Error desbloqueando sender key distribuida: $e\n$st');
        return null;
      }
    }

    return null;
  }

  Future<Uint8List> _decryptSenderKeyForDistribution(String encryptedBase64, Map<String, dynamic> distRow) async {
    final identityPairSer = await _keyManager.getIdentityPairSerialized();
    final registrationId = await _keyManager.getRegistrationId() ?? 1;
    if (identityPairSer == null) throw Exception('No identity pair locally');

    final identityPair = signal.IdentityKeyPair.fromSerialized(identityPairSer);
    final store = signal.InMemorySignalProtocolStore(identityPair, registrationId);

    // Cargar claves locales para que el SessionCipher pueda establecer la sesión
    final localPreKeys = await _keyManager.loadLocalOneTimePreKeys();
    for (final p in localPreKeys) {
      await store.storePreKey(p.id, p);
    }
    final signed = await _keyManager.loadLocalSignedPreKeyRecord();
    if (signed != null) {
      await store.storeSignedPreKey(signed.id, signed);
    }

    final senderDeviceId = distRow['sender_device'] as String;
    final address = signal.SignalProtocolAddress(senderDeviceId, 1);

    final sessionCipher = signal.SessionCipher.fromStore(store, address);
    final encryptedBytes = base64Decode(encryptedBase64);
    
    try {
      final preKeyMsg = signal.PreKeySignalMessage(encryptedBytes);
      final decrypted = await sessionCipher.decrypt(preKeyMsg);
      return base64Decode(utf8.decode(decrypted));
    } catch (e) {
      try {
        final signalMsg = signal.SignalMessage.fromSerialized(encryptedBytes);
        final decrypted = await sessionCipher.decryptFromSignal(signalMsg);
        return base64Decode(utf8.decode(decrypted));
      } catch (e2) {
        debugPrint('Fallo al desencriptar SenderKey: $e2');
        throw Exception('Could not decrypt message as PreKey or SignalMessage');
      }
    }
  }

  Uint8List _aesGcmEncrypt(Uint8List key, Uint8List plaintext, Uint8List nonce) {
    final aead = GCMBlockCipher(AESEngine());
    final aeadParams = pc.AEADParameters(pc.KeyParameter(key), 128, nonce, Uint8List(0));
    aead.init(true, aeadParams);
    return aead.process(plaintext);
  }

  Uint8List _aesGcmDecryptFromPackaged(Uint8List key, Uint8List packaged) {
    final nonce = packaged.sublist(0, 12);
    final cipherAndTag = packaged.sublist(12);
    final aead = GCMBlockCipher(AESEngine());
    final aeadParams = pc.AEADParameters(pc.KeyParameter(key), 128, nonce, Uint8List(0));
    aead.init(false, aeadParams);
    return aead.process(cipherAndTag);
  }
}