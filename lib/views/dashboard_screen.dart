import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import 'lost_form_screen.dart';
import 'found_feed_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> myReports = [];
  bool isListLoading = true;
  int userPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchMyUpdates();
  }

  Future<void> _fetchMyUpdates() async {
    try {
      final res = await http.get(Uri.parse("http://10.0.2.2/lost_found_api/get_owner_updates.php?user_id=${widget.user.id}"));
      final responseData = jsonDecode(res.body);
      
      if (res.statusCode == 200 && responseData['status'] == 'success') {
        setState(() {
          myReports = responseData['items'];
          userPoints = responseData['user_points'] ?? 0;
          isListLoading = false;
        });
      } else {
        setState(() { isListLoading = false; });
      }
    } catch (e) {
      setState(() { isListLoading = false; });
    }
  }

  void _showRedeemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.card_giftcard_rounded, color: Colors.teal, size: 28),
            SizedBox(width: 12),
            Text("Redeem Campus Rewards", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Balance: $userPoints Points",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15),
            ),
            const SizedBox(height: 12),
            const Text(
              "Convert your earned helper tokens into cafeteria discounts or campus merchandise bundles!",
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.coffee, color: Colors.brown),
              title: const Text("RM5 Cafeteria Voucher", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: userPoints >= 50 ? Colors.green : Colors.grey[300], 
                  foregroundColor: userPoints >= 50 ? Colors.white : Colors.grey[600],
                  elevation: userPoints >= 50 ? 3 : 0,
                ),
                onPressed: userPoints >= 50 ? () {
                  Navigator.pop(context); 
                  
                  showDialog(
                    context: context,
                    barrierDismissible: false, 
                    builder: (innerContext) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      backgroundColor: const Color(0xFFF0FDF4), 
                      title: const Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 60),
                          SizedBox(height: 12),
                          Text(
                            "REDEEM SUCCESSFUL", 
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534), fontSize: 18, letterSpacing: 0.5)
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "🎁 RM5 CAFETERIA VOUCHER",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Please present this live screen container layout to the cafeteria counter vendor to claim your discount.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!, width: 1.5)
                            ),
                            child: const Text(
                              "VOUCHER CODE: UUM-REWARD-50",
                              style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                            ),
                          )
                        ],
                      ),
                      actions: [
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                            ),
                            onPressed: () {
                              
                              Navigator.pop(innerContext);
                              
                              setState(() {
                                userPoints -= 50;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("50 Points deducted. Remaining Balance: $userPoints Pts"),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                            },
                            child: const Text("Close & Deduct", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                } : null, 
                child: const Text("50 Pts"),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
        title: const Text('Sintok Lost & Found Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), 
            onPressed: _fetchMyUpdates,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Logout Session",
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully!"), 
                  backgroundColor: Colors.blueGrey,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back, 👋", 
                              style: TextStyle(color: Colors.teal[100], fontSize: 12, fontWeight: FontWeight.w500)
                            ),
                            Text(
                              widget.user.name, 
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "$userPoints Token Points",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showRedeemDialog,
                        icon: const Icon(Icons.card_giftcard_rounded, size: 16),
                        label: const Text("Redeem Rewards", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal[800],
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LostFormScreen(user: widget.user)),
                      ).then((_) => _fetchMyUpdates());
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2), 
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Icon(Icons.report_gmailerrorred_rounded, size: 36, color: Color(0xFFDC2626)),
                            SizedBox(height: 8),
                            Text("I Lost Something", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                            SizedBox(height: 2),
                            Text("Post missing object info", style: TextStyle(fontSize: 10, color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FoundFeedScreen(user: widget.user)),
                      ).then((_) => _fetchMyUpdates());
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4), 
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.5),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Icon(Icons.security_rounded, size: 36, color: Color(0xFF16A34A)),
                            SizedBox(height: 8),
                            Text("I Found Something", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                            SizedBox(height: 2),
                            Text("Earn points via claims feed", style: TextStyle(fontSize: 10, color: Colors.green)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            const Text(
              "📋 Your Lost Reports Status", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: 0.3)
            ),
            const SizedBox(height: 12),

            isListLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : myReports.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0))
                        ),
                        child: const Center(
                          child: Text(
                            "You haven't reported any lost items yet.", 
                            style: TextStyle(color: Colors.grey, fontSize: 13)
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: myReports.length,
                        itemBuilder: (context, index) {
                          final report = myReports[index];
                          bool isFound = report['status'] == 'Found';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: isFound ? Colors.green[200]! : const Color(0xFFE2E8F0))
                            ),
                            color: isFound ? const Color(0xFFF0FDF4) : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        report['item_name'] ?? 'Item',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isFound ? Colors.green[100] : Colors.orange[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isFound ? "FOUND" : "MISSING",
                                          style: TextStyle(
                                            color: isFound ? Colors.green[800] : Colors.orange[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Location: ${report['place'] ?? 'N/A'}", style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                  const Divider(height: 20),
                                  if (isFound) ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 16, color: Colors.green),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "Contact Finder to retrieve: ${report['color']?.toString().replaceAll('Finder Phone: ', '') ?? 'No Number Provided'}",
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Waiting for helpers to locate your item...", 
                                          style: const TextStyle(color: Colors.black45, fontSize: 13, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}