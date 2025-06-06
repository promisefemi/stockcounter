import 'package:flutter/material.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/models/ApiResponse.dart';
import 'package:stock_count_app/models/Bin.dart';
import 'package:stock_count_app/models/Location.dart';
import 'package:stock_count_app/models/Sku.dart';

import 'package:stock_count_app/util/constant.dart' as constant;

import '../api/api.dart';
import '../models/User.dart';
import '../util/shared_preference_helper.dart';

class DiscrepancyPage extends StatefulWidget {
  const DiscrepancyPage({super.key});
  static const routeName = "/DiscrepancyPage";

  @override
  State<DiscrepancyPage> createState() => _DiscrepancyPageState();
}

class _DiscrepancyPageState extends State<DiscrepancyPage> {
  int currentSection = 1;
  User user = User();
  bool pageLoading = false;
  List discrepancies = [];

  @override
  void initState() {
    super.initState();
    _handleInitData();
  }

  _handleInitData() async {
    setState(() {
      pageLoading = true;
    });
    final prefs = await SharedPreferencesHelper.getInstance();
    var userMap = prefs.getMap(constant.userKey);
    if (userMap != null) {
      var response = await Api.instance.getDiscrepancies();
      if (response == null) {
        return;
      }

      if (response['data']['discrepancies'] != null) {
        setState(() {
          user = User.fromJson(userMap);
          discrepancies = response['data']['discrepancies'] as List;
          pageLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      appBar: AppBar(
        title: const Text(
          "Discrepancies",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        backgroundColor: constant.primaryColor,
      ),
      child: pageLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(31, 156, 156, 156),
                      borderRadius: BorderRadius.circular(5)),
                  child: ListTile(
                    title: Text(
                      discrepancies[index]['sku_name'],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Team: ${discrepancies[index]['team_name']}"),
                        Text("Bin: ${discrepancies[index]['bin_name']}"),
                        Text(
                            "Resolved: ${discrepancies[index]['resolved'] == '0' ? 'NO' : 'YES'}"),
                        Text(
                            "Pallet discrepancy amount: ${discrepancies[index]['pallet_discrepancy_amount']}"),
                        Text(
                            "Extras discrepancy amount: ${discrepancies[index]['extras_discrepancy_amount']}"),
                      ],
                    ),
                  ),
                );
              },
              itemCount: discrepancies.length,
            ),
    );
  }
}
