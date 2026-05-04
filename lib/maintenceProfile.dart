import 'package:flutter/material.dart';

class Maintenceprofile extends StatelessWidget {
  const Maintenceprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// PROFILE CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                children: [

                  /// AVATAR
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF5B2EFF),
                    child: Icon(Icons.person, size: 45, color: Colors.white),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Worker Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "worker@company.com",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 15),

                  /// STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Active Worker",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFO CARDS
            _infoCard(Icons.phone, "Phone", "+91 9876543210"),
            _infoCard(Icons.badge, "Employee ID", "EMP1023"),
            _infoCard(Icons.work, "Department", "Maintenance Team"),
            _infoCard(Icons.location_on, "Location", "Factory Unit - A"),

            const SizedBox(height: 20),

            /// SETTINGS SECTION
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [

                  _menuItem(Icons.lock, "Change Password"),
                  _divider(),
                  _menuItem(Icons.notifications, "Notifications"),
                  _divider(),
                  _menuItem(Icons.help, "Help & Support"),
                  _divider(),
                  _menuItem(Icons.logout, "Logout", color: Colors.red),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INFO CARD
  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5B2EFF)),
          const SizedBox(width: 12),

          Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),

          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// MENU ITEM
  Widget _menuItem(IconData icon, String title, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(title, style: TextStyle(color: color ?? Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }

  Widget _divider() {
    return const Divider(height: 1);
  }
}