import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool loading = true;
  List<dynamic> attendanceData = [];

  late String today;

  @override
  void initState() {
    super.initState();

    today = DateTime.now().toIso8601String().split('T')[0];
    fetchAttendance();
  }

  // =========================
  // FETCH ONLY TODAY DATA
  // =========================
  Future<void> fetchAttendance() async {
    try {
      final data = await supabase
          .from('attendance')
          .select('''
            id,
            employee_id,
            date,
            status,
            employees!inner(shift)
          ''')
          .eq('date', today); // 🔥 IMPORTANT FIX

      setState(() {
        attendanceData = data ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        attendanceData = [];
        loading = false;
      });
    }
  }

  // =========================
  // COUNT BY SHIFT + STATUS
  // =========================
  int countBy(String shift, String status) {
    return attendanceData.where((e) {
      final emp = e['employees'];
      if (emp == null) return false;

      return emp['shift'] == shift && e['status'] == status;
    }).length;
  }

  // =========================
  // STATUS WIDGET
  // =========================
  Widget statusBox(String title, int count, Color color) {
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
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final shifts = ["A", "B", "C"];

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Shift Reports (Today)"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shifts.length,
        itemBuilder: (context, index) {
          final shift = shifts[index];

          final p = countBy(shift, "P");
          final l = countBy(shift, "L");
          final ab = countBy(shift, "AB");
          final off = countBy(shift, "OFF");
          final nh = countBy(shift, "NH");

          final total = p + l + ab + off + nh;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // SHIFT HEADER
                // =========================
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
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // =========================
                // STATUS ROW
                // =========================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    statusBox("P", p, Colors.green),
                    statusBox("L", l, Colors.orange),
                    statusBox("AB", ab, Colors.red),
                    statusBox("OFF", off, Colors.amber),
                    statusBox("NH", nh, Colors.blue),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}