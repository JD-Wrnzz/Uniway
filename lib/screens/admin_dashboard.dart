import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'group_detail_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> groups = [];
  String search = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 💾 LOAD DATA
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("groups");

    if (data != null) {
      setState(() {
        groups = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> loadMockData() async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> mockGroups = [
      {
        "name": "ADC",
        "ambassadors": [
          {
            "name": "Arun",
            "username": "arun_1023",
            "password": "1234",
            "referral": "ARU5678",
            "count": 20,
          },
          {
            "name": "Divya",
            "username": "divya_2234",
            "password": "5678",
            "referral": "DIV7890",
            "count": 10,
          },
        ],
      },
      {
        "name": "XYS",
        "ambassadors": [
          {
            "name": "Xavier",
            "username": "xavier_8899",
            "password": "4321",
            "referral": "XAV3456",
            "count": 30,
          },
          {
            "name": "Yash",
            "username": "yash_5544",
            "password": "8765",
            "referral": "YAS6789",
            "count": 0,
          },
        ],
      },
      {
        "name": "MNO",
        "ambassadors": [
          {
            "name": "Manoj",
            "username": "manoj_7788",
            "password": "1111",
            "referral": "MAN2345",
            "count": 50,
          },
        ],
      },
      {
        "name": "QRT",
        "ambassadors": [
          {
            "name": "Riya",
            "username": "riya_6677",
            "password": "2222",
            "referral": "RIY9876",
            "count": 20,
          },
          {
            "name": "Tarun",
            "username": "tarun_1122",
            "password": "3333",
            "referral": "TAR4567",
            "count": 10,
          },
        ],
      },
    ];

    await prefs.setString("groups", jsonEncode(mockGroups));

    setState(() {
      groups = mockGroups;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Mock data loaded 🚀")));
  }

  int get totalSignups {
    int total = 0;
    for (var g in groups) {
      for (var a in g["ambassadors"]) {
        total += (a["count"] ?? 0) as int;
      }
    }
    return total;
  }

  Map<String, dynamic>? get topAmbassador {
    Map<String, dynamic>? top;

    for (var g in groups) {
      for (var a in g["ambassadors"]) {
        if (top == null || (a["count"] ?? 0) > (top["count"] ?? 0)) {
          top = a;
        }
      }
    }

    return top;
  }

  // 💾 SAVE DATA
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("groups", jsonEncode(groups));
  }

  int get totalAmbassadors {
    int count = 0;
    for (var g in groups) {
      count += (g["ambassadors"] as List).length;
    }
    return count;
  }

  void addGroup() {
    TextEditingController name = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Create Group"),
        content: TextField(controller: name),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;

              setState(() {
                groups.add({"name": name.text, "ambassadors": []});
              });

              saveData();
              Navigator.pop(context);
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void deleteGroup(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Group"),
        content: Text("Are you sure you want to delete this group?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                groups.removeAt(index);
              });

              saveData(); // 💾 SAVE AFTER DELETE
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filtered = groups
        .where((g) => g["name"].toLowerCase().contains(search))
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Dashboard"),
        actions: [IconButton(onPressed: logout, icon: Icon(Icons.logout))],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: addGroup,
        child: Icon(Icons.add),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC), Color(0xFF00C9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // 🔥 HEADER
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Column(
                      children: [
                        // 🔥 FIRST ROW
                        Row(
                          children: [
                            Expanded(child: statCard("Groups", groups.length)),
                            SizedBox(width: 12),
                            Expanded(
                              child: statCard("Ambassadors", totalAmbassadors),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        // 🔥 SECOND ROW
                        Row(
                          children: [
                            Expanded(child: statCard("Total Signups", 260)),

                            SizedBox(width: 12),

                            Expanded(
                              child: Container(
                                height: 110,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Top Ambassador",
                                      style: TextStyle(color: Colors.white70),
                                    ),

                                    SizedBox(height: 6),

                                    Text(
                                      topAmbassador?["name"] ?? "-",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 4),

                                    Text(
                                      "50 users",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // 🔍 SEARCH
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        onChanged: (v) =>
                            setState(() => search = v.toLowerCase()),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search groups...",
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 BODY
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      var g = filtered[i];

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(
                                group: g,
                                onUpdate: saveData,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  g["name"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),

                              Row(
                                children: [
                                  // 🗑 DELETE BUTTON
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => deleteGroup(i),
                                  ),

                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(String title, int value) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text(
              "$value",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
