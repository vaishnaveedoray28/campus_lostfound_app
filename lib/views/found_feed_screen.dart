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
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("I Found this ${item['item_name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your contact number so the owner can reach out to retrieve it:", 
              style: TextStyle(fontSize: 13, color: Colors.black54)
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Your Phone Number", 
                border: OutlineInputBorder()
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A), 
              foregroundColor: Colors.white
            ),
            onPressed: () async {
              if (phoneController.text.trim().isEmpty) return;
              
              try {
                final res = await http.post(
                  Uri.parse(claimUrl),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "item_id": item['id'], 
                    "finder_id": widget.user.id, 
                    "finder_phone": phoneController.text.trim()
                  }),
                );
                
                final responseData = jsonDecode(res.body);
                
                if (mounted) {
                  Navigator.pop(context);
                  _fetchLostItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(responseData['message'] ?? "Claim submitted successfully!"), 
                      backgroundColor: const Color(0xFF1E3A8A)
                    ),
                  );
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Campus Claims Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchLostItems)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : lostItems.isEmpty
              ? const Center(child: Text("🎉 Excellent! No lost items currently pending.", style: TextStyle(color: Colors.grey, fontSize: 15)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lostItems.length,
                  itemBuilder: (context, index) {
                    final item = lostItems[index];
                    return InkWell(
                      onTap: () => _openClaimDialog(item),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[200]!)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['item_name'] ?? 'Unknown Item', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                                    child: const Text("LOST", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                                  )
                                ],
                              ),
                              const Divider(height: 20),
                              Row(children: [const Icon(Icons.location_on, size: 16, color: Color(0xFF1E3A8A)), const SizedBox(width: 6), Text("Place: ${item['place'] ?? 'N/A'}", style: const TextStyle(fontSize: 13))]),
                              const SizedBox(height: 6),
                              Row(children: [const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF1E3A8A)), const SizedBox(width: 6), Text("Time: ${item['date_lost'] ?? 'N/A'}", style: const TextStyle(fontSize: 13))]),
                              const SizedBox(height: 8),
                              Text("Description: ${item['description'] ?? ''}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                              const Divider(height: 24),
                              const Text("REPORTER:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38)),
                              Text("👤 Name: ${item['reporter_name'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text("🆔 Matric: ${item['reporter_matric'] ?? 'N/A'}", style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 8),
                              const Text("💡 Tap this card if you found this item to submit your number!", style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}