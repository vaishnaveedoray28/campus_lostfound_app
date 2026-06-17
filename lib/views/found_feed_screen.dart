import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class FoundFeedScreen extends StatefulWidget {
  final UserModel user;
  const FoundFeedScreen({super.key, required this.user});

  @override
  State<FoundFeedScreen> createState() => _FoundFeedScreenState();
}

class _FoundFeedScreenState extends State<FoundFeedScreen> {
  bool isLoading = true;
  List<dynamic> lostItems = [];
  final String apiUrl = "http://10.0.2.2/lost_found_api/get_lost_items.php";
  final String claimUrl = "http://10.0.2.2/lost_found_api/claim_item.php";

  @override
  void initState() {
    super.initState();
    _fetchLostItems();
  }

  Future<void> _fetchLostItems() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        setState(() {
          lostItems = responseData['items'];
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  void _openClaimDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Claim ${item['item_name']}"),
        content: const Text(
          "Are you sure you found this item? Tapping confirm will instantly link your account and share your registered phone number with the owner so they can reach out to you.",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A), 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                final res = await http.post(
                  Uri.parse(claimUrl),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "item_id": item['id'],
                    "finder_id": widget.user.id,
                    "finder_phone": widget.user.phone, // Automatically pulls from registration
                  }),
                );
                if (mounted) {
                  Navigator.pop(context);
                  _fetchLostItems(); // Instantly refresh layout feed
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Campus Claims Feed'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchLostItems)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : lostItems.isEmpty
              ? const Center(child: Text("No lost items currently pending.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lostItems.length,
                  itemBuilder: (context, index) {
                    final item = lostItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        onTap: () => _openClaimDialog(item),
                        title: Text(item['item_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("📍 Place: ${item['place'] ?? ''}"),
                            Text("⏰ Time: ${item['date_lost'] ?? ''}"),
                            Text("📝 Desc: ${item['description'] ?? ''}"),
                            Text("👤 Reporter: ${item['reporter_name'] ?? ''} (${item['reporter_matric'] ?? ''})"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}