import 'package:flutter/material.dart';
import 'package:attendance_plot/main.dart';

class ReportsScreen extends StatelessWidget {
  final List<Employee> employees;

  const ReportsScreen({super.key, required this.employees});

  /// 🔥 COUNT FUNCTION (TODAY STATUS ONLY)
  int countStatus(String shift, String status) {
    return employees
        .where((e) => e.shift == shift && e.status == status)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final shifts = ["A", "B", "C"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Shift Reports",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      /// ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 SHIFT CARDS
            Expanded(
              child: ListView.builder(
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final shift = shifts[index];

                  /// 🔥 TODAY COUNTS
                  final p = countStatus(shift, "P");
                  final l = countStatus(shift, "L");
                  final ab = countStatus(shift, "AB");
                  final off = countStatus(shift, "OFF");
                  final nh = countStatus(shift, "NH");

                  final total = p + l + ab + off + nh;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔹 SHIFT TITLE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Shift $shift",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Total: $total",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// 🔹 STATUS ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatus("P", p, Colors.green),
                            _buildStatus("L", l, Colors.orange),
                            _buildStatus("AB", ab, Colors.red),
                            _buildStatus("OFF", off, Colors.amber),
                            _buildStatus("NH", nh, Colors.blue),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// 🔹 PROGRESS BAR (PRESENT RATE)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : p / total,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 STATUS WIDGET
  Widget _buildStatus(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}