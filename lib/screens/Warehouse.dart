import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stock_count_app/components/Button.dart';
import 'package:stock_count_app/components/CustomTextField..dart';
import 'package:stock_count_app/components/FullPageLoader.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/components/QrcodeScanner.dart';
import 'package:stock_count_app/models/ApiResponse.dart';
import 'package:stock_count_app/models/Bin.dart';
import 'package:stock_count_app/models/Location.dart';
import 'package:stock_count_app/models/Model.dart';
import 'package:stock_count_app/models/Sku.dart';
import 'package:stock_count_app/models/Warehouse.dart';
import 'package:stock_count_app/screens/Discrepancies.dart';

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
    'two_way_pallets_count': '',
    'four_way_pallets_count': '',
    'euro_pallets_count': '',
    'extras': '',
    'sku_type': ''
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
  final _twoWayCountController = TextEditingController();
  final _fourWayCountController = TextEditingController();
  final _euroCountController = TextEditingController();
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
    if (currentSection == 5) {
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
        currentSectionTitle = "Please select count type";
      });
    }
    if (currentSection == 4) {
      if (formData['sku_type'] == "") {
        showAlert(context, "Please select SKU");
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

    formData['two_way_pallets_count'] = _twoWayCountController.text;
    formData['four_way_pallets_count'] = _fourWayCountController.text;
    formData['euro_pallets_count'] = _euroCountController.text;

    formData['extras'] = _extrasController.text;
    if (formData['extras'] == "" || formData['sku_id'] == "") {
      showAlert(context, "Kindly complete all fields");
      return;
    }

// CHECKS FOR FG
    if (formData['sku_type'] == 'FG') {
      if (formData['pallet_count'] == "" ||
          formData['two_way_pallets_count'] == "" ||
          formData['four_way_pallets_count'] == "" ||
          formData['euro_pallets_count'] == "") {
        showAlert(context, "Kindly complete all fields");
        return;
      }

      var palletCountNumber = int.tryParse(formData['pallet_count']!);
      var twoWayPallet = int.tryParse(formData['two_way_pallets_count']!);
      var fourWayPallet = int.tryParse(formData['four_way_pallets_count']!);
      var euroPalletCount = int.tryParse(formData['euro_pallets_count']!);

      if (palletCountNumber == null ||
          twoWayPallet == null ||
          fourWayPallet == null ||
          euroPalletCount == null) {
        showAlert(context, "Kindly enter valid counts");
        return;
      }

      if (palletCountNumber !=
          (twoWayPallet + fourWayPallet + euroPalletCount)) {
        showAlert(context,
            "Pallet count does not match the sum of 2-way, 4-way and Euro pallets");
        return;
      }
    } else if (formData['sku_type'] == 'NFG') {
      formData['pallet_count'] = "0";
      formData['two_way_pallets_count'] = "0";
      formData['four_way_pallets_count'] = "0";
      formData['euro_pallets_count'] = "0";
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
      showAlert(context, "Welldone, stock count save successfully",
          title: "Success", callback: () {
        checkForDiscrepancies();
      });
    } else if (response != null && response.message != "") {
      showAlert(context, response.message);
    } else {
      showAlert(context, "Something went wrong");
    }
    setState(() {
      formData['sku_id'] = "";
      formData['pallet_count'] = "";
      formData['two_way_pallets_count'] = "";
      formData['four_way_pallets_count'] = "";
      formData['euro_pallets_count'] = "";
      formData['extras'] = "";
    });
    _extrasController.clear();
    _palletCountController.clear();
    _twoWayCountController.clear();
    _fourWayCountController.clear();
    _euroCountController.clear();
  }

  checkForDiscrepancies() async {
    var response = await Api.instance.getDiscrepancies();
    if (response == null) {
      return;
    }

    print(response['data']['discrepancies']);
    if (response['data']['discrepancies'] != null &&
        response['data']['discrepancies'].length > 0) {
      Fluttertoast.showToast(
        msg:
            "There are ${response['data']['discrepancies'].length} discrepancies in the records",
        toastLength: Toast.LENGTH_LONG,
      );
    }
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
                //SELECT SKU TYPE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => {
                        setState(() {
                          formData['sku_type'] = "FG";
                        }),
                        _nextSection()
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black12,
                        ),
                        child: const Text(
                          "Count SKU",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => {
                        setState(() {
                          formData['sku_type'] = "NFG";
                        }),
                        _nextSection()
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black12,
                        ),
                        child: const Text(
                          "Count NFG",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (formData['sku_type'] == "FG")
                  buildSKUForm()
                else
                  buildNFGSKUForm()
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
              if (currentSection != 5)
                Expanded(child: Button(onPressed: _nextSection, text: "Next"))
              else
                Expanded(child: Button(onPressed: submitCount, text: "Submit"))
            ],
          )
        ],
      ),
    );
  }

  Widget buildSKUForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text(
            "SKUs",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        builder: (_, controller) => SkuBottomSheet(
                          skus: skus.data
                              .where((sku) => sku.skuType == "FG")
                              .toList(),
                          selectedSkuId: formData['sku_id'] ?? "",
                          onSkuSelected: (newValue) {
                            setState(() {
                              formData['sku_id'] = newValue;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            formData['sku_id'] == ""
                                ? "Select an SKU"
                                : skus.data
                                    .firstWhere(
                                        (sku) => sku.id == formData['sku_id'])
                                    .name,
                            style: TextStyle(
                              color: formData['sku_id'] == ""
                                  ? Colors.black54
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
              // const SizedBox(width: 8),
              // InkWell(
              // onTap: () {
              // print("Scanning barcode");
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => QrcodeScanner(
              //         callback: (result) {
              //           print(result);
              //           print("asdkfsldkksd");
              //         },
              //         text: "Scan SKU Barcode",
              //       ),
              //     ));
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //         horizontal: 12, vertical: 14),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.black12),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: const Icon(Icons.qr_code),
              //   ),
              // )
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Pallet Count",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          CustomTextField.withController(
            controller: _palletCountController,
            borderRadius: 10,
            keyboardType: TextInputType.number,
            hintText: "Please enter pallet count",
          ),
          const SizedBox(height: 10),
          const Text(
            "Cases",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          CustomTextField.withController(
            controller: _extrasController,
            borderRadius: 10,
            keyboardType: TextInputType.number,
            hintText: "Please enter any cases",
          ),
          const SizedBox(height: 10),
          const Text(
            "2-Way Pallet Count",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          CustomTextField.withController(
            controller: _twoWayCountController,
            borderRadius: 10,
            keyboardType: TextInputType.number,
            hintText: "Please enter the 2-way pallet count",
          ),
          const SizedBox(height: 10),
          const Text(
            "4-Way Pallet Count",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          CustomTextField.withController(
            controller: _fourWayCountController,
            borderRadius: 10,
            keyboardType: TextInputType.number,
            hintText: "Please enter the 4-way pallet count",
          ),
          const SizedBox(height: 10),
          const Text(
            "Euro Pallet Count",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          CustomTextField.withController(
            controller: _euroCountController,
            borderRadius: 10,
            keyboardType: TextInputType.number,
            hintText: "Please enter the euro pallet count",
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget buildNFGSKUForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text(
            "SKUs (NFG)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        builder: (_, controller) => SkuBottomSheet(
                          skus: skus.data
                              .where((sku) => sku.skuType == "NFG")
                              .toList(),
                          selectedSkuId: formData['sku_id'] ?? "",
                          onSkuSelected: (newValue) {
                            setState(() {
                              formData['sku_id'] = newValue;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            formData['sku_id'] == ""
                                ? "Select an SKU"
                                : skus.data
                                    .firstWhere(
                                        (sku) => sku.id == formData['sku_id'])
                                    .name,
                            style: TextStyle(
                              color: formData['sku_id'] == ""
                                  ? Colors.black54
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Cases",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          CustomTextField.withController(
            controller: _extrasController,
            borderRadius: 10,
            keyboardType: TextInputType.number,
            hintText: "Please enter any cases",
          ),
          const SizedBox(height: 10),
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

class SkuBottomSheet extends StatefulWidget {
  final List<Sku> skus;
  final String selectedSkuId;
  final Function(String) onSkuSelected;

  const SkuBottomSheet({
    required this.skus,
    required this.selectedSkuId,
    required this.onSkuSelected,
  });

  @override
  State<SkuBottomSheet> createState() => _SkuBottomSheetState();
}

class _SkuBottomSheetState extends State<SkuBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Sku> filteredSkus = [];

  @override
  void initState() {
    super.initState();
    filteredSkus = widget.skus;
  }

  void _filterSkus(String query) {
    setState(() {
      filteredSkus = widget.skus
          .where((sku) => sku.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select SKU",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search TextField
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search SKUs...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: _filterSkus,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterSkus('');
                    },
                    color: Colors.grey[600],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredSkus.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No SKUs found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredSkus.length,
                    itemBuilder: (context, index) {
                      final sku = filteredSkus[index];
                      final isSelected = sku.id == widget.selectedSkuId;

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                        ),
                        child: ListTile(
                          title: Text(sku.name),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.blue)
                              : null,
                          onTap: () {
                            widget.onSkuSelected(sku.id);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
