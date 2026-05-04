import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MaintenanceDashboard extends StatefulWidget {
  const MaintenanceDashboard({super.key});

  @override
  State<MaintenanceDashboard> createState() => _MaintenanceDashboardState();
}

class _MaintenanceDashboardState extends State<MaintenanceDashboard> {
  List issues = [];
  List machines = [];

  int total = 0;
  int inProgress = 0;
  int completed = 0;
  int highPriority = 0;

  int totalDowntimeMinutes = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // =========================
  // FETCH DATA
  // =========================
  // =========================
  // FETCH DATA
  // =========================
  Future<void> fetchData() async {
    try {
      final issueRes = await supabase.from('issues').select();
      final machineRes = await supabase.from('machines').select();

      issues = issueRes;
      machines = machineRes;

      total = issues.length;

      // 🔥 NORMALIZE STATUS
      inProgress = issues.where((e) {
        final status = (e['status'] ?? '').toString().toLowerCase().replaceAll(
          ' ',
          '',
        );

        return status == 'inprogress';
      }).length;

      completed = issues.where((e) {
        final status = (e['status'] ?? '').toString().toLowerCase().replaceAll(
          ' ',
          '',
        );

        return status == 'completed';
      }).length;

      highPriority = issues.where((e) {
        return (e['priority'] ?? '').toString().toLowerCase() == 'high';
      }).length;

      // =========================
      // DOWNTIME CALCULATION
      // =========================
      totalDowntimeMinutes = 0;

      for (final i in issues) {
        try {
          final start = i['start_time'];
          final end = i['end_time'];

          if (start == null || end == null) continue;

          final s = DateTime.tryParse(start);
          final e = DateTime.tryParse(end);

          if (s == null || e == null) continue;

          if (e.isAfter(s)) {
            totalDowntimeMinutes += e.difference(s).inMinutes;
          }
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      debugPrint("ERROR: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

    //   appBar: AppBar(
    //  //   title: const Text("Maintenance Dashboard"),
    //     centerTitle: true,
    //     backgroundColor: const Color(0xFFF4F6FA),

    //     foregroundColor: Colors.black,
    //     elevation: 0,
    //   ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // STATS GRID
                  // =========================
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _card("Total Issues", "$total", Icons.build, Colors.blue),
                      _card(
                        "In Progress",
                        "$inProgress",
                        Icons.timelapse,
                        Colors.orange,
                      ),
                      _card(
                        "Completed",
                        "$completed",
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _card(
                        "High Priority",
                        "$highPriority",
                        Icons.warning,
                        Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // MACHINES
                  // =========================
                  const Text(
                    "Today Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // =========================
                  // DOWNTIME
                  // =========================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Downtime",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${totalDowntimeMinutes ~/ 60}h ${totalDowntimeMinutes % 60}m",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...machines.map((m) {
                    final count = issues
                        .where((i) => i['machine_name'] == m['name'])
                        .length;

                    return _tile(m['machine_name'] ?? '', count);
                  }),

                  // =========================
                  // ISSUES
                  // =========================
                  const Text(
                    "Issue Report",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...issues
                      .take(5)
                      .map(
                        (i) => _issueTile(
                          i['machine_name'] ?? '',
                          i['issue_type'] ?? '',
                          (i['status'] ?? '').toString(),
                        ),
                      ),
                ],
              ),
            ),
    );
  }

  // =========================
  // CARD
  // =========================
  Widget _card(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // =========================
  // MACHINE TILE
  // =========================
  Widget _tile(String name, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.precision_manufacturing),
          const SizedBox(width: 10),
          Expanded(child: Text(name)),
          Text(count.toString()),
        ],
      ),
    );
  }

  // =========================
  // ISSUE TILE
  // =========================
  Widget _issueTile(String machine, String type, String status) {
    final s = status.toLowerCase().trim();

    Color color;
    if (s == "completed") {
      color = Colors.green;
    } else if (s == "in_progress") {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.report),
          const SizedBox(width: 10),
          Expanded(child: Text("$machine - $type")),
          Text(
            s,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
