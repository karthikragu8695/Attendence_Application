import 'package:attendance_plot/MaintenanceScreen.dart';
import 'package:attendance_plot/kaizen/MykaizenScreen.dart';
import 'package:attendance_plot/kaizen/reportScreen.dart';
import 'package:attendance_plot/kaizen/submitKaizen.dart';
import 'package:attendance_plot/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatelessWidget {
  final List<Employee> employes;

  const DashboardScreen({super.key, required this.employes});

  /// 🔥 REALTIME STREAM
  Stream<List<Map<String, dynamic>>> kaizenStream() {
    final supabase = Supabase.instance.client;

    return supabase
        .from('kaizens')
        .stream(primaryKey: ['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      /// 🔥 DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Attendance"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MainScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.build),
              title: const Text("Maintenance"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MaintenanceScreen(employees: employes),
                  ),
                  (route) => false,
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text("Kaizen"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      /// 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Welcome, Karthi 👋",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            SizedBox(height: 2),
            Text("Keep improving everyday!",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child:
                Icon(Icons.notifications_none, color: Colors.black),
          )
        ],
      ),

      /// 📦 BODY
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: kaizenStream(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          /// 🔢 CALCULATIONS
          int total = data.length;
          int approved =
              data.where((e) => e['status'] == 'approved').length;
          int pending =
              data.where((e) => e['status'] == 'pending').length;
          int rejected =
              data.where((e) => e['status'] == 'rejected').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔵 SUMMARY CARD (REALTIME)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F80ED), Color(0xFF1C60D5)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          statItem("Total Kaizen",
                              total.toString(), Icons.bar_chart),
                          statItem("Approved",
                              approved.toString(), Icons.check),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          statItem("Pending",
                              pending.toString(), Icons.access_time),
                          statItem("Rejected",
                              rejected.toString(), Icons.cancel),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                /// ⚡ QUICK ACTIONS
                const Text("Quick Actions",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: actionCard(
                        Icons.add,
                        "Submit Kaizen",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SubmitKaizenScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: actionCard(
                        Icons.list_alt,
                        "My Kaizen",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MyKaizenScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// 📊 OVERVIEW (STATIC UI)
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("This Month Overview",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text("View all",
                        style: TextStyle(
                            color: Colors.blue, fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 150,
                        decoration: cardDecoration(),
                        child: Center(
                          child: Text(
                            "$approved%",
                            style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          overviewCard("Ideas Implemented",
                              approved.toString()),
                          const SizedBox(height: 12),
                          overviewCard("Total Kaizen",
                              total.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: BottomAppBar(
  shape: const CircularNotchedRectangle(),
  notchMargin: 8,
  child: SizedBox(
    height: 65,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        /// HOME
        navItem(
          Icons.home,
          "Home",
          true,
          onTap: () {
            // Already in dashboard
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DashboardScreen(employes: [],),
              ),
            );
          },
        ),

        /// MY KAIZEN
        

        const SizedBox(width: 40),

        /// REPORTS
        // navItem(
        //   Icons.bar_chart,
        //   "Reports",
        //   false,
        //   onTap: () {
        //     // TODO: Add Reports screen
        //      Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (_) => const ReportScreen(),
        //       ),
        //     );
        //   },
        // ),
        navItem(
          Icons.list_alt,
          "My Kaizen",
          false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyKaizenScreen(),
              ),
            );
          },
        ),

        /// PROFILE
        // navItem(
        //   Icons.person,
        //   "Profile",
        //   false,
        //   onTap: () {
        //     // TODO: Add Profile screen
        //   },
        // ),
      ],
    ),
  ),
),

      /// ➕ FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {

           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubmitKaizenScreen(),
              ),
            );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }

  /// 🔹 UI METHODS

  static Widget statItem(
      String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  static Widget actionCard(
    IconData icon,
    String title, {
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 100,
        decoration: cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  static Widget overviewCard(String title, String value) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(12),
      decoration: cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8)
      ],
    );
  }
}

/// 🔹 NAV ITEM
class navItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const navItem(
    this.icon,
    this.label,
    this.active, {
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}