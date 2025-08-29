import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/app_user.dart';

class AddEditUserPage extends StatefulWidget {
  final AppUser? user;

  const AddEditUserPage({super.key, this.user});

  @override
  State<AddEditUserPage> createState() => _AddEditUserPageState();
}

class _AddEditUserPageState extends State<AddEditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  String _role = "user"; // القيمة الافتراضية

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user != null ? widget.user!.name : "",
    );
    _emailController = TextEditingController(
      text: widget.user != null ? widget.user!.email : "",
    );
    _passwordController = TextEditingController(
      text: widget.user != null ? widget.user!.password : "",
    );
    _phoneController = TextEditingController(
      text: widget.user != null ? widget.user!.phone : "",
    );
    _role = widget.user != null ? widget.user!.role : "user";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final user = AppUser(
        id: widget.user?.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _role,
      );

      if (widget.user == null) {
        await _userService.createUser(user, context);
      } else {
        await _userService.updateUser(user.id!, user.toMap());
      }

      if (mounted) {
        Navigator.pop(context, true); // رجع true للتحديث التلقائي
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? "Add AppUser" : "Edit AppUser"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // لتفادي overflow
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter name" : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter email" : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter password" : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: "user", child: Text("User")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _role = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: "Role"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveUser,
                  child: Text(widget.user == null ? "Add" : "Update"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
