import 'package:flutter/material.dart';

class KaizenDetailScreen extends StatelessWidget {
  final Map data;

  const KaizenDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Kaizen Details",
            style: TextStyle(color: Colors.black)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 TITLE + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                statusChip(data['status'] ?? 'pending'),
              ],
            ),

            const SizedBox(height: 8),

            /// 🔹 CATEGORY + DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['category'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  data['created_at']
                          ?.toString()
                          .substring(0, 10) ??
                      '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 DESCRIPTION
            sectionTitle("Description"),
            detailBox(data['description'] ?? ''),

            const SizedBox(height: 16),

            /// 🔹 DEPARTMENT
            sectionTitle("Department"),
            detailBox(data['department'] ?? ''),

            const SizedBox(height: 16),

            /// 🔹 BENEFIT
            sectionTitle("Expected Benefit"),
            detailBox(data['benefit'] ?? ''),

            const SizedBox(height: 16),

            /// 🔹 IMAGES
            sectionTitle("Before / After"),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: imageBox(data['before_image'], "Before")),
                const SizedBox(width: 12),
                Expanded(child: imageBox(data['after_image'], "After")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 SECTION TITLE
  Widget sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14));
  }

  /// 🔹 BOX
  Widget detailBox(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }

  /// 🔹 STATUS CHIP
  Widget statusChip(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case "approved":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12),
      ),
    );
  }

  /// 🔹 IMAGE BOX
  Widget imageBox(String? url, String label) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: Center(child: Text(label)),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}