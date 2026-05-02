import 'dart:io';

import 'package:attendance_plot/model/date.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'main.dart';

class AttendanceScreen extends StatefulWidget {
  final List<Employee> employees;

  const AttendanceScreen({super.key, required this.employees});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final today = DateTime.now().toIso8601String().split('T')[0];
  late String yesterday;

  String selectedShift = "A";

  Map<String, String> todayMap = {};
  Map<String, String> yesterdayMap = {};

  @override
  void initState() {
    super.initState();

    yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    fetchAttendance();
  }

  /// 🔥 FETCH DATA
  Future<void> fetchAttendance() async {
    final data = await supabase
        .from('attendance')
        .select()
        .inFilter('date', [today, yesterday]);

    todayMap.clear();
    yesterdayMap.clear();

    for (var row in data) {
      final empId = row['employee_id'].toString();
      final date = row['date'].toString().split('T')[0];

      if (date == today) {
        todayMap[empId] = row['status'];
      } else if (date == yesterday) {
        yesterdayMap[empId] = row['status'];
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  List<Employee> getFilteredEmployees() {
    return widget.employees.where((e) => e.shift == selectedShift).toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "P":
        return Colors.green;
      case "L":
        return Colors.orange;
      case "AB":
        return Colors.red;
      case "OFF":
        return Colors.yellow;
      case "NH":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 🔥 PDF (UNCHANGED)
  Future<void> generateShiftPdf() async {
  final pdf = pw.Document();
  final filtered = getFilteredEmployees();

  /// 🔥 SORT ASCENDING
  filtered.sort((a, b) {
    int getNumber(String id) {
      return int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    return getNumber(a.employee_id ?? "")
        .compareTo(getNumber(b.employee_id ?? ""));
  });

  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  final daysInMonth = DateUtils.getDaysInMonth(year, month);

  final data = await supabase
      .from('attendance')
      .select()
      .gte('date', DateTime(year, month, 1).toIso8601String())
      .lte(
        'date',
        DateTime(year, month, daysInMonth, 23, 59, 59)
            .toIso8601String(),
      );

  /// 🔥 MAP
  Map<String, Map<int, String>> monthlyMap = {};
  for (var row in data) {
    final empId = row['employee_id'].toString();
    final date = DateTime.parse(row['date']);
    final day = date.day;

    monthlyMap.putIfAbsent(empId, () => {});
    monthlyMap[empId]![day] = row['status'];
  }

  pw.Widget cell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: pw.TextStyle(fontSize: 7)),
    );
  }

  pdf.addPage(
    pw.MultiPage(
      orientation: pw.PageOrientation.landscape,
      margin: const pw.EdgeInsets.all(6),
      build: (context) => [
        pw.SizedBox(height: 20),

        /// 🔥 TITLE
        pw.Center(
          child: pw.Text(
            "SHIFT $selectedShift - ATTENDANCE ($month/$year)",
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        pw.SizedBox(height: 6),

        pw.Table(
          border: pw.TableBorder.all(width: 0.3),
          children: [
            /// 🔥 HEADER ROW
            pw.TableRow(
              children: [
                cell("NO"),   // 🔥 NEW COLUMN
                cell("NAME"),
                ...List.generate(daysInMonth, (i) {
                  final d = DateTime(year, month, i + 1);
                  return pw.Container(
                    color: d.weekday == 7
                        ? PdfColors.red200
                        : PdfColors.grey300,
                    child: cell(getDayName(d.weekday)),
                  );
                }),
                cell("P"),
                cell("L"),
                cell("AB"),
                cell("OFF"),
                cell("NH"),
              ],
            ),

            /// 🔥 DATE ROW
            pw.TableRow(
              children: [
                cell(""),
                cell(""),
                ...List.generate(daysInMonth, (i) {
                  final d = DateTime(year, month, i + 1);
                  return pw.Container(
                    color: d.weekday == 7
                        ? PdfColors.red100
                        : PdfColors.white,
                    child: cell("${i + 1}"),
                  );
                }),
                cell(""),
                cell(""),
                cell(""),
                cell(""),
                cell(""),
              ],
            ),

            /// 🔥 DATA ROWS
            ...filtered.asMap().entries.map((entry) {
              final index = entry.key;
              final emp = entry.value;

              int p = 0, l = 0, ab = 0, off = 0, nh = 0;

              List<pw.Widget> dayCells = [];

              for (int d = 1; d <= daysInMonth; d++) {
                String status =
                    monthlyMap[emp.id.toString()]?[d] ?? "-";

                if (status == "P") p++;
                if (status == "L") l++;
                if (status == "AB") ab++;
                if (status == "OFF") off++;
                if (status == "NH") nh++;

                dayCells.add(
                  pw.Container(
                    alignment: pw.Alignment.center,
                    color: getPdfColor(status),
                    child: pw.Text(
                      status,
                      style: const pw.TextStyle(fontSize: 6),
                    ),
                  ),
                );
              }

              return pw.TableRow(
                children: [
                  /// 🔥 SERIAL NUMBER
                  cell("${index + 1}"),

                  /// 🔥 NAME + ID
                  cell("${emp.name} (${emp.employee_id})"),

                  ...dayCells,

                  cell("$p"),
                  cell("$l"),
                  cell("$ab"),
                  cell("$off"),
                  cell("$nh"),
                ],
              );
            }),
          ],
        ),
      ],
    ),
  );

  final bytes = await pdf.save();

  await Printing.sharePdf(
    bytes: bytes,
    filename:
        "Attendance_Shift-${selectedShift}_${month.toString().padLeft(2, '0')}_$year.pdf",
  );
}

  @override
  Widget build(BuildContext context) {
    final employees = getFilteredEmployees();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Attendance",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: generateShiftPdf,
          ),
        ],
      ),

      body: Column(
        children: [
          /// SHIFT FILTER
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["A", "B", "C"].map((shift) {
                final isSelected = selectedShift == shift;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedShift = shift);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Shift $shift",
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          /// LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];

                final todayStatus =
                    todayMap[emp.id.toString()] ?? "-";

                final yesterdayStatus =
                    yesterdayMap[emp.id.toString()] ?? "-";

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(child: Text(emp.name[0])),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(emp.name,
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold)),
                                const SizedBox(width: 10),
                                Text("(ID: ${emp.employee_id})",
                                    style: const TextStyle(
                                        fontSize: 12)),
                              ],
                            ),
                            Text("Shift ${emp.shift}"),

                            Text(
                              "Yesterday: $yesterdayStatus",
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w500,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      DropdownButton<String>(
                        value:
                            todayStatus == "-" ? null : todayStatus,
                        hint: const Text("Select"),
                        underline: const SizedBox(),
                        items: ["P", "L", "AB", "OFF", "NH"]
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color:
                                        getStatusColor(s),
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          if (value == null) return;

                          await supabase
                              .from('attendance')
                              .upsert({
                            'employee_id': emp.id,
                            'date': today,
                            'status': value,
                          }, onConflict: 'employee_id,date');

                          await fetchAttendance(); // 🔥 refresh
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

PdfColor getPdfColor(String status) {
  switch (status) {
    case "P":
      return PdfColors.green200;
    case "L":
      return PdfColors.orange200;
    case "AB":
      return PdfColors.red200;
    case "OFF":
      return PdfColors.yellow200;
    case "NH":
      return PdfColors.blue200;
    default:
      return PdfColors.white;
  }
}