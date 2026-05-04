import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// =======================
/// MODEL
/// =======================
class Machine {
  final String name;
  final IconData icon;

  Machine({required this.name, required this.icon});
}

class IssueType {
  final String name;
  final IconData icon;
  final Color color;

  IssueType({required this.name, required this.icon, required this.color});
}

/// =======================
/// SCREEN
/// =======================
class MachineSelectScreen extends StatelessWidget {
  MachineSelectScreen({super.key});

  final List<Machine> machines = [
    Machine(
      name: "Fettling Machine",
      icon: Icons.build                     ,
    ),
    Machine(
      name: "Old Patel Shot Blast Machine",
      icon: Icons.precision_manufacturing,
    ),
    Machine(
      name: "New Patel Shot Blast Machine",
      icon: Icons.precision_manufacturing,
    ),
    Machine(name: "Belt Conveyor", icon: Icons.settings),
    Machine(name: "Bore Machine", icon: Icons.build),
    Machine(name: "Chipping Machine", icon: Icons.construction),
    Machine(name: "Forklift Issues", icon: Icons.local_shipping),
    Machine(name: "Power Cut", icon: Icons.bolt),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Select Machine"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: machines.length,
        itemBuilder: (context, index) {
          final machine = machines[index];

          return _MachineCard(
            machine: machine,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IssueDetailScreen(machine: machine),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// =======================
/// MACHINE CARD
/// =======================
class _MachineCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback onTap;

  const _MachineCard({required this.machine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(machine.icon, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    machine.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================
/// ISSUE SCREEN + SUPABASE
/// =======================
class IssueDetailScreen extends StatefulWidget {
  final Machine machine;

  const IssueDetailScreen({super.key, required this.machine});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  String? selectedIssue;
  final TextEditingController descController = TextEditingController();
  DateTime? startTime;
  DateTime? endTime;

  bool isLoading = false;

  final supabase = Supabase.instance.client;
  Future<void> pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final now = DateTime.now();
      setState(() {
        startTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final now = DateTime.now();
      setState(() {
        endTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String getBreakdownDuration() {
    if (startTime == null || endTime == null) return "0";

    final diff = endTime!.difference(startTime!);

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    return "$hours hr $minutes min";
  }

  final List<IssueType> issues = [
    IssueType(name: "Electrical", icon: Icons.bolt, color: Colors.orange),
    IssueType(name: "Mechanical", icon: Icons.build, color: Colors.blue),
    IssueType(name: "Oil Leak", icon: Icons.opacity, color: Colors.green),
    IssueType(name: "Breakdown", icon: Icons.warning, color: Colors.red),
    IssueType(name: "Power Issue", icon: Icons.power, color: Colors.purple),
    IssueType(name: "Sensor Fault", icon: Icons.sensors, color: Colors.teal),
  ];

  @override
  void dispose() {
    descController.dispose();
    super.dispose();
  }

  /// =======================
  /// SUBMIT TO SUPABASE
  /// =======================
  Future<void> submit() async {
    if (isLoading) return;

    if (selectedIssue == null || selectedIssue!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select issue type")));
      return;
    }

    if (descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter description")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.from('issues').insert({
        'machine_name': widget.machine.name,
        'issue_type': selectedIssue,
        'description': descController.text.trim(),
        'status': 'Pending',
        'start_time': startTime?.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'breakdown_duration': getBreakdownDuration(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Issue Saved Successfully ✅")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Issue Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// MACHINE CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(widget.machine.icon, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.machine.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ISSUE TYPE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: selectedIssue,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.report_problem),
                  labelText: "Issue Type",
                ),
                items: issues.map((e) {
                  return DropdownMenuItem(
                    value: e.name,
                    child: Row(
                      children: [
                        Icon(e.icon, color: e.color, size: 18),
                        const SizedBox(width: 8),
                        Text(e.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => selectedIssue = val);
                },
              ),
            ),

            const SizedBox(height: 15),

            /// DESCRIPTION
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.description),
                  hintText: "Describe issue...",
                ),
              ),
            ),
            const SizedBox(height: 15),
             Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickStartTime,
                    child: Text(
                      startTime == null
                          ? "Start Time"
                          : "Start: ${startTime!.hour}:${startTime!.minute}",
                    ),
                  ),
                ),
                // const SizedBox(width: 10),
                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: pickEndTime,
                //     child: Text(
                //       endTime == null
                //           ? "End Time"
                //           : "End: ${endTime!.hour}:${endTime!.minute}",
                //     ),
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 25),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
