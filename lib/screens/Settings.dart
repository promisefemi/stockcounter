import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stock_count_app/api/api.dart';
import 'package:stock_count_app/components/Button.dart';
import 'package:stock_count_app/components/CustomTextField.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/components/UpdatePassword.dart';
import 'package:stock_count_app/models/User.dart';
import 'package:stock_count_app/screens/Login.dart';
import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:stock_count_app/util/dialog.dart';
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

  String oldPassword = "";
  String newPassword = "";
  String confirmPassword = "";
  bool _passwordResetLoading = false;

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

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

  _handleChangePassword() {
    print('Change password tapped');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UpdatePassword(),
    );
  }

  logout() async {
    final prefs = await SharedPreferencesHelper.getInstance();

    showAlert(context, AlertState.warning, "Are you sure you want to logout",
        title: "Log out", okCallback: () async {
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
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            Container(
              // padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.key_rounded,
                  color: Colors.black,
                ),
                title: const Text(
                  "Change Password",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: _handleChangePassword,
              ),
            ),
            const SizedBox(height: 10),
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
