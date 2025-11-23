import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class KeyManager {
  final FlutterSecureStorage _secureStorage;
  final SupabaseClient _supabase;
  final Uuid _uuid = const Uuid();

  static const _deviceIdKey = 'e2ee_device_id';
  static const _identityPairKey = 'e2ee_identity_pair';
  static const _registrationIdKey = 'e2ee_registration_id';
  static const _signedPreKeyKey = 'e2ee_signed_prekey';
  static const _oneTimePrekeysKey = 'e2ee_one_time_prekeys';

  KeyManager({required SupabaseClient supabase})
      : _secureStorage = const FlutterSecureStorage(),
        _supabase = supabase;

  Future<String> getDeviceId() async {
    var id = await _secureStorage.read(key: _deviceIdKey);
    if (id == null) {
      id = _uuid.v4();
      await _secureStorage.write(key: _deviceIdKey, value: id);
    }
    return id;
  }

  Future<bool> hasLocalBundle() async {
    final v = await _secureStorage.read(key: _identityPairKey);
    return v != null;
  }

  Future<void> initDeviceBundleIfNeeded() async {
    if (!await hasLocalBundle()) {
      await initDeviceBundle();
    } else {
      await getDeviceId();
    }
  }

  Future<void> initDeviceBundle() async {
    final identityKeyPair = generateIdentityKeyPair();
    final registrationId = generateRegistrationId(false);
    final preKeys = generatePreKeys(0, 10);
    final signedPreKey = generateSignedPreKey(identityKeyPair, 0);

    final identitySerialized = identityKeyPair.serialize();
    await _secureStorage.write(key: _identityPairKey, value: base64Encode(identitySerialized));
    await _secureStorage.write(key: _registrationIdKey, value: registrationId.toString());

    final signedPreKeySerialized = signedPreKey.serialize();
    await _secureStorage.write(key: _signedPreKeyKey, value: base64Encode(signedPreKeySerialized));

    final List<Map<String, String>> otpList = [];
    for (final p in preKeys) {
      final item = {
        'id': p.id.toString(),
        'serialized': base64Encode(p.serialize()),
      };
      otpList.add(item);
    }
    await _secureStorage.write(key: _oneTimePrekeysKey, value: jsonEncode(otpList));

    final identityPub = identityKeyPair.getPublicKey();
    final identityPubBytes = identityPub.serialize();
    final signedPreKeyPub = signedPreKey.getKeyPair().publicKey.serialize();
    final signedPreKeySignature = signedPreKey.signature;

    final List<Map<String, dynamic>> prekeysPublic = preKeys
        .map((p) => {
              'id': p.id,
              'pub': base64Encode(p.getKeyPair().publicKey.serialize()),
            })
        .toList();

    final deviceId = await getDeviceId();
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('User not signed in when uploading device bundle');

    await _supabase.from('user_devices').upsert({
      'id_device': deviceId,
      'id_usuario': currentUser.id,
      'registration_id': registrationId,
      'identity_key': base64Encode(identityPubBytes),
      'signed_prekey': base64Encode(signedPreKeyPub),
      'signed_prekey_signature': base64Encode(signedPreKeySignature),
      'one_time_prekeys': prekeysPublic,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> exportPublicBundle() async {
    final deviceId = await getDeviceId();
    final identityPairB64 = await _secureStorage.read(key: _identityPairKey);
    final signedPreKeyB64 = await _secureStorage.read(key: _signedPreKeyKey);
    final oneTimeJson = await _secureStorage.read(key: _oneTimePrekeysKey);
    final registrationId = await _secureStorage.read(key: _registrationIdKey);

    IdentityKey? identityPub;
    if (identityPairB64 != null) {
      final bytes = base64Decode(identityPairB64);
      final identity = IdentityKeyPair.fromSerialized(Uint8List.fromList(bytes));
      identityPub = identity.getPublicKey();
    }

    final List<Map<String, dynamic>> prekeysPublic = [];
    if (oneTimeJson != null) {
      final parsed = jsonDecode(oneTimeJson) as List<dynamic>;
      for (final e in parsed) {
        final id = e['id'] as String?;
        final serB64 = e['serialized'] as String?;
        if (id != null && serB64 != null) {
          final bytes = base64Decode(serB64);
          final record = PreKeyRecord.fromBuffer(Uint8List.fromList(bytes));
          prekeysPublic.add({
            'id': record.id, 
            'pub': base64Encode(record.getKeyPair().publicKey.serialize())
          });
        }
      }
    }

    String? signedPreKeyPublicB64;
    if (signedPreKeyB64 != null) {
      final bytes = base64Decode(signedPreKeyB64);
      final signedRecord = SignedPreKeyRecord.fromSerialized(Uint8List.fromList(bytes));
      signedPreKeyPublicB64 = base64Encode(signedRecord.getKeyPair().publicKey.serialize());
    }

    return {
      'id_device': deviceId,
      'registration_id': registrationId,
      'identity_key': identityPub != null ? base64Encode(identityPub.serialize()) : null,
      'signed_prekey': signedPreKeyPublicB64,
      'one_time_prekeys': prekeysPublic,
    };
  }

  Future<Uint8List?> getIdentityPairSerialized() async {
    final b64 = await _secureStorage.read(key: _identityPairKey);
    if (b64 == null) return null;
    return Uint8List.fromList(base64Decode(b64));
  }

  Future<int?> getRegistrationId() async {
    final v = await _secureStorage.read(key: _registrationIdKey);
    if (v == null) return null;
    return int.tryParse(v);
  }

  Future<List<PreKeyRecord>> loadLocalOneTimePreKeys() async {
    final oneTimeJson = await _secureStorage.read(key: _oneTimePrekeysKey);
    if (oneTimeJson == null) return [];
    final parsed = jsonDecode(oneTimeJson) as List<dynamic>;
    final out = <PreKeyRecord>[];
    for (final e in parsed) {
      final serB64 = e['serialized'] as String?;
      if (serB64 == null) continue;
      final bytes = base64Decode(serB64);
      final record = PreKeyRecord.fromBuffer(Uint8List.fromList(bytes));
      out.add(record);
    }
    return out;
  }

  Future<SignedPreKeyRecord?> loadLocalSignedPreKeyRecord() async {
    final b64 = await _secureStorage.read(key: _signedPreKeyKey);
    if (b64 == null) return null;
    final bytes = base64Decode(b64);
    return SignedPreKeyRecord.fromSerialized(Uint8List.fromList(bytes));
  }
}