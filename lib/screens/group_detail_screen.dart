import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

class GroupDetailScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  final Function onUpdate;

  GroupDetailScreen({required this.group, required this.onUpdate});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  Map<int, bool> showPassword = {};

  String generateUsername(String name) {
    final clean = name.replaceAll(" ", "").toLowerCase();
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return "${clean}_$random";
  }

  String generateReferralCode(String name) {
    final clean = name.replaceAll(" ", "").toUpperCase();

    // ✅ handle short names safely
    final prefix = clean.length >= 3
        ? clean.substring(0, 3)
        : clean.padRight(3, 'X'); // JD → JDX

    final random = Random().nextInt(9000) + 1000;

    return "$prefix$random";
  }

  String generatePassword() {
    return (1000 + Random().nextInt(9000)).toString();
  }

  void addAmbassador() {
    TextEditingController name = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Create Ambassador"),
        content: TextField(
          controller: name,
          decoration: InputDecoration(
            hintText: "Enter name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;

              String user = generateUsername(name.text);
              String pass = generatePassword();

              String ref = generateReferralCode(name.text);

              setState(() {
                widget.group["ambassadors"].add({
                  "name": name.text,
                  "username": user,
                  "password": pass,
                  "referral": ref, // ✅ NEW
                });
              });

              widget.onUpdate(); // 💾 SAVE
              Navigator.pop(context);
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }

  void deleteAmbassador(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Ambassador"),
        content: Text("Are you sure you want to delete this ambassador?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                widget.group["ambassadors"].removeAt(index);
              });

              widget.onUpdate(); // 💾 SAVE
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Copied")));
  }

  @override
  Widget build(BuildContext context) {
    List ambassadors = widget.group["ambassadors"];

    // 🔥 CALCULATIONS
    int totalSignups = 0;
    Map top = {};

    for (var a in ambassadors) {
      int count = a["count"] ?? 0;
      totalSignups += count;

      if (top.isEmpty || count > (top["count"] ?? 0)) {
        top = a;
      }
    }

    // 📊 MOCK GRAPH DATA
    final dates = ["1", "2", "3", "4", "5", "6", "7"];
    final signups = [3, 6, 5, 9, 13, 11, 16];
    final logouts = [1, 2, 2, 3, 4, 3, 5];
    final loss = List.generate(signups.length, (i) => signups[i] - logouts[i]);

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.group["name"]),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: addAmbassador,
        child: Icon(Icons.person_add),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC), Color(0xFF00C9FF)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔥 ANALYTICS HEADER
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ROW 1
                      Row(
                        children: [
                          Expanded(
                            child: statCard("Ambassadors", ambassadors.length),
                          ),
                          SizedBox(width: 12),
                          Expanded(child: statCard("Signups", totalSignups)),
                        ],
                      ),

                      SizedBox(height: 12),

                      // ROW 2
                      Row(
                        children: [
                          Expanded(child: statCard("Top", top["count"] ?? 0)),
                          SizedBox(width: 12),
                          Expanded(
                            child: statCardText("Top Name", top["name"] ?? "-"),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // 📊 GRAPH
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),

                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        dates[value.toInt()],
                                        style: TextStyle(color: Colors.white70),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              lineBarsData: [
                                line(signups, Colors.greenAccent),
                                line(logouts, Colors.redAccent),
                                line(loss, Colors.blueAccent),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔥 LIST BELOW
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ambassadors.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              "No Ambassadors Yet 🚀",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(ambassadors.length, (i) {
                            var a = ambassadors[i];

                            if (a["referral"] == null) {
                              a["referral"] = generateReferralCode(a["name"]);
                              widget.onUpdate();
                            }

                            showPassword[i] ??= false;

                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          a["name"],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => deleteAmbassador(i),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12),

                                  rowItem(
                                    "ID",
                                    a["username"],
                                    () => copy(a["username"]),
                                  ),

                                  SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Password: ${showPassword[i]! ? a["password"] : "••••"}",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              showPassword[i]!
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                showPassword[i] =
                                                    !showPassword[i]!;
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.copy,
                                              color: Colors.white,
                                            ),
                                            onPressed: () =>
                                                copy(a["password"]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 8),

                                  rowItem(
                                    "Referral",
                                    a["referral"],
                                    () => copy(a["referral"]),
                                  ),
                                  SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Signups: ${a["count"] ?? 0}",
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      // OPTIONAL: ICON
                                      Icon(
                                        Icons.trending_up,
                                        color: Colors.greenAccent,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget rowItem(String label, String value, VoidCallback onCopy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$label: $value", style: TextStyle(color: Colors.white70)),
        IconButton(
          icon: Icon(Icons.copy, color: Colors.white),
          onPressed: onCopy,
        ),
      ],
    );
  }
}

Widget statCard(String title, int value) {
  return Container(
    height: 90,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withOpacity(0.2),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(color: Colors.white70)),
        SizedBox(height: 6),
        Text(
          "$value",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget statCardText(String title, String text) {
  return Container(
    height: 90,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withOpacity(0.2),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(color: Colors.white70)),
        SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

LineChartBarData line(List data, Color color) {
  return LineChartBarData(
    isCurved: true,
    barWidth: 3,
    color: color,
    dotData: FlDotData(show: true),
    spots: List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].toDouble()),
    ),
  );
}
