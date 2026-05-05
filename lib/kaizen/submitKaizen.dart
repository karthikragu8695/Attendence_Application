import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SubmitKaizenScreen extends StatefulWidget {
  const SubmitKaizenScreen({super.key});

  @override
  State<SubmitKaizenScreen> createState() => _SubmitKaizenScreenState();
}

class _SubmitKaizenScreenState extends State<SubmitKaizenScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController benefitController = TextEditingController();

  String? selectedCategory;
  String? selectedDepartment;

  XFile? beforeImage;
  XFile? afterImage;

  final picker = ImagePicker();

  /// 📸 PICK IMAGE
  Future<void> pickImage(bool isBefore) async {
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        if (isBefore) {
          beforeImage = image;
        } else {
          afterImage = image;
        }
      });
    }
  }

  /// ☁️ UPLOAD IMAGE
  Future<String?> uploadImage(XFile file, String name) async {
    final supabase = Supabase.instance.client;

    final bytes = await file.readAsBytes();

    await supabase.storage.from('kaizen-images').uploadBinary(name, bytes);

    return supabase.storage.from('kaizen-images').getPublicUrl(name);
  }

  /// 🚀 SUBMIT KAIZEN
  bool isLoading = false;

  Future<void> submitKaizen() async {
    final supabase = Supabase.instance.client;

    /// 🔴 VALIDATION
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedCategory == null ||
        selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? beforeUrl;
      String? afterUrl;

      /// 📤 Upload Before Image
      if (beforeImage != null) {
        beforeUrl = await uploadImage(
          beforeImage!,
          "before_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
      }

      /// 📤 Upload After Image
      if (afterImage != null) {
        afterUrl = await uploadImage(
          afterImage!,
          "after_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
      }

      /// 🧠 INSERT INTO SUPABASE
      await supabase.from('kaizens').insert({
        'title': titleController.text,
        'description': descriptionController.text,
        'category': selectedCategory,
        'department': selectedDepartment,
        'expected_benefit': benefitController.text,
        'before_image': beforeUrl,
        'after_image': afterUrl,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      /// ✅ SUCCESS
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kaizen Submitted Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      /// ❌ ERROR
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Submit Kaizen",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fieldLabel("Title *"),
            textField(titleController, "Enter short title"),

            const SizedBox(height: 16),

            fieldLabel("Category *"),
            dropdownField(
              value: selectedCategory,
              hint: "Select Category",
              items: const ["Productivity", "Safety", "Quality"],
              onChanged: (val) => setState(() => selectedCategory = val),
            ),

            const SizedBox(height: 16),

            fieldLabel("Department *"),
            dropdownField(
              value: selectedDepartment,
              hint: "Select Department",
              items: const ["Production", "Maintenance", "Quality", "Stores"],
              onChanged: (val) => setState(() => selectedDepartment = val),
            ),

            const SizedBox(height: 16),

            fieldLabel("Description *"),
            textField(
              descriptionController,
              "Describe your idea in detail...",
              maxLines: 4,
            ),

            const SizedBox(height: 16),

            /// ✅ FIXED IMAGE SECTION
            fieldLabel("Upload Images *"),
            Row(
              children: [
                Expanded(child: imageBox("Before Image", true)),
                const SizedBox(width: 12),
                Expanded(child: imageBox("After Image", false)),
              ],
            ),

            const SizedBox(height: 16),

            fieldLabel("Expected Benefit *"),
            textField(benefitController, "e.g. Time saving, Cost saving"),

            const SizedBox(height: 24),

            /// ✅ FIXED BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitKaizen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Kaizen",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// UI HELPERS

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: boxDecoration(),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget dropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: boxDecoration(),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  /// ✅ FIXED IMAGE PREVIEW
  Widget imageBox(String label, bool isBefore) {
    final image = isBefore ? beforeImage : afterImage;

    return GestureDetector(
      onTap: () => pickImage(isBefore),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.grey),
                  const SizedBox(height: 6),
                  Text(label),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(image.path), fit: BoxFit.cover),
              ),
      ),
    );
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}
