import 'package:flutter/material.dart';
import 'package:stock_count_app/components/Button.dart';
import 'package:stock_count_app/components/CustomTextField..dart';
import 'package:stock_count_app/components/FullPageLoader.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/models/ApiResponse.dart';
import 'package:stock_count_app/models/Bin.dart';
import 'package:stock_count_app/models/Location.dart';
import 'package:stock_count_app/models/Model.dart';
import 'package:stock_count_app/models/Sku.dart';
import 'package:stock_count_app/models/Warehouse.dart';

import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:stock_count_app/util/util.dart';

import '../api/api.dart';
import '../models/User.dart';
import '../util/shared_preference_helper.dart';

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});
  static const routeName = "/WarehousePage";

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
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
    'selected': Warehouse()
  };
  Map<String, dynamic> location = {
    'loading': false,
    'data': LocationList(),
    'selected': Location()
  };
  Map<String, dynamic> bins = {
    'loading': false,
    'data': BinList(),
    'selected': Bin()
  };
  final PageController _pageViewController = PageController(initialPage: 0);
  final _palletCountController = TextEditingController();
  final _extrasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _handleInitData();
  }

  _handleInitData() async {
    final prefs = await SharedPreferencesHelper.getInstance();
    var userMap = prefs.getMap(constant.userKey);
    print(userMap);
    if (userMap != null) {
      setState(() {
        user = User.fromJson(userMap);
        formData['team_id'] = user.team!.teamId;
        formData['user_id'] = user.id;
        formData['counting_exercise_id'] = user.team!.countingExcerciseId;
        currentSectionTitle = "Select a warehouse";
      });

      _fetchWarehousePages();
      _fetchSkus();
    }
  }

  _fetchSkus() async {
    ApiResponse<SkuList>? response = await Api.instance.fetchSKUs();
    print("SKU $response");
    if (response != null && response.statusCode == 200) {
      setState(() {
        skus = response.data;
      });
    }
  }

  _fetchWarehousePages() async {
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
    // if (location['data'].data.length > 0) return;

    setState(() {
      location['loading'] = true;
    });
    ApiResponse<LocationList>? response =
        await Api.instance.fetchWarehouseLocations(warehouse['selected'].id);
    if (response != null && response.statusCode == 200) {
      setState(() {
        location['data'] = response.data;
        location['loading'] = false;
      });
    }
  }

  _fetchBins() async {
    // if (bins['data'].data.length > 0) return;

    setState(() {
      bins['loading'] = true;
    });
    ApiResponse<BinList>? response =
        await Api.instance.fetchBins(location['selected'].id);
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

    if (currentSection == 2) {
      currentSectionTitle = "Kindly select warehouse";
    } else if (currentSection == 3) {
      currentSectionTitle = "Kindly select location";
    } else if (currentSection == 4) {
      currentSectionTitle = "Kindly select bin";
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
      if (warehouse['selected'].id == '') {
        showAlert(context, "Please select Warehouse");
        return;
      }

      setState(() {
        currentSectionTitle = "Kindly select location";
      });
      _fetchLocations();
    }
    if (currentSection == 2) {
      if (location['selected'].id == '') {
        showAlert(context, "Please select location");
        return;
      }
      setState(() {
        currentSectionTitle = "Kindly select bin";
      });
      _fetchBins();
    }
    if (currentSection == 3) {
      if (bins['selected'].id == '') {
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

  submitCount() async {
    formData['pallet_count'] = _palletCountController.text;
    formData['extras'] = _extrasController.text;
    if (formData['pallet_count'] == "" ||
        formData['extras'] == "" ||
        formData['sku_id'] == "") {
      showAlert(context, "Kindly complete all fields");
      return;
    }

    formData['bin_id'] = bins['selected'].id;

    print(formData);
    showDialog(
      context: context,
      builder: (context) {
        return const FullPageLoader();
      },
    );

    ApiResponse<Sku>? response = await Api.instance.submitCount(formData);
    Navigator.of(context).pop();
    if (response != null && response.statusCode == 201) {
      print(response.toJson());

      showAlert(context, "Welldone, stock count save successfully",
          title: "Success");
    } else if (response != null && response.message != "") {
      showAlert(context, response.message);
    } else {
      showAlert(context, "Something went wrong");
    }
    setState(() {
      formData['sku_id'] = "";
      formData['pallet_count'] = "";
      formData['extras'] = "";
    });
    _extrasController.clear();
    _palletCountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      appBar: AppBar(
        title: Text(
          currentSectionTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        backgroundColor: constant.primaryColor,
      ),
      child: Column(
        children: [
          if (warehouse['selected'].id != "" ||
              location['selected'].id != "" ||
              bins['selected'].id != "")
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black12),
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (warehouse['selected'].id != "")
                    Text(
                      "Selected Warehouse: ${warehouse['selected'].name}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  if (location['selected'].id != "")
                    Text(
                      "Selected Location: ${location['selected'].name}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  if (bins['selected'].id != "")
                    Text(
                      "Selected Bin: ${bins['selected'].name}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    )
                ],
              ),
            ),
          Expanded(
            child: PageView(
              controller: _pageViewController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                WarehousePageList(
                  loading: warehouse['loading'],
                  list: warehouse['data'].data,
                  selected: warehouse['selected'],
                  selectMethod: (index) {
                    setState(() {
                      warehouse['selected'] = warehouse['data'].data[index];
                    });
                  },
                ),
                LocationPageList(
                  loading: location['loading'],
                  list: location['data'].data,
                  selected: location['selected'],
                  selectMethod: (index) {
                    setState(() {
                      location['selected'] = location['data'].data[index];
                    });
                  },
                ),
                BinPageList(
                  loading: bins['loading'],
                  list: bins['data'].data,
                  selected: bins['selected'],
                  selectMethod: (index) {
                    setState(() {
                      bins['selected'] = bins['data'].data[index];
                    });
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "SKUs",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    skus.data.length < 1
                        ? CircularProgressIndicator()
                        : DropdownButton<String>(
                            value: formData['sku_id'] == ""
                                ? null
                                : formData['sku_id'],
                            hint: Text("Select an SKU"),
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(10),
                            items: skus.data.map((Sku value) {
                              return DropdownMenuItem<String>(
                                value: value.id,
                                child: Text(value.name),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  formData['sku_id'] = newValue;
                                });
                              }
                            },
                          ),
                    const SizedBox(height: 10),
                    const Text(
                      "Pallet Count",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    CustomTextField.withController(
                      controller: _palletCountController,
                      borderRadius: 10,
                      hintText: "Please enter pallet count",
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Extra",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    CustomTextField.withController(
                      controller: _extrasController,
                      borderRadius: 10,
                      hintText: "Please enter any extras",
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (currentSection != 1)
                Expanded(
                  child: Button(
                      onPressed: _previousSection,
                      style: constant.buttonSecondary,
                      text: "Previous"),
                ),
              const SizedBox(
                width: 10,
              ),
              if (currentSection != 4)
                Expanded(child: Button(onPressed: _nextSection, text: "Next"))
              else
                Expanded(child: Button(onPressed: submitCount, text: "Submit"))
            ],
          )
        ],
      ),
    );
  }
}

class WarehousePageList extends StatelessWidget {
  const WarehousePageList(
      {super.key,
      required this.loading,
      required this.list,
      required this.selectMethod,
      required this.selected});

  final bool loading;
  final Warehouse selected;
  final List<Warehouse> list;
  final Function selectMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  // padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      list[index].name,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(list[index].description),
                    onTap: () => selectMethod(index),
                    trailing: selected.id == list[index].id
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : null,
                  ),
                );
              },
              itemCount: list.length,
            ),
    );
  }
}

class LocationPageList extends StatelessWidget {
  const LocationPageList(
      {super.key,
      required this.loading,
      required this.list,
      required this.selectMethod,
      required this.selected});

  final bool loading;
  final Location selected;
  final List<Location> list;
  final Function selectMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  // padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      list[index].name,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(list[index].description),
                    onTap: () => selectMethod(index),
                    trailing: selected.id == list[index].id
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : null,
                  ),
                );
              },
              itemCount: list.length,
            ),
    );
  }
}

class BinPageList extends StatelessWidget {
  const BinPageList(
      {super.key,
      required this.loading,
      required this.list,
      required this.selectMethod,
      required this.selected});

  final bool loading;
  final Bin selected;
  final List<Bin> list;
  final Function selectMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  // padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      list[index].name,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () => selectMethod(index),
                    trailing: selected.id == list[index].id
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : null,
                  ),
                );
              },
              itemCount: list.length,
            ),
    );
  }
}
