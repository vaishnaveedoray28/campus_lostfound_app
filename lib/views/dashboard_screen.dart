import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/user_model.dart';
import 'auth_screen.dart'; 
import 'lost_form_screen.dart';
import 'found_feed_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  int currentPoints = 0;
  List<dynamic> myReports = [];

  final String getOwnerUpdatesUrl = "http://10.0.2.2/lost_found_api/get_owner_updates.php";
  final String deleteItemUrl = "http://10.0.2.2/lost_found_api/delete_item.php";

  @override
  void initState() {
    super.initState();
    currentPoints = widget.user.points;
    _refreshDashboardData();
  }

  Future<void> _refreshDashboardData() async {
    setState(() { isLoading = true; });
    try {
      
      final response = await http.get(Uri.parse("$getOwnerUpdatesUrl?reporter_id=${widget.user.id}"));
      final responseData = jsonDecode(response.body);

      List<dynamic> fetchedReports = [];
      int updatedPoints = currentPoints;

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        fetchedReports = responseData['updates'] ?? [];
        
       
        if (responseData['current_points'] != null) {
          updatedPoints = responseData['current_points'] is String
              ? int.parse(responseData['current_points'])
              : responseData['current_points'];
        }
      }

      setState(() {
        myReports = fetchedReports;
        currentPoints = updatedPoints; 
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _deleteReport(int itemId) async {
    try {
      final response = await http.post(
        Uri.parse(deleteItemUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "item_id": itemId,
          "reporter_id": widget.user.id,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🗑️ Report deleted successfully!"), backgroundColor: Colors.redAccent),
        );
        _refreshDashboardData(); 
      }
    } catch (e) {
    
    }
  }

  String _generateCouponCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _showCouponDialog(String drinkName, int cost) {
    final String claimCode = _generateCouponCode();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.confirmation_number_outlined, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text("Claim $drinkName", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Show this verification code to the vendor lounge counter to receive your drink:",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                claimCode,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4, color: Color(0xFF1E3A8A)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Cost: $cost Points will be deducted upon confirmation.",
              style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context); 
              _finalizeRedemption(drinkName, cost);
            },
            child: const Text("Use & Deduct Points"),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeRedemption(String drinkName, int cost) async {
    if (currentPoints >= cost) {
      try {
        
        final response = await http.get(Uri.parse("$getOwnerUpdatesUrl?reporter_id=${widget.user.id}&deduct_points=$cost"));
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['status'] == 'success') {
          setState(() {
            currentPoints = responseData['current_points'] is String
                ? int.parse(responseData['current_points'])
                : responseData['current_points'];
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("🎉 Points deducted from DB! Enjoy your free $drinkName."),
              backgroundColor: Colors.green,
            ),
          );
          _refreshDashboardData(); 
        }
      } catch (e) {

        setState(() { currentPoints -= cost; });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Insufficient points! Coupon is invalid."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out of the campus hub?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
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
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshDashboardData, tooltip: "Refresh Data"),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _showLogoutDialog, tooltip: "Logout Profile"),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboardData,
        color: const Color(0xFF1E3A8A),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28, 
                            backgroundColor: Colors.white.withOpacity(0.2), 
                            child: const Icon(Icons.person, color: Colors.white, size: 30)
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome back, 👋", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                              Text(widget.user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.amber, size: 22),
                              const SizedBox(width: 6),
                              Text("$currentPoints Pts", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text("Redeem Free Drink 🥤"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Your balance: $currentPoints Points\n"),
                                      const Text("Choose a drink to claim for 50 Points:"),
                                      const SizedBox(height: 12),
                                      ListTile(
                                        leading: const Icon(Icons.coffee, color: Colors.brown),
                                        title: const Text("Iced Milo (50 pts)"),
                                        onTap: () { Navigator.pop(context); _showCouponDialog("Iced Milo", 50); },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.local_drink, color: Colors.orange),
                                        title: const Text("Fruit Juice (50 pts)"),
                                        onTap: () { Navigator.pop(context); _showCouponDialog("Fruit Juice", 50); },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            icon: const Icon(Icons.local_drink_rounded, size: 14, color: Color(0xFF1E3A8A)),
                            label: const Text("Redeem", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => LostFormScreen(user: widget.user)));
                        _refreshDashboardData();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(20)),
                        child: const Column(children: [Icon(Icons.error_outline_rounded, color: Colors.red, size: 32), SizedBox(height: 8), Text("I Lost Something", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => FoundFeedScreen(user: widget.user)));
                        _refreshDashboardData();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)),
                        child: const Column(children: [Icon(Icons.verified_user_outlined, color: Colors.green, size: 32), SizedBox(height: 8), Text("I Found Something", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text("Your Lost Reports Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
                  : myReports.isEmpty
                      ? const Card(child: Padding(padding: EdgeInsets.all(24.0), child: Center(child: Text("No items reported yet."))))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: myReports.length,
                          itemBuilder: (context, index) {
                            final item = myReports[index];
                            final bool isItemFound = item['status'] == 'Found' || item['status'] == 'Claimed';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['item_name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text("Location: ${item['place'] ?? 'N/A'}", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                        if (isItemFound && item['finder_name'] != null) ...[
                                          const SizedBox(height: 6),
                                          Text("Found by: ${item['finder_name']} (📞 ${item['finder_phone'] ?? 'N/A'})", style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 12)),
                                        ]
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(color: isItemFound ? Colors.green[50] : Colors.amber[50], borderRadius: BorderRadius.circular(8)),
                                          child: Text(
                                            isItemFound ? "FOUND" : "MISSING",
                                            style: TextStyle(color: isItemFound ? Colors.green : Colors.amber[800], fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                          onPressed: () => _deleteReport(int.parse(item['id'].toString())),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}