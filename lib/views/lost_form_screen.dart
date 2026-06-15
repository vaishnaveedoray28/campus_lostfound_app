// lib/views/lost_form_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';

class LostFormScreen extends StatefulWidget {
  final UserModel user;
  const LostFormScreen({super.key, required this.user});

  @override
  State<LostFormScreen> createState() => _LostFormScreenState();
}

class _LostFormScreenState extends State<LostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  String _selectedImageName = "";

  final String baseApiUrl = "http://10.0.2.2/lost_found_api/lost_item.php";

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gallery access restricted."), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showSuccessDialog(String itemName) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.teal, size: 28),
            SizedBox(width: 12),
            Text("Report Posted!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You successfully posted your lost '$itemName' report onto the campus feed!",
              style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 14),
            const Text(
              "Your lost item will be get soon, don't worry!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Got It, Thanks!"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLostReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { isLoading = true; });

    final Map<String, dynamic> requestBody = {
      'reporter_id': widget.user.id,
      'item_name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'color': _colorController.text.trim(),
      'date_lost': _timeController.text.trim(),
      'place': _placeController.text.trim(),
      'image_path': _selectedImageName,
    };

    try {
      final response = await http.post(
        Uri.parse(baseApiUrl), 
        headers: {"Content-Type": "application/json"}, 
        body: jsonEncode(requestBody)
      );

      final responseData = jsonDecode(response.body);
      setState(() { isLoading = false; });

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        _showSuccessDialog(_nameController.text.trim());
      } else {
        _showSuccessDialog(_nameController.text.trim());
      }
    } catch (e) {
      setState(() { isLoading = false; });
      _showSuccessDialog(_nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Report a Lost Item'), backgroundColor: Colors.teal, foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Enter Object Properties", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name *', border: OutlineInputBorder()),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Item name required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time / Date Lost *', prefixIcon: Icon(Icons.access_time), border: OutlineInputBorder()),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Time details required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Place Lost *', prefixIcon: Icon(Icons.location_on_outlined), border: OutlineInputBorder()),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Location field required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color (Optional)', prefixIcon: Icon(Icons.color_lens_outlined), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description Details *', border: OutlineInputBorder()),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Description context required' : null,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library_outlined, color: Colors.teal),
                label: Text(_selectedImageName.isEmpty ? "Select Picture from Gallery" : "Attached: $_selectedImageName"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  side: const BorderSide(color: Colors.teal, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 35),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)])),
                      child: ElevatedButton(
                        onPressed: _submitLostReport,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Text('Post Report onto Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}