import 'package:flutter/material.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/models/Warehouse.dart';

import 'package:stock_count_app/util/constant.dart' as constant;

import '../api/api.dart';
import '../models/User.dart';
import '../util/shared_preference_helper.dart';

class Warehouse extends StatefulWidget {
  const Warehouse({super.key});
  static const routeName = "/warehouse";

  @override
  State<Warehouse> createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse> {
  bool loadingHistory = false;
  String currentSectionTitle = "";
  User user = User();
  Map<String, dynamic> warehouse = {
    'loading': false,
    'data': WarehouseList(),
  };
  Map<String, dynamic> location = {
    'loading': false,
    'data': WarehouseList(),
  };

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

  @override
  Widget build(BuildContext context) {
    return Layout(
      appBar: AppBar(
        title: Text(currentSectionTitle),
        foregroundColor: Colors.white,
        backgroundColor: constant.primaryColor,
      ),
      child: Container(),
    );
  }
}

class WarehouseCard extends StatelessWidget {
  const WarehouseCard({
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
