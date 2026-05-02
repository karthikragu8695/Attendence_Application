import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'attendance.dart';
import 'employee_screen.dart';
import 'reportScreen.dart';
import 'profileScreen.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eehulaacihowptvbomns.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVlaHVsYWFjaWhvd3B0dmJvbW5zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczNDYwNjYsImV4cCI6MjA5MjkyMjA2Nn0.xIY1Ivm2MZoq1VWgdzPP5KxD_guIaKMN0XbgwB_sAQY',
  );

  runApp(const MyApp());
}

/// ================= APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

/// ================= MODEL =================
class Employee {
  final String id;
  final String name;
  final String shift;
  final String? role;
  final String? employee_id;
  String status;
  String? image;

  Employee({
    required this.id,
    required this.name,
    required this.shift,
    required this.role,
    required this.employee_id,
    this.status = "P",
    this.image,
  });
}

/// ================= MAIN SCREEN =================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  List<Employee> employees = [];
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  /// 🔥 LOAD BOTH PROFILE + EMPLOYEES
  Future<void> initData() async {
    await Future.wait([
      fetchEmployees(),
      fetchProfile(),
    ]);

    setState(() => loading = false);
  }

  /// ================= PROFILE =================
  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    profile = data;
  }

  /// ================= EMPLOYEES =================
  Future<void> fetchEmployees() async {
   final data = await supabase.from('employees').select('''
  id,
  name,
  shift,
  role,
  image,
  id_no,
  attendance(employee_id, date, status)
''');

    employees = (data as List).map((e) {
      final attendance = e['attendance'] as List?;

      String status = "P";
      if (attendance != null && attendance.isNotEmpty) {
        status = attendance.last['status'];
      }

      return Employee(
        id: e['id'],
        name: e['name'],
        shift: e['shift'],
        role: e['role'],
        image: e['image'],
        status: status,
        employee_id: e['id_no']
      );
    }).toList();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      AttendanceScreen(employees: employees),
      EmployeesScreen(
        employees: employees,
        refresh: () async {
          await fetchEmployees();
          setState(() {});
        },
      ),
      ReportsScreen(employees: employees),
      ProfileScreen(profile: profile ?? {}),
    ];

    return Scaffold(
      body: screens[currentIndex],

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Employees",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}