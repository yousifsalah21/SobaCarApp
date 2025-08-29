import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AppUser?> login(String email, String password) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password);

    if (response.isNotEmpty) {
      return AppUser.fromSupabase(response.first);
    }
    return null;
  }
}
