import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepo;
  StreamSubscription<AuthState>? _authSub;
  AppUser? _currentUser;

  AuthProvider({required AuthRepository authRepo}) : _authRepo = authRepo {
    _currentUser = _authRepo.currentUser;
    _authSub = _authRepo.authStateChanges.listen((_) {
      _currentUser = _authRepo.currentUser;
      notifyListeners();
    });
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _authRepo.signUp(email: email, password: password, username: username);
    _currentUser = _authRepo.currentUser;
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _authRepo.signIn(email: email, password: password);
    _currentUser = _authRepo.currentUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await _authRepo.signInWithGoogle();
  }

  @override
  void dispose() {
    _authRepo.dispose();
    _authSub?.cancel();
    super.dispose();
  }
}
