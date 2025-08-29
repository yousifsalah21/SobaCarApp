import 'package:flutter/material.dart';
import 'screens/users_list_page.dart';
import 'screens/car_list_page.dart';
import 'screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://adeopmyczrajircvzdjn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkZW9wbXljenJhamlyY3Z6ZGpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyOTUzNTMsImV4cCI6MjA3MTg3MTM1M30.YpmhF5osyS54XX9TQL059VMvP8OQsOsBdFQnO-bHHVU',
  );
  runApp(const SobaApp());
}

class SobaApp extends StatelessWidget {
  const SobaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // قائمة الشاشات التي سيتم عرضها بناءً على الزر المحدد
  final List<Widget> _pages = [
    const CarsListPageContent(), // استخدام الكلاس المستورد
    const UsersListPageContent(),
    const LoginPage(), // استخدام الكلاس المستورد
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Soba Car app',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'cars',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'my profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
