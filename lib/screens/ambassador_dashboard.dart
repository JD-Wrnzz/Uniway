import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class AmbassadorDashboard extends StatelessWidget {
  final Map<String, dynamic> ambassador;
  final String groupName;

  AmbassadorDashboard({required this.ambassador, required this.groupName});

  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 📅 DATE BASED (NO DECIMAL)
    final dates = ["1", "2", "3", "4", "5", "6", "7"];

    final signups = [3, 6, 5, 9, 13, 11, 16];
    final logouts = [1, 2, 2, 3, 4, 3, 5];

    // 🔥 USER LOSS (SIGNUP - LOGOUT)
    final loss = List.generate(signups.length, (i) => signups[i] - logouts[i]);

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Analytics Dashboard"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout),
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC), Color(0xFF00C9FF)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 HEADER
                glassBox(
                  child: Column(
                    children: [
                      Text(
                        "Welcome 👋",
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 8),
                      Text(
                        ambassador["name"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Referral: ${ambassador["referral"]}",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 📊 STATS
                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        "Signups",
                        signups.reduce((a, b) => a + b),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: statCard(
                        "Logouts",
                        logouts.reduce((a, b) => a + b),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: statCard("Loss", loss.reduce((a, b) => a + b)),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // 📈 TITLE
                Text(
                  "Performance Overview",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12),

                // 📊 PROFESSIONAL GRAPH
                glassBox(
                  child: SizedBox(
                    height: 260,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),

                        // ❌ REMOVE SIDE NUMBERS
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
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
                          // 🟢 SIGNUPS
                          LineChartBarData(
                            isCurved: true,
                            barWidth: 3,
                            spots: List.generate(
                              signups.length,
                              (i) =>
                                  FlSpot(i.toDouble(), signups[i].toDouble()),
                            ),
                            color: Colors.greenAccent,
                            dotData: FlDotData(show: true),
                          ),

                          // 🔴 LOGOUTS
                          LineChartBarData(
                            isCurved: true,
                            barWidth: 3,
                            spots: List.generate(
                              logouts.length,
                              (i) =>
                                  FlSpot(i.toDouble(), logouts[i].toDouble()),
                            ),
                            color: Colors.redAccent,
                            dotData: FlDotData(show: true),
                          ),

                          // 🔵 LOSS
                          LineChartBarData(
                            isCurved: true,
                            barWidth: 3,
                            spots: List.generate(
                              loss.length,
                              (i) => FlSpot(i.toDouble(), loss[i].toDouble()),
                            ),
                            color: Colors.blueAccent,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // 📋 ACTIVITY
                Text(
                  "Recent Activity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                glassBox(
                  child: Column(
                    children: List.generate(5, (i) {
                      return ListTile(
                        leading: Icon(
                          Icons.trending_up,
                          color: Colors.greenAccent,
                        ),
                        title: Text(
                          "User ${i + 1}",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "via ${ambassador["referral"]}",
                          style: TextStyle(color: Colors.white70),
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

  // 🔥 GLASS CARD (KEEP YOUR THEME)
  Widget glassBox({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.2),
      ),
      child: child,
    );
  }

  // 🔥 STAT CARD
  Widget statCard(String title, int value) {
    return glassBox(
      child: Column(
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
}
