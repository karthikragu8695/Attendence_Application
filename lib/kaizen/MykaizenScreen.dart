import 'package:attendance_plot/kaizen/KaizenDeatil.dart';
import 'package:attendance_plot/kaizen/home.dart';
import 'package:attendance_plot/kaizen/submitKaizen.dart';
import 'package:attendance_plot/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyKaizenScreen extends StatefulWidget {
  const MyKaizenScreen({super.key});

  @override
  State<MyKaizenScreen> createState() => _MyKaizenScreenState();
}

class _MyKaizenScreenState extends State<MyKaizenScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late TabController _tabController;

  List allData = [];
  List filteredData = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
    fetchKaizens();

    _tabController.addListener(() {
      filterData();
    });
  }

  Future<void> fetchKaizens() async {
    final data = await supabase
        .from('kaizens')
        .select()
        .order('created_at', ascending: false);

    if (!mounted) return;

    setState(() {
      allData = data;
      filteredData = data;
    });
  }

  void filterData() {
    String status = "";

    switch (_tabController.index) {
      case 1:
        status = "pending";
        break;
      case 2:
        status = "approved";
        break;
      case 3:
        status = "rejected";
        break;
      default:
        filteredData = allData;
        setState(() {});
        return;
    }

    filteredData = allData.where((e) => e['status'] == status).toList();
    setState(() {});
  }

  Future<void> deleteKaizen(String id) async {
    await supabase.from('kaizens').delete().eq('id', id);
    fetchKaizens();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Deleted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      /// 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Kaizen",
            style: TextStyle(color: Colors.black)),

        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),

      /// 📦 BODY
      body: filteredData.isEmpty
          ? const Center(child: Text("No Kaizen found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];

                return Dismissible(
                  key: Key(item['id'].toString()),
                  direction: DismissDirection.endToStart,

                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Kaizen"),
                        content: const Text(
                            "Are you sure you want to delete this?"),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text("Delete",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },

                  onDismissed: (direction) {
                    deleteKaizen(item['id'].toString());
                  },

                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              KaizenDetailScreen(data: item),
                        ),
                      );
                    },
                    child: kaizenCard(
                      title: item['title'] ?? '',
                      category: item['category'] ?? '',
                      status: item['status'] ?? 'pending',
                      date: item['created_at']
                              ?.toString()
                              .substring(0, 10) ??
                          '',
                      beforeImage: item['before_image'],
                      afterImage: item['after_image'],
                    ),
                  ),
                );
              },
            ),

      /// 🔻 BOTTOM NAV
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              /// HOME
              navItem(
                Icons.home,
                "Home",
                false,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardScreen(employes: [],)),
                    (route) => false,
                  );
                },
              ),

              /// MY KAIZEN (ACTIVE)
              navItem(
                Icons.list_alt,
                "My Kaizen",
                true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),

      /// ➕ FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubmitKaizenScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// 🔹 NAV ITEM
class navItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const navItem(
    this.icon,
    this.label,
    this.active, {
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.blue : Colors.grey),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: active ? Colors.blue : Colors.grey)),
        ],
      ),
    );
  }
}
class kaizenCard extends StatelessWidget {
  final String title;
  final String category;
  final String status;
  final String date;
  final String? beforeImage;
  final String? afterImage;

  const kaizenCard({
    super.key,
    required this.title,
    required this.category,
    required this.status,
    required this.date,
    this.beforeImage,
    this.afterImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 TITLE + STATUS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              statusChip(status),
            ],
          ),

          const SizedBox(height: 6),

          /// 🔹 CATEGORY + DATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.category,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    category,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔹 IMAGES
          Row(
            children: [
              Expanded(
                child: imageBox(beforeImage, "Before"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: imageBox(afterImage, "After"),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🔹 IMAGE BOX
  Widget imageBox(String? url, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Colors.grey)),

        const SizedBox(height: 4),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: url == null || url.isEmpty
              ? Container(
                  height: 70,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 20, color: Colors.grey),
                  ),
                )
              : Image.network(
                  url,
                  height: 70,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
      ],
    );
  }
}