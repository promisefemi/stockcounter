import 'package:flutter/material.dart';

import 'package:stock_count_app/util/constant.dart' as constant;

import '../api/api.dart';
import '../components/Layout.dart';
import '../models/User.dart';
import '../util/shared_preference_helper.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  static const routeName = "/dashboard";

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool loadingHistory = false;
  int currentLimit = 10;
  User user = User();

  @override
  void initState() {
    super.initState();

    _handleInitData();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (_isFirstLoad) {
  //     _isFirstLoad = false;
  //     // Perform your first-time load operations here
  //     print('Widget just loaded for the first time');
  //   }
  // }

  _handleInitData() async {
    final prefs = await SharedPreferencesHelper.getInstance();
    var userMap = prefs.getMap(constant.userKey);
    if (userMap != null) {
      setState(() {
        user = User.fromJson(userMap);
        loadingHistory = true;
      });

      print(user.toJson());
      setState(() {
        loadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        user.username,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ])
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "20",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 25),
                            ),
                            Text(
                              "Total SKU Count",
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: constant.primaryColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 25,
                                  )
                                ],
                              ),
                            ),
                            const Text(
                              "New Count",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

// SECOND SECTION
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      " History",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("View all"),
                    ),
                  ],
                ),
                if (loadingHistory)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 40,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (!loadingHistory)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("No History to show"),
                  )
                else
                  const SizedBox(
                    height: 10,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.icon,
    required this.colors,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset.fromDirection(12),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(50)),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 23,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
