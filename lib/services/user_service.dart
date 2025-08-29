import 'package:flutter/material.dart';
import '../models/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/users_list_page.dart';

final supabase = Supabase.instance.client;

class UserService {
  final String tableName = 'users';

  Future<void> createUser(AppUser user, BuildContext context) async {
    try {
      final data = user.toMap();
      await supabase.from(tableName).insert(data);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("user saved succesfuly✅")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UsersListPageContent()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("saving user failed❌ : $e")));
      }
    }
  }

  Stream<Result<List<AppUser>>> getUsers() {
    return supabase.from(tableName).stream(primaryKey: ['id']).map((records) {
      try {
        final users = records
            .map((record) => AppUser.fromSupabase(record))
            .toList();
        return Result(data: users);
      } catch (e) {
        return Result(error: e.toString());
      }
    });
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await supabase.from(tableName).update(data).eq('id', id);
  }

  Future<void> deleteUser(int id) async {
    await supabase.from(tableName).delete().eq('id', id);
  }
}
