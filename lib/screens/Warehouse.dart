import 'package:flutter/material.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/models/ApiResponse.dart';
import 'package:stock_count_app/models/Bin.dart';
import 'package:stock_count_app/models/Location.dart';
import 'package:stock_count_app/models/Sku.dart';
import 'package:stock_count_app/models/Warehouse.dart';

import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:stock_count_app/util/util.dart';

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
  int currentSection = 1;
  User user = User();
  SkuList skus = SkuList();
  Map<String, String> formData = {
    'counting_exercise_id': '',
    'team_id': '',
    'user_id': '',
    'bin_id': '',
    'sku_id': '',
    'pallet_count': '',
    'extras': '',
  };
  Map<String, dynamic> warehouse = {
    'loading': false,
    'data': WarehouseList(),
  };
  Map<String, dynamic> location = {
    'loading': false,
    'data': LocationList(),
  };
  Map<String, dynamic> bins = {
    'loading': false,
    'data': BinList(),
  };
  final PageController _pageViewController = PageController(initialPage: 0);
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
        formData['team_id'] = user.team!.teamId;
        formData['user_id'] = user.id;
        formData['counting_exercise_id'] = user.team!.countingExcerciseId;
      });

      _fetchWarehouses();
      _fetchSkus();
    }
  }

  _fetchSkus() async {
    ApiResponse<SkuList>? response = await Api.instance.fetchSKUs();
    if (response != null && response.statusCode == 200) {
      setState(() {
        skus = response.data;
      });
    }
  }

  _fetchWarehouses() async {
    setState(() {
      warehouse['loading'] = true;
    });
    ApiResponse<WarehouseList>? response =
        await Api.instance.fetchWarehouses(user.plant);
    if (response != null && response.statusCode == 200) {
      setState(() {
        warehouse['data'] = response.data;
        warehouse['loading'] = false;
      });
    }
  }

  _fetchLocations() async {
    setState(() {
      location['loading'] = true;
    });
    ApiResponse<LocationList>? response =
        await Api.instance.fetchWarehouseLocations(formData['warehouse_id']!);
    if (response != null && response.statusCode == 200) {
      setState(() {
        location['data'] = response.data;
        location['loading'] = false;
      });
    }
  }

  _fetchBins() async {
    setState(() {
      bins['loading'] = true;
    });
    ApiResponse<BinList>? response =
        await Api.instance.fetchBins(formData['location_id']!);
    if (response != null && response.statusCode == 200) {
      setState(() {
        bins['data'] = response.data;
        bins['loading'] = false;
      });
    }
  }

  _previousSection() {
    if (currentSection == 1) {
      return;
    }
    setState(() {
      currentSection = currentSection - 1;
    });
    _pageViewController.previousPage(
        duration: Durations.short1, curve: Curves.easeIn);
  }

  _nextSection() {
    if (currentSection == 4) {
      return;
    }

    if (currentSection == 1) {
      if (formData['warehouse_id'] == '') {
        showAlert(context, "Please select warehouse");
        return;
      }

      setState(() {
        currentSectionTitle = "Kindly select location";
      });
    }
    if (currentSection == 2) {
      if (formData['location_id'] == '') {
        showAlert(context, "Please select location");
        return;
      }
      setState(() {
        currentSectionTitle = "Kindly select bin";
      });
    }
    if (currentSection == 3) {
      if (formData['bin_id'] == '') {
        showAlert(context, "Please select bin");
        return;
      }
      setState(() {
        currentSectionTitle = "Please complete the form below";
      });
    }

    setState(() {
      currentSection = currentSection + 1;
    });
    _pageViewController.nextPage(
        duration: Durations.short1, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      appBar: AppBar(
        title: Text(currentSectionTitle),
        foregroundColor: Colors.white,
        backgroundColor: constant.primaryColor,
      ),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Container(),
          PageView(
            controller: _pageViewController,
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Container(
                child: warehouse['loading']
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        children: [],
                      ),
              )
            ],
          ),
        ],
      )),
    );
  }
}
