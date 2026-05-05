import 'package:attendance_plot/MyIssuesScreen.dart';
import 'package:attendance_plot/kaizen/home.dart';
import 'package:attendance_plot/main.dart';
import 'package:attendance_plot/maindence_dashboard.dart';
import 'package:attendance_plot/maintenceReport.dart';
import 'package:flutter/material.dart';

class MaintenanceScreen extends StatefulWidget {
  final List<Employee>? employees;

  const MaintenanceScreen({super.key, this.employees});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  int currentIndex = 0;

  late final List<Employee> employees;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    employees = widget.employees ?? [];

    pages = [
    //  DashboardPage(employees: employees),
     const MaintenanceDashboard(),
     MachineSelectScreen(),
     const  MyIssuesScreen(),
     
    
     // const MyIssuesScreen(),
    //  const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      // 🔥 APPBAR (IMPORTANT for drawer icon)
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B2EFF),
        title: const Text("Maintenance"),
      ),

      // 🔥 DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF5B2EFF)),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Attendance"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MainScreen()
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.build),
              title: const Text("Maintenance"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
              ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text("Kaizen"),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DashboardScreen(employes: employees), // ✅ correct
                  ),
                  (route) => false,
                );
              },
            ),


            // ListTile(
            //   leading: const Icon(Icons.report),
            //   title: const Text("Report"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     setState(() => currentIndex = 1);
            //   },
            // ),

            // ListTile(
            //   leading: const Icon(Icons.list),
            //   title: const Text("My Issues"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     setState(() => currentIndex = 2);
            //   },
            // ),

            // ListTile(
            //   leading: const Icon(Icons.person),
            //   title: const Text("Profile"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     setState(() => currentIndex = 3);
            //   },
            // ),
          ],
        ),
      ),

      // 🔥 BODY
      body: pages[currentIndex],

      // 🔥 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF5B2EFF),
        unselectedItemColor: Colors.grey,
        

        onTap: (index) {
          setState(() => currentIndex = index);
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: "Report",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "My Issues",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: "Profile",
          // ),
        ],
      ),
    );
  }
}