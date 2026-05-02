import 'package:attendance_plot/main.dart';
import 'package:flutter/material.dart';

class EmployeesScreen extends StatefulWidget {
  final List<Employee> employees;
  final VoidCallback refresh;

  const EmployeesScreen({
    super.key,
    required this.employees,
    required this.refresh,
  });

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> shifts = ["A", "B", "C"];

  bool isAscending = true;

  /// 🔍 SEARCH
  bool isSearching = false;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  /// 🔥 ROLES LIST (FIX)
  final List<String> roles = [
    "worker",
    "Incharge",
    "Assistent Incharge",
    "Fettling Feeder",
    "Bore",
    "Chipping",
    "Belt",
    "RFd counter",
    "Stacker Operator",
    "Shotblast Operator",
    "Gaadi",
    "System Entry Operator",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: shifts.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// 🔹 FILTER + SORT + SEARCH
  List<Employee> getFilteredEmployees() {
    final currentShift = shifts[_tabController.index];

    final filtered = widget.employees
        .where((e) => e.shift == currentShift)
        .where((e) {
          final q = searchQuery.toLowerCase();
          return e.name.toLowerCase().contains(q) ||
              (e.employee_id ?? "").toLowerCase().contains(q);
        })
        .toList();

    filtered.sort((a, b) {
      int getNumber(String id) {
        return int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }

      return isAscending
          ? getNumber(
              a.employee_id ?? "",
            ).compareTo(getNumber(b.employee_id ?? ""))
          : getNumber(
              b.employee_id ?? "",
            ).compareTo(getNumber(a.employee_id ?? ""));
    });

    return filtered;
  }

  /// 🔹 ROLE COLOR
  Color getRoleColor(String? role) {
    switch (role) {
      case "Incharge":
        return Colors.red;
      case "Assistent Incharge":
        return Colors.deepPurple;
      case "worker":
        return Colors.green;
      case "Chipping":
        return Colors.teal;
      case "Bore":
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  /// 🔹 EDIT
  void openEditEmployeeSheet(Employee emp) {
    final nameController = TextEditingController(text: emp.name);
    final empIdController = TextEditingController(text: emp.employee_id ?? "");

    String selectedShift = emp.shift;
    String selectedRole = emp.role ?? "worker";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔥 HANDLE BAR
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// 🔥 TITLE
                    const Text(
                      "Edit Employee",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 NAME
                    const Text("Employee Name"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter name",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// 🔹 ID
                    const Text("Employee ID"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: empIdController,
                      decoration: InputDecoration(
                        hintText: "EMP001",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// 🔹 SHIFT
                    const Text("Shift"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedShift,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: shifts
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text("Shift $e"),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setModalState(() => selectedShift = val!);
                      },
                    ),

                    const SizedBox(height: 15),

                    /// 🔹 ROLE
                    const Text("Role"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items:
                          [
                                "worker",
                                "Incharge",
                                "Assistent Incharge",
                                "Fettling Feeder",
                                "Bore",
                                "Chipping",
                                "Belt",
                                "RFd counter",
                                "Stacker Operator",
                                "Shotblast Operator",
                                "Gaadi",
                                "System Entry Operator",
                                "Other",
                              ]
                              .toSet() // 🔥 FIX duplicate dropdown error
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (val) {
                        setModalState(() => selectedRole = val!);
                      },
                    ),

                    const SizedBox(height: 25),

                    /// 🔥 UPDATE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final empId = empIdController.text.trim();

                          if (name.isEmpty || empId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Fill all fields")),
                            );
                            return;
                          }

                          await supabase
                              .from('employees')
                              .update({
                                'name': name,
                                'id_no': empId,
                                'shift': selectedShift,
                                'role': selectedRole,
                              })
                              .eq('id', emp.id);

                          if (mounted) {
                            Navigator.pop(context);
                            widget.refresh();
                          }
                        },
                        label: const Text(
                          "Update Employee",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🔹 ADD
  void openAddEmployeeSheet() {
    final nameController = TextEditingController();
    final empIdController = TextEditingController();

    String selectedShift = "A";
    String selectedRole = "worker";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔥 HEADER
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Add Employee",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 NAME
                    const Text("Employee Name"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter name",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// 🔹 ID
                    const Text("Employee ID"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: empIdController,
                      decoration: InputDecoration(
                        hintText: "EMP001",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// 🔹 SHIFT
                    const Text("Shift"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedShift,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: shifts
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text("Shift $e"),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setModalState(() => selectedShift = val!);
                      },
                    ),

                    const SizedBox(height: 15),

                    /// 🔹 ROLE
                    const Text("Role"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items:
                          [
                                "worker",
                                "Incharge",
                                "Assistent Incharge",
                                "Fettling Feeder",
                                "Bore",
                                "Chipping",
                                "Belt",
                                "RFd counter",
                                "Stacker Operator",
                                "Shotblast Operator",
                                "Gaadi",
                                "System Entry Operator",
                                "Other",
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (val) {
                        setModalState(() => selectedRole = val!);
                      },
                    ),

                    const SizedBox(height: 25),

                    /// 🔥 BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final empId = empIdController.text.trim();

                          if (name.isEmpty || empId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Fill all fields")),
                            );
                            return;
                          }

                          await supabase.from('employees').insert({
                            'name': name,
                            'id_no': empId,
                            'shift': selectedShift,
                            'role': selectedRole,
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            widget.refresh();
                          }
                        },
                        child: const Text(
                          "Add Employee",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final employees = getFilteredEmployees();

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search employee...",
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => searchQuery = val),
              )
            : const Text("Employees"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  searchQuery = "";
                }
                isSearching = !isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () => setState(() => isAscending = !isAscending),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: shifts.map((s) => Tab(text: "Shift $s")).toList(),
          onTap: (_) => setState(() {}),
        ),
      ),

      body: employees.isEmpty
          ? const Center(child: Text("No Employees"))
          : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final e = employees[index];

                return Dismissible(
                  key: Key(e.id),
                  direction: DismissDirection.endToStart,

                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  /// 🔥 ADD THIS CONFIRM DIALOG
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Employee"),
                        content: Text("Are you sure to delete ${e.name}?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },

                  /// 🔥 DELETE ONLY IF CONFIRMED
                  onDismissed: (direction) async {
                    await supabase.from('employees').delete().eq('id', e.id);

                    widget.refresh();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${e.name} deleted")),
                    );
                  },

                  child: ListTile(
                    onTap: () => openEditEmployeeSheet(e),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(e.name[0].toUpperCase()),
                    ),
                    title: Text(
                      e.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          "ID: ${e.employee_id}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getRoleColor(e.role).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            e.role ?? "",
                            style: TextStyle(
                              fontSize: 10,
                              color: getRoleColor(e.role),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(e.status),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: openAddEmployeeSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
