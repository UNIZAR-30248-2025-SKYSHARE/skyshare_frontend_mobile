import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSub;
  bool _expectingOAuthSignIn = false;

  AuthRepository({required SupabaseClient client}) : _client = client {
    _startAuthListener();
  }

  void dispose() {
    _authSub?.cancel();
    _authSub = null;
  }

  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    if (response.user != null) {
      final signInResp = await _client.auth.signInWithPassword(email: email, password: password);
      final signedUser = signInResp.user ?? response.user!;
      await _ensureUserInDb(signedUser, usernameOverride: username);
    } else {
      throw Exception('Failed to create user');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Login failed');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    _expectingOAuthSignIn = true;
    final redirectUri = kIsWeb ? null : 'com.example.skyshare://login-callback';
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUri,
    );
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  void _startAuthListener() {
    _authSub = _client.auth.onAuthStateChange.listen((event) async {
      final e = event.event;
      final session = event.session;
      if (e == AuthChangeEvent.signedIn && _expectingOAuthSignIn) {
        final user = session?.user;
        if (user != null) {
          await _ensureUserInDb(user);
        }
        _expectingOAuthSignIn = false;
      }
    });
  }

  Future<void> _ensureUserInDb(User user, {String? usernameOverride}) async {
    try {
      String username = usernameOverride ??
          (user.userMetadata?['username'] as String?) ??
          (user.userMetadata?['name'] as String?) ??
          (user.email?.split('@').first ?? '');

      username = username.split('.').first.trim(); 

      final parts = username.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.length > 1 && parts.every((p) => p == parts.first)) {
        username = parts.first;
      }

      String? photo = (user.userMetadata?['avatar_url'] as String?) ??
          (user.userMetadata?['picture'] as String?);
      await _client.from('usuario').upsert({
        'id_usuario': user.id,
        'email': user.email,
        'nombre_usuario': username == '' ? null : username,
        'url_foto': photo,
      });
    } catch (e, st) {
      debugPrint('Error asegurando usuario en BD: $e\n$st');
    }
  }
}