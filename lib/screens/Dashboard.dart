import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:stock_count_app/components/Button.dart';
import 'package:stock_count_app/components/SKUName.dart';
import 'package:stock_count_app/screens/Discrepancies.dart';
import 'package:stock_count_app/screens/History.dart';
import 'package:stock_count_app/screens/Settings.dart';

import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:stock_count_app/util/dialog.dart';
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
  bool showDiscrepancyButton = false;
  bool showCertifyButton = true;
  List history = [];

  @override
  void initState() {
    super.initState();

    _handleInitData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Perform your first-time load operations here
    print('Widget just loaded for the first time');
  }

  _handleInitData() async {
    final prefs = await SharedPreferencesHelper.getInstance();
    var userMap = prefs.getMap(constant.userKey);
    if (userMap != null) {
      setState(() {
        user = User.fromJson(userMap);
      });
      _getDashboard();
      checkForDiscrepancies();
      checkForUserTeamCountingStatus();
    }
  }

  _getDashboard() async {
    setState(() {
      loadingHistory = true;
    });
    var response = await Api.instance.getDashboard(user.id);
    // var response = await Api.instance.getDashboard(");
    setState(() {
      loadingHistory = false;
    });

    print("===== === === === === =====");
    print(response);
    print("===== === === === === =====");

    if (response == null) {
      return;
    }

    if (response['status'] == false) {
      // showAlert(context, response['message']);
      return;
    }

    if (response['data'].containsKey("total_sku_count")) {
      int totalCount = response['data']['total_sku_count'];
      setState(() {
        totalSKUcount = totalCount;
      });
    }

    if (response['data'].containsKey("history")) {
      var countSummary = response['data']['history'] as List;
      setState(() {
        history = countSummary;
      });
    }
  }

  checkForDiscrepancies() async {
    var response = await Api.instance.getDiscrepancies(user.id);
    if (response == null) {
      return;
    }
    print("DESCREPANCY");
    print("DESCREPANCY TD");

    print(response);
    if (response['data']['discrepancies'] != null &&
        response['data']['discrepancies'].length > 0) {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg:
              "There are ${response['data']['discrepancies'].length} discrepancies in the records",
          toastLength: Toast.LENGTH_LONG,
        );
      }
      setState(() {
        showDiscrepancyButton = true;
      });
    } else {
      setState(() {
        showDiscrepancyButton = false;
      });
    }
  }

  checkForUserTeamCountingStatus() async {
    var response = await Api.instance.checkUserCompletedCount(user.id);
    if (response == null) {
      return;
    }

    if (response['status']) {
      setState(() {
        showCertifyButton = false;
      });
    } else {
      setState(() {
        showCertifyButton = true;
      });
    }
  }

  initiatefinalizeCount() async {
    showAlert(context, AlertState.error,
        "Once finalized, you will not be able to make any further changes to the counts.",
        title: "Are you sure you want to finalize?",
        okText: "Finalize",
        showCancel: true, okCallback: () async {
      showFullPageLoader(context);
      var response = await Api.instance.finalizeCount(user.id);
      Navigator.of(context).pop();
      if (response == null) {
        return;
      }

      print(response);
      if (response['status']) {
        showAlert(context, AlertState.success, response['message']);
      } else {
        showAlert(context, AlertState.error, response['message']);
      }
    });
  }

  _checkForActiveTeamCountingSession() async {
    showFullPageLoader(context);

    var response = await Api.instance.fetchActiveTeamCounting(user.id);
    print("clicking");

    Navigator.pop(context);

    if (response == null) {
      return;
    }

    print(response.toJson());
    if (!response.status) {
      if (mounted) {
        showAlert(context, AlertState.error, response.message);
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return WarehousePage(
          teamId: response.data.teamId,
          countingExerciseId: response.data.countingExcerciseId,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      _getDashboard();
    }
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Color.fromRGBO(237, 80, 86, 1),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(HistoryPage.routeName);
                          },
                          icon: const Icon(
                            Icons.refresh,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(Settings.routeName);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    user.fullName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    user.username,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(width: 5),
                              const CircleAvatar(
                                radius: 25.0,
                                child: Icon(Icons.person, size: 40),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 140,
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
                                  NumberFormat("#,##0").format(totalSKUcount),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 25),
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
                          child: Container(
                            child: GestureDetector(
                              onTap: _checkForActiveTeamCountingSession,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (showDiscrepancyButton)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(DiscrepancyPage.routeName);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromARGB(255, 249, 49, 56),
                                ),
                                child: const Text(
                                  "See discrepancy list",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Daily count",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                _getDashboard();
                                checkForDiscrepancies();
                              },
                              child: const Text(
                                "Refresh",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ))
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
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 70, left: 40, right: 40),
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 37,
                                  child: Icon(Icons.inbox, size: 35),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "You have no counts yet",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                    textAlign: TextAlign.center,
                                    "Start a new count by the 'New Count' button or review your history"),
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: 200,
                                  child: Button(
                                    text: "See History",
                                    style: constant.buttonSecondary,
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed(HistoryPage.routeName);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      else ...[
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _handleInitData();
                            },
                            child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  31, 156, 156, 156),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return WarehousePage(
                                                  countingExerciseId: history[
                                                          index]
                                                      ['counting_exercise_id'],
                                                  teamId: history[index]
                                                      ['team_id'],
                                                  bin_id: history[index]
                                                      ['bin_id'],
                                                  sku_id: history[index]
                                                      ['sku_id'],
                                                  count_type: history[index]
                                                      ['count_type'],
                                                );
                                              }));
                                            },
                                            title: SKUName(
                                                name: history[index]
                                                    ['sku_name'],
                                                countType: history[index]
                                                    ['count_type']),
                                            // Text(
                                            //   history[index]['sku_name'],
                                            //   style: TextStyle(
                                            //       fontWeight: FontWeight.w700),
                                            // ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "Team: ${history[index]['team_name']}"),
                                                Text(
                                                    "Bin: ${history[index]['bin_name']}"),
                                                Text(
                                                    "Couting Area: ${history[index]['warehouse_name']}"),
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
                                    if (showCertifyButton)
                                      Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          width: double.infinity,
                                          child: Button(
                                              onPressed: initiatefinalizeCount,
                                              text: "Certify Counts")),
                                  ]),
                            ),
                          ),
                        ),
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
