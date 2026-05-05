import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IssueDetailScreen extends StatefulWidget {
  final Map item;

  const IssueDetailScreen({super.key, required this.item});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final supabase = Supabase.instance.client;

  late Map item;

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  Future<void> updateIssue(Map<String, dynamic> data) async {
    await supabase.from('issues').update(data).eq('id', item["id"]);

    final updated = await supabase
        .from('issues')
        .select()
        .eq('id', item["id"])
        .single();

    setState(() {
      item = updated;
    });
  }

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

  String formatDate(String? date) {
    if (date == null) return "-";
    final dt = DateTime.parse(date);
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  String formatTime(String? date) {
    if (date == null) return "-";
    final dt = DateTime.parse(date);
    return "${dt.hour}:${dt.minute}";
  }

  String duration() {
    if (item["start_time"] == null || item["end_time"] == null) return "-";

    final s = DateTime.parse(item["start_time"]);
    final e = DateTime.parse(item["end_time"]);

    final diff = e.difference(s);
    return "${diff.inHours}h ${diff.inMinutes.remainder(60)}m";
  }

  Future<void> endIssue() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    await updateIssue({
      "end_time": end.toIso8601String(),
      "status": "completed",
    });
  }

  void editDialog() {
    final descController =
        TextEditingController(text: item["description"] ?? "");

    String issueType = item["issue_type"] ?? "Electrical";
    TimeOfDay? selectedStartTime;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit Issue"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: issueType,
                  items: const [
                    DropdownMenuItem(
                        value: "Electrical", child: Text("Electrical")),
                    DropdownMenuItem(
                        value: "Mechanical", child: Text("Mechanical")),
                    DropdownMenuItem(
                        value: "Oil Leak", child: Text("Oil Leak")),
                    DropdownMenuItem(
                        value: "Breakdown", child: Text("Breakdown")),
                    DropdownMenuItem(
                        value: "Power Issue", child: Text("Power Issue")),
                  ],
                  onChanged: (val) {
                    setState(() => issueType = val!);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration:
                      const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time != null) {
                      setState(() {
                        selectedStartTime = time;
                      });
                    }
                  },
                  child: Text(
                    selectedStartTime == null
                        ? "Select Start Time"
                        : "Start: ${selectedStartTime!.format(context)}",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> data = {
                    "issue_type": issueType,
                    "description": descController.text,
                  };

                  if (selectedStartTime != null) {
                    final now = DateTime.now();
                    final start = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedStartTime!.hour,
                      selectedStartTime!.minute,
                    );

                    data["start_time"] = start.toIso8601String();
                    data["status"] = "In Progress";
                  }

                  await updateIssue(data);
                  Navigator.pop(context);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  @override
Widget build(BuildContext context) {
  final status = item["status"] ?? "Pending";

  return Scaffold(
    backgroundColor: const Color(0xFFF4F6FA),

    appBar: AppBar(
      title: const Text("Issue Details"),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          /// 🔥 HEADER CARD (Machine + Status)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor(status).withOpacity(0.15),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor(status).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.precision_manufacturing,
                    color: statusColor(status),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["machine_name"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["issue_type"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔥 DESCRIPTION CARD
          _infoCard(
            title: "Description",
            value: item["description"] ?? "-",
            icon: Icons.description,
          ),

          const SizedBox(height: 16),

          /// 🔥 TIMELINE CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Timeline",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 12),

                _timelineRow(
                  "Created",
                  formatDate(item["created_at"]),
                  Icons.calendar_today,
                ),

                _timelineRow(
                  "Start",
                  formatTime(item["start_time"]),
                  Icons.play_arrow,
                ),

                _timelineRow(
                  "End",
                  formatTime(item["end_time"]),
                  Icons.stop,
                ),

                const Divider(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Duration",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      duration(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: endIssue,
                  icon: const Icon(Icons.stop, color: Colors.white),
                  label: const Text("End",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: editDialog,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label:  Text("Edit",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
Widget _infoCard({
  required String title,
  required String value,
  required IconData icon,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    ),
  );
}

Widget _timelineRow(String title, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(child: Text(title)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}