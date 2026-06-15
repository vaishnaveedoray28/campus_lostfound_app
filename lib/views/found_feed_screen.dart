// lib/views/found_feed_screen.dart
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Campus Claims Feed'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchLostItems)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : lostItems.isEmpty
              ? const Center(child: Text("🎉 Excellent! No lost items currently pending.", style: TextStyle(color: Colors.grey, fontSize: 15)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lostItems.length,
                  itemBuilder: (context, index) {
                    final item = lostItems[index];
                    return Card(
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
                            Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.teal), const SizedBox(width: 6), Text("Place: ${item['place'] ?? 'N/A'}", style: const TextStyle(fontSize: 13))]),
                            const SizedBox(height: 6),
                            Row(children: [const Icon(Icons.access_time_filled, size: 16, color: Colors.teal), const SizedBox(width: 6), Text("Time: ${item['date_lost'] ?? 'N/A'}", style: const TextStyle(fontSize: 13))]),
                            if (item['color'] != null && item['color'].toString().trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(children: [const Icon(Icons.color_lens, size: 16, color: Colors.teal), const SizedBox(width: 6), Text("Color: ${item['color']}", style: const TextStyle(fontSize: 13))]),
                            ],
                            const SizedBox(height: 8),
                            Text("Description: ${item['description'] ?? ''}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            const Divider(height: 24),
                            const Text("REPORTER CONTACT DETAILS:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 0.5)),
                            const SizedBox(height: 6),
                            Text("👤 Name: ${item['reporter_name'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text("🆔 Matric No: ${item['reporter_matric'] ?? 'N/A'}", style: const TextStyle(fontSize: 13)),
                            Text("🏠 Hostel: ${item['reporter_inasis'] ?? 'N/A'}", style: const TextStyle(fontSize: 13)),
                            Text("📞 Phone Number: ${item['reporter_phone'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}