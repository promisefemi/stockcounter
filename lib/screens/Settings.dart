import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/models/User.dart';
import 'package:stock_count_app/screens/Login.dart';
import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:stock_count_app/util/shared_preference_helper.dart';
import 'package:stock_count_app/util/util.dart';

class Settings extends StatefulWidget {
  Settings({super.key});
  static const routeName = "/settings";

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final List<Map<String, dynamic>> settingsItems = [
    // {
    //   "name": "Profile Update",
    //   "subtitle": "Update your profile information.",
    //   "icon": Icons.person_outline_rounded,
    //   "ontap": (context) {
    //     Navigator.pushNamed(context, ProfileUpdate.routeName);
    //   }
    // },
    // {
    //   "name": "Change Password",
    //   "subtitle": "Manage your password",
    //   "icon": Icons.lock_outline_rounded,
    //   "ontap": (context) {}
    // },
  ];
  User user = User();

  @override
  void initState() {
    super.initState();
    _handleInitData();
  }

  _handleInitData() async {
    final prefs = await SharedPreferencesHelper.getInstance();
    var userMap = prefs.getMap(constant.userKey);
    if (userMap != null) {
      setState(() {
        user = User.fromJson(userMap);
      });
    }
  }

  logout() async {
    final prefs = await SharedPreferencesHelper.getInstance();

    showAlert(context, "Are you sure you want to logout", title: "Log out",
        callback: () async {
      await prefs.remove(constant.apiKey);
      await prefs.remove(constant.userKey);

      // Navigator.pushReplacementNamed(context, LoginPage.routeName);
      Navigator.pushNamedAndRemoveUntil(
          context, LoginPage.routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        backgroundColor: constant.primaryColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  constant.primaryColor,
                  constant.primaryColor,
                ]),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("assets/images/user.png"),

                    backgroundColor: Colors.grey[200], // Fallback color
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.fullName} ",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${user.phone}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Username: ${user.username}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.logout_outlined,
                  color: Colors.red[700],
                ),
                title: Text(
                  "Log out",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[900],
                  ),
                ),
                onTap: logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
