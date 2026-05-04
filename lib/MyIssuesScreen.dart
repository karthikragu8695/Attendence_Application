import 'package:attendance_plot/issueDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyIssuesScreen extends StatefulWidget {
  const MyIssuesScreen({super.key});

  @override
  State<MyIssuesScreen> createState() => _MyIssuesScreenState();
}

class _MyIssuesScreenState extends State<MyIssuesScreen> {
  final supabase = Supabase.instance.client;

  List issues = [];
  bool isLoading = true;
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  /// ================= FETCH =================
  Future<void> fetchIssues() async {
    try {
      final data = await supabase
          .from('issues')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        issues = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  /// ================= DELETE =================
  Future<void> deleteIssue(String id) async {
    await supabase.from('issues').delete().eq('id', id);
    fetchIssues();
  }

  /// ================= CONFIRM DELETE =================
  Future<bool?> confirmDelete() {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Issue"),
        content: const Text("Are you sure you want to delete?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// ================= END ISSUE =================
  Future<void> endIssue(Map item) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    await supabase
        .from('issues')
        .update({"end_time": end.toIso8601String(), "status": "completed"})
        .eq('id', item["id"]);

    fetchIssues();
  }

  /// ================= FILTER =================
  List get filteredIssues {
    if (selectedFilter == "All") return issues;

    return issues.where((item) {
      final status = item["status"] ?? "Pending";

      if (selectedFilter == "Pending") return status == "Pending";
      if (selectedFilter == "In Progress") return status == "In Progress";
      if (selectedFilter == "Completed") return status == "completed";

      return true;
    }).toList();
  }

  /// ================= HELPERS =================
  Color statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "In Progress":
        return Colors.blue;
      case "completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return "-";
    }
  }

  String duration(String? start, String? end) {
    if (start == null || end == null) return "-";

    final s = DateTime.parse(start);
    final e = DateTime.parse(end);
    final diff = e.difference(s);

    return "${diff.inHours}h ${diff.inMinutes.remainder(60)}m";
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("My Issues"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// 🔥 FILTER TABS
                SizedBox(
                  height: 55,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      _tab("All"),
                      _tab("Pending"),
                      _tab("In Progress"),
                      _tab("Completed"),
                    ],
                  ),
                ),

                /// 🔥 LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredIssues.length,
                    itemBuilder: (context, index) {
                      final item = filteredIssues[index];
                      final status = item["status"] ?? "Pending";

                      return Dismissible(
                        key: Key(item["id"].toString()),
                        direction: DismissDirection.endToStart,

                        /// 🔥 CONFIRM DELETE
                        confirmDismiss: (_) async => await confirmDelete(),

                        onDismissed: (_) => deleteIssue(item["id"]),

                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        /// 🔥 NAVIGATION
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IssueDetailScreen(item: item),
                              ),
                            ).then((_) => fetchIssues());
                          },
                          child: _card(item, status),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  /// TAB
  Widget _tab(String title) {
    final isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title; // 🔥 ONLY FILTER
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD
  Widget _card(Map item, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.precision_manufacturing, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item["machine_name"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(formatDate(item["created_at"] ?? "")),
              ],
            ),
            const SizedBox(height: 8),
            Text(item["issue_type"] ?? ""),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor(status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status),
            ),

            const SizedBox(height: 10),

            if (item["start_time"] != null && item["end_time"] != null)
              Text(
                "Duration: ${duration(item["start_time"], item["end_time"])}",
              ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => endIssue(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "End",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
