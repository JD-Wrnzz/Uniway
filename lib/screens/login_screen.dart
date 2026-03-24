import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ambassador_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final username = TextEditingController();
  final password = TextEditingController();

  Map<String, String> ambassadors = {"john": "1234", "alex": "abcd"};

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    controller.forward();
    super.initState();
  }

  void login() async {
    String user = username.text.trim();
    String pass = password.text.trim();

    // ✅ ADMIN LOGIN
    if (user == "Uniway" && pass == "j3p") {
      showBottomPopup("Admin Login Success 🚀", Colors.green);

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      });
      return;
    }

    // ✅ LOAD SAVED DATA
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("groups");

    if (data != null) {
      List groups = jsonDecode(data);

      for (var g in groups) {
        for (var a in g["ambassadors"]) {
          if (a["username"] == user && a["password"] == pass) {
            showBottomPopup("Ambassador Login Success 🎉", Colors.blue);

            Future.delayed(Duration(milliseconds: 500), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AmbassadorDashboard(ambassador: a, groupName: g["name"]),
                ),
              );
            });
            return;
          }
        }
      }
    }

    // ❌ INVALID
    showBottomPopup("Invalid Credentials ❌", Colors.red);
  }

  // 🔥 CUSTOM BOTTOM POPUP
  void showBottomPopup(String message, Color color) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300),
            builder: (_, double value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Text(message, style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: controller,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC), Color(0xFF00C9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              width: 320,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Uniway Dashboard",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: username,
                    style: TextStyle(color: Colors.white),
                    decoration: inputStyle("Username"),
                  ),

                  SizedBox(height: 12),

                  TextField(
                    controller: password,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: inputStyle("Password"),
                  ),

                  SizedBox(height: 20),

                  GestureDetector(
                    onTap: login,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [Colors.orange, Colors.red],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
