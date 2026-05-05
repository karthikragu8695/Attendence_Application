import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

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

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Reports",
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

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

          /// CATEGORY COUNT
          Map<String, int> categoryCount = {};
          for (var item in data) {
            String cat = item['category'] ?? 'Other';
            categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔵 SUMMARY CARD
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
                          statItem("Total", total.toString()),
                          statItem("Approved", approved.toString()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          statItem("Pending", pending.toString()),
                          statItem("Rejected", rejected.toString()),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                /// 📊 MONTH OVERVIEW
                const Text("This Month",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: overviewCard(
                          "Total Ideas", total.toString()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: overviewCard(
                          "Implemented", approved.toString()),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// 📂 CATEGORY REPORT
                const Text("Category Breakdown",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),

                const SizedBox(height: 12),

                ...categoryCount.entries.map((entry) {
                  double percent =
                      entry.value / total;

                  return categoryItem(
                      entry.key, entry.value, percent);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔹 STAT ITEM
  Widget statItem(String title, String value) {
    return Column(
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
    );
  }

  /// 🔹 OVERVIEW CARD
  Widget overviewCard(String title, String value) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  /// 🔹 CATEGORY ITEM
  Widget categoryItem(String title, int count, double percent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(count.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 COMMON STYLE
  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}