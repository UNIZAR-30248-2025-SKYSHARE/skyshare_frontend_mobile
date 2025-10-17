import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();
  
  bool _initialized = false;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> init({String? url, String? anonKey}) async {
    if (_initialized) return;
    final u = url ?? dotenv.env['SUPABASE_URL'];
    final k = anonKey ?? dotenv.env['SUPABASE_ANON_KEY'];
    if (u == null || k == null) throw StateError('Supabase credentials missing');
    await Supabase.initialize(url: u, anonKey: k);
    _initialized = true;
  }
}

extension SupabaseClientX on SupabaseClient {
  String? get currentUserId => auth.currentUser?.id;
}

