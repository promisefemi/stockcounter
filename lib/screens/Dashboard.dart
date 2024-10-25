import 'package:flutter/material.dart';
import 'package:stock_count_app/screens/Settings.dart';

import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:stock_count_app/util/util.dart';

import '../api/api.dart';
import '../components/Layout.dart';
import '../models/User.dart';
import '../util/shared_preference_helper.dart';
import 'Warehouse.dart';

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
  int totalSKUcount = 0;

  List history = [];

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

      var response = await Api.instance.getDashboard(user.id);
      // var response = await Api.instance.getDashboard(");
      setState(() {
        loadingHistory = false;
      });

      print(response);
      if (response == null) {
        showAlert(context, "an Error Occured");
        return;
      }

      if (response['data']["countSummary"] != null) {
        var countSummary = response['data']['countSummary'] as List;

        print(countSummary);
        var preTotalCount = 0;

        countSummary.forEach((cs) {
          var number = int.tryParse(cs['total_sku_count']);
          if (number != null) {
            preTotalCount += number;
          }
        });

        setState(() {
          totalSKUcount = preTotalCount;
        });
      }

      if (response['data']["countDetails"] != null) {
        setState(() {
          history = response['data']["countDetails"] as List;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 10, left: 20, bottom: 20, right: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(Settings.routeName);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  user.username,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ]),
                          const SizedBox(width: 5),
                          CircleAvatar(
                            radius: 25.0,
                            child: Icon(Icons.person, size: 40),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  totalSKUcount.toString(),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 35),
                                ),
                                const Text(
                                  "Total SKU Count",
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              print("clicking");
                              Navigator.of(context)
                                  .pushNamed(WarehousePage.routeName);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 30),
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
                                      color: Color.fromRGBO(237, 80, 86, 1),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 35,
                                          weight: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    "New Count",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // SECOND SECTION
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            " History",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {},
                          //   child: const Text("View all"),
                          // ),
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
                      else if (!loadingHistory && history.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("No History to show"),
                        )
                      else ...[
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(31, 156, 156, 156),
                                    borderRadius: BorderRadius.circular(5)),
                                child: ListTile(
                                  title: Text(
                                    history[index]['sku_name'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Team: ${history[index]['team_name']}"),
                                      Text(
                                          "Bin: ${history[index]['bin_name']}"),
                                      Text(
                                          "Warehouse: ${history[index]['warehouse_name']}"),
                                    ],
                                  ),
                                  trailing: Text(
                                    history[index]['total_sku_cases'],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: history.length,
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
