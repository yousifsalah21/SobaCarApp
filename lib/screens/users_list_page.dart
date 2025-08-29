import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/app_user.dart';
import 'add_edit_user_page.dart';

class UsersListPageContent extends StatefulWidget {
  const UsersListPageContent({super.key});

  @override
  State<UsersListPageContent> createState() => _UsersListPageContentState();
}

class _UsersListPageContentState extends State<UsersListPageContent> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  List<AppUser> _allUsers = [];
  List<AppUser> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _openAddUserPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditUserPage()),
    );
    if (result == true) {
      setState(() {}); 
    }
  }

  Future<void> _openEditUserPage(AppUser user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditUserPage(user: user)),
    );
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<Result<List<AppUser>>>(
                  stream: _userService.getUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: Text("No users found"));
                    }

                    final result = snapshot.data!;

                    if (result.hasError) {
                      return Center(
                        child: Text("❌ Error: ${result.error}"),
                      );
                    }

                    final users = result.data ?? [];

                    if (users.isEmpty) {
                      return const Center(child: Text("No users found"));
                    }

                    _allUsers = users;
                    if (_filteredUsers.isEmpty &&
                        _searchController.text.isEmpty) {
                      _filteredUsers = _allUsers;
                    }

                    if (_filteredUsers.isEmpty) {
                      return const Center(
                          child: Text("No matching users found."));
                    }

                    return ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];

                        return Card(
                          child: ListTile(
                            title: Text(user.name),
                            subtitle: Text("${user.role}\n${user.phone}"),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit button
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _openEditUserPage(user),
                                ),
                                // Delete button
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content:
                                            Text("Delete user ${user.name}?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _userService.deleteUser(user.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    onPressed: _openAddUserPage,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Result<T> {
  final T? data;
  final String? error;

  Result({this.data, this.error});

  bool get hasError => error != null;
}
