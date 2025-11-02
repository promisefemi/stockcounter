import 'dart:io';
import 'dart:ui' as BorderType;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stock_count_app/components/Button.dart';
import 'package:stock_count_app/components/CustomTextField.dart';
import 'package:stock_count_app/components/FullPageLoader.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/components/QrcodeScanner.dart';
import 'package:stock_count_app/models/ApiResponse.dart';
import 'package:stock_count_app/models/Bin.dart';
import 'package:stock_count_app/models/Location.dart';
import 'package:stock_count_app/models/Model.dart';
import 'package:stock_count_app/models/Sku.dart';
import 'package:stock_count_app/models/Warehouse.dart';
import 'package:stock_count_app/screens/Dashboard.dart';
import 'package:stock_count_app/screens/Discrepancies.dart';

import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:stock_count_app/util/dialog.dart';
import 'package:stock_count_app/util/util.dart';
import 'package:dotted_border/dotted_border.dart';

import '../api/api.dart';
import '../models/User.dart';
import '../util/shared_preference_helper.dart';

class FormData {
  String countingExerciseId = "";
  String teamId = "";
  String userId = "";
  String binId = "";
  String skuId = "";
  String skuName = "";
  String palletCount = "";
  String extras = "";
  String skuType = "FG";
  String countType = "GOOD";

  Map<String, String> toMap() {
    return {
      'counting_exercise_id': countingExerciseId,
      'team_id': teamId,
      'user_id': userId,
      'bin_id': binId,
      'sku_id': skuId,
      'pallet_count': palletCount,
      'extras': extras,
      'sku_type': skuType,
      'count_type': countType,
    };
  }

  FormData copy() {
    return FormData()
      ..countingExerciseId = countingExerciseId
      ..teamId = teamId
      ..userId = userId
      ..binId = binId
      ..skuId = skuId
      ..skuName = skuName
      ..palletCount = palletCount
      ..extras = extras
      ..countType = countType
      ..skuType = skuType;
  }
}

class WarehousePage extends StatefulWidget {
  const WarehousePage({
    super.key,
    required this.countingExerciseId,
    required this.teamId,
    this.bin_id,
    this.sku_id,
    this.count_type,
  });
  static const routeName = "/WarehousePage";

  final String countingExerciseId;
  final String teamId;
  final String? bin_id;
  final String? sku_id;
  final String? count_type;

  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  bool loadingHistory = false;
  String currentSectionTitle = "";
  int currentSection = 1;
  bool goback = true;
  User user = User();
  SkuList skus = SkuList();
  bool isCreate = true;
  FormData formData = FormData();

  List<FormData> savedFormData = [];

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

  final List<String> options = ["GOOD", "BAD"];
  final PageController _pageViewController = PageController(initialPage: 0);
  final _palletCountController = TextEditingController();
  final _extrasController = TextEditingController();

  String casePerPalletCount = "";
  String totalCaseCount = "";
  @override
  void initState() {
    super.initState();
    _extrasController.addListener(() {
      if (formData.skuType == "FG") {
        print("EXTRAS");
        final extras = int.tryParse(_extrasController.text);
        final casePerPallet = int.tryParse(casePerPalletCount);

        print("NEW EXTRA -- $extras");
        print("NEW CASE -- $casePerPallet");

        if (extras == null || casePerPallet == null) return;
        print("NEW TOTAL CASE --  ${(casePerPallet + extras).toString()}");
        setState(() {
          totalCaseCount = (casePerPallet + extras).toString();
        });
      }
    });
    _palletCountController.addListener(() {
      final skuId = formData.skuId;
      if (skuId == null || skuId.isEmpty) return;

      final selectedSKU = skus.data.firstWhere(
        (e) => e.id == skuId,
      );

      final palletCount = int.tryParse(_palletCountController.text);
      final casePerPallet = int.tryParse(selectedSKU.casePerPallet);
      final extras = int.tryParse(_extrasController.text) ?? 0;

      if (palletCount == null || casePerPallet == null) return;

      // _extrasController.text = (casePerPallet * palletCount).toString();

      setState(() {
        casePerPalletCount = (casePerPallet * palletCount).toString();
        totalCaseCount = ((casePerPallet * palletCount) + extras).toString();
      });
    });

    _handleInitData();
  }

  Sku? selectedSKU() {
    final skuId = formData.skuId;
    if (skuId == null || skuId.isEmpty) return null;
    return skus.data.firstWhere(
      (e) => e.id == skuId,
    );
  }

  _handleInitData() async {
    final prefs = await SharedPreferencesHelper.getInstance();
    var userMap = prefs.getMap(constant.userKey);
    print(userMap);
    if (userMap != null) {
      setState(() {
        user = User.fromJson(userMap);
        formData.teamId = widget.teamId;
        formData.userId = user.id;
        formData.countingExerciseId = widget.countingExerciseId;

        currentSectionTitle = "Select a Counting Area";
      });

      _fetchWarehousePages();
      await _fetchSkus();
      if (widget.sku_id != null && widget.bin_id != null) {
        setState(() {
          formData.skuId = widget.sku_id!;
          formData.binId = widget.bin_id!;
          formData.countType = widget.count_type ?? "GOOD";

          formData.skuType = selectedSKU()?.skuType ?? "";
          currentSection = 3;
          currentSectionTitle = "Please complete the form below";
          goback = false;
          isCreate = false;
        });
        print("FORM ${formData}");
        _pageViewController.animateToPage(
          5,
          duration: Durations.short1,
          curve: Curves.easeIn,
        );
      }
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

  _fetchWarehousePages() async {
    setState(() {
      warehouse['loading'] = true;
    });
    ApiResponse<WarehouseList>? response =
        await Api.instance.fetchWarehouses(widget.countingExerciseId, user.id);
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
        await Api.instance.fetchBins(warehouse['selected'].id);

    print(response);

    if (response != null) {
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
      currentSectionTitle = "Kindly select Counting Area";
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
    if (currentSection == 3) {
      return;
    }

    if (currentSection == 1) {
      if (warehouse['selected'].id == '') {
        showAlert(context, AlertState.info, "Please select Warehouse");
        return;
      }

      setState(() {
        currentSectionTitle = "Kindly select bin";
      });
      _fetchBins();
    }
    // if (currentSection == 2) {
    //   if (location['selected'].id == '') {
    //     showAlert(context, AlertState.info, "Please select location");
    //     return;
    //   }
    //   setState(() {
    //     currentSectionTitle = "Kindly select bin";
    //   });
    //   _fetchBins();
    // }
    if (currentSection == 2) {
      if (bins['selected'].id == '') {
        showAlert(context, AlertState.info, "Please select bin");
        return;
      }
      setState(() {
        currentSectionTitle = "Please complete the form below";
      });
    }
    // if (currentSection == 3) {
    //   if (formData.skuType == "") {
    //     showAlert(context, AlertState.info, "Please select SKU");
    //     return;
    //   }
    //   setState(() {
    //     currentSectionTitle = "Please complete the form below";
    //   });
    // }

    setState(() {
      currentSection = currentSection + 1;
    });
    _pageViewController.nextPage(
        duration: Durations.short1, curve: Curves.easeIn);
  }

  bool validateFormData() {
    formData.palletCount = _palletCountController.text;

    formData.extras = _extrasController.text;

    if (formData.extras == "" || formData.skuId == "") {
      showAlert(context, AlertState.info, "Kindly complete all fields");
      return false;
    }
    var extraCountNumber = int.tryParse(formData.extras!);

// CHECKS FOR FG
    if (formData.skuType == 'FG') {
      if (formData.palletCount == "") {
        showAlert(context, AlertState.info, "Kindly complete all fields");
        return false;
      }

      var palletCountNumber = int.tryParse(formData.palletCount!);

      if (palletCountNumber == null || extraCountNumber == null) {
        showAlert(context, AlertState.error, "Kindly enter valid counts");
        return false;
      }

      if (palletCountNumber == 0 && extraCountNumber == 0) {
        showAlert(context, AlertState.info,
            "Pallet count cannot be 0 if extras is 0");
        return false;
      }
    } else if (formData.skuType == 'NFG') {
      formData.palletCount = "0";

      if (extraCountNumber == null) {
        showAlert(context, AlertState.error, "Kindly enter valid counts");
        return false;
      }
      if (extraCountNumber == 0) {
        showAlert(context, AlertState.info, "Cases cannot be 0");
        return false;
      }
    }

    if (formData.binId == null || formData.binId!.isEmpty) {
      formData.binId = bins['selected'].id;
    }
    return true;
  }

  saveFormCount() {
    if (validateFormData()) {
      var sku = skus.data.firstWhere(
        (e) => e.id == formData.skuId,
      );
      formData.skuName = sku.name;

      savedFormData.add(formData.copy());
      _resetForm();
      Navigator.pop(context);
    }
  }

  submitCount() async {
    print(formData);
    ApiResponse<Sku>? response;
    if (isCreate) {
      if (savedFormData.length <= 0) {
        return;
      }
      List<FormData> finalCounts = [];

      for (var i = 0; i < savedFormData.length; i++) {
        FormData savedItem = savedFormData[i];
        if (finalCounts.isEmpty) {
          finalCounts.add(savedItem.copy());
        } else {
          int index = finalCounts.indexWhere((item) =>
              (item.skuId == savedItem.skuId &&
                  item.countType == savedItem.countType));
          if (index != -1) {
            int? currentFinalPalletCount =
                int.tryParse(finalCounts[index].palletCount);
            int? savedPalletCount = int.tryParse(savedItem.palletCount);

            if (currentFinalPalletCount == null || savedPalletCount == null) {
              showAlert(context, AlertState.error,
                  "kindly enter valid pallet counts");
              return;
            }
            finalCounts[index].palletCount =
                (currentFinalPalletCount + savedPalletCount).toString();

// EXTRAS

            int? currentFinalExtrasCount =
                int.tryParse(finalCounts[index].extras);
            int? savedExtrasCount = int.tryParse(savedItem.extras);

            if (currentFinalExtrasCount == null || savedExtrasCount == null) {
              showAlert(context, AlertState.error, "kindly enter valid extras");
              return;
            }
            finalCounts[index].extras =
                (currentFinalExtrasCount + savedExtrasCount).toString();
          } else {
            finalCounts.add(savedItem.copy());
          }
        }
      }

      List<Map<String, String>> finalList = [];
      for (var i = 0; i < finalCounts.length; i++) {
        finalList.add(finalCounts[i].toMap());
      }
      // print(finalList);
      // return;
      // print(finalCounts);
      showFullPageLoader(context);
      print("loading");
      response = await Api.instance.submitCount(finalList);
    } else {
      if (!validateFormData()) {
        return;
      }
      showFullPageLoader(context);

      response = await Api.instance.submitCount([formData.toMap()]);
    }
    Navigator.of(context).pop();
    if (response != null && response.statusCode == 201) {
      showAlert(context, AlertState.success, "Update successfully",
          title: "Success", okCallback: () {
        checkForDiscrepancies();
      });
    } else if (response != null && response.message != "") {
      showAlert(context, AlertState.error, response.message);
    } else {
      showAlert(context, AlertState.error, "Something went wrong");
    }

    _resetForm();
    setState(() {
      savedFormData = [];
    });
    print(isCreate);
    if (!isCreate) {
      print("IS CREATED");
      Navigator.pushNamed(context, Dashboard.routeName);
    }
  }

  _resetForm() {
    setState(() {
      formData.skuId = "";
      // formData.binId = "";
      formData.palletCount = "";
      formData.extras = "";
      formData.countType = "GOOD";
      casePerPalletCount = "";
      totalCaseCount = "";
    });
    _extrasController.clear();
    _palletCountController.clear();
  }

  checkForDiscrepancies() async {
    var response = await Api.instance.getDiscrepancies(user.id);
    if (response == null) {
      return;
    }

    print(response['data']['discrepancies']);
    if (response['data']['discrepancies'] != null &&
        response['data']['discrepancies'].length > 0) {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg:
              "There are ${response['data']['discrepancies'].length} discrepancies in the records",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }
  }

  VoidCallback? _palletListener;
  _initiateSKUAddition() {
    void onTextChanged(context, setModalState) {
      if (setModalState != null && Navigator.of(context).canPop()) {
        setModalState(() {});
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (_palletListener != null) {
              _palletCountController.removeListener(_palletListener!);
              _extrasController.removeListener(_palletListener!);
            }
            _palletListener = () {
              if (Navigator.of(context).canPop()) {
                setModalState(() {});
              }
            };
            _palletCountController.addListener(_palletListener!);
            _extrasController.addListener(_palletListener!);

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 5),
                            Container(
                              height: 4,
                              width: 40,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _resetForm();
                                Navigator.pop(context);
                              },
                            ),
                          ]),
                      if (formData.skuType == "FG")
                        buildSKUForm(setModalState)
                      else
                        buildNFGSKUForm(setModalState),
                      Container(
                          width: double.infinity,
                          child:
                              Button(onPressed: saveFormCount, text: "Save")),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  _switchSkuType(String type) {
    if (savedFormData.length > 0) {
      showAlert(context, AlertState.info,
          "Are you sure you want to switch, any unsaved sku count would be discarded",
          okCallback: () {
        setState(() {
          formData.skuType = type;
          savedFormData = [];
        });
      });
    } else {
      setState(() => formData.skuType = type);
    }
  }

  Widget _buildPositionedBottomPill() {
    // Bottom pill navigator
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: constant.primaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _switchSkuType("FG"),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: formData.skuType == "FG"
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'FG',
                style: TextStyle(
                  color: formData.skuType == "FG" ? Colors.red : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _switchSkuType("NFG"),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: formData.skuType == "NFG"
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'NFG',
                style: TextStyle(
                  color: formData.skuType == "NFG" ? Colors.red : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSKUForm(setModalState) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom >= 20
              ? MediaQuery.of(context).viewInsets.bottom - 20
              : MediaQuery.of(context).viewInsets.bottom,
        ),
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
                            selectedSkuId: formData.skuId ?? "",
                            onSkuSelected: (newValue) {
                              setState(() {
                                formData.skuId = newValue;
                              });
                              if (setModalState != null) {
                                setModalState(() {});
                              }
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
                              formData.skuId == ""
                                  ? "Select an SKU"
                                  : selectedSKU()?.name ?? "",
                              style: TextStyle(
                                color: formData.skuId == ""
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
            if (selectedSKU() != null) ...[
              const SizedBox(
                height: 3,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Case per Pallet: ${selectedSKU()!.casePerPallet.toString()}",
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              "Full Pallet Counted",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            CustomTextField.withController(
              controller: _palletCountController,
              borderRadius: 10,
              keyboardType: TextInputType.number,
              hintText: "Enter count in pallets",
            ),
            if (casePerPalletCount.isNotEmpty) ...[
              const SizedBox(
                height: 3,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Case per Pallet Count: $casePerPalletCount",
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
            const SizedBox(height: 10),
            const Text(
              "Non-full pallet cases counted",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            CustomTextField.withController(
              controller: _extrasController,
              borderRadius: 10,
              keyboardType: TextInputType.number,
              hintText: "Enter count in cases",
            ),
            const SizedBox(height: 10),
            if (totalCaseCount.isNotEmpty) ...[
              const Text(
                "Total cases",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              CustomTextField.withOnChanged(
                onChanged: (value) {},
                enabled: false,
                borderRadius: 10,
                hintText: totalCaseCount,
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              "Count Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                hint: const Text("Select count type"),
                value: formData.countType,
                underline: const SizedBox.shrink(),
                isExpanded: true,
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: widget.count_type == null
                    ? (newValue) {
                        if (newValue != null) {
                          setState(() {
                            formData.countType = newValue;
                          });
                          if (setModalState != null) {
                            setModalState(() {});
                          }
                        }
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildNFGSKUForm(setModalState) {
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
                          selectedSkuId: formData.skuId ?? "",
                          onSkuSelected: (newValue) {
                            setState(() {
                              formData.skuId = newValue;
                            });
                            if (setModalState != null) {
                              setModalState(() {});
                            }
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
                            formData.skuId == ""
                                ? "Select an SKU"
                                : skus.data
                                    .firstWhere(
                                        (sku) => sku.id == formData.skuId)
                                    .name,
                            style: TextStyle(
                              color: formData.skuId == ""
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
            "Quantity",
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

  Widget buildSheetPage() {
    return savedFormData.isEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(children: [
              DottedBorder(
                options: const RoundedRectDottedBorderOptions(
                    dashPattern: [10, 5],
                    strokeWidth: 2,
                    padding: EdgeInsets.all(16),
                    color: Colors.black12,
                    radius: Radius.circular(15)),
                child: Container(
                  width: double.infinity,
                  child: Column(children: [
                    const Icon(Icons.inbox, size: 64, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(formData.skuType == "FG" ? "Add SKU" : "Add NFG SKU",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 4),
                    const Text("Click on the '+' button to begin count",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ]),
                ),
              )
            ]))
        : ListView.builder(
            // shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(),
            itemCount: savedFormData.length,
            itemBuilder: (context, index) {
              final item = savedFormData[index];

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Item text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: item.skuName + " ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment
                                      .middle, // keeps pill aligned
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.countType == "GOOD"
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.countType,
                                      style: TextStyle(
                                        color: item.countType == "GOOD"
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            softWrap:
                                true, // allows wrapping if skuName is long
                          ),

                          // Text(
                          //   item.skuName,
                          //   style: TextStyle(
                          //       fontWeight: FontWeight.bold, fontSize: 16),
                          // ),
                          SizedBox(height: 4),
                          Text(
                            '${item.skuType == "FG" ? "Full Pallet Counted: ${item.palletCount}   |  " : ""} ${item.skuType == "FG" ? "Non-full pallet cases counted:" : "Quantity:"} ${item.extras}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    // Delete icon
                    IconButton(
                      onPressed: () {
                        showAlert(context, AlertState.info,
                            "Are you sure you want to remove this count?",
                            title: "Kindly Confirm",
                            showCancel: true, okCallback: () {
                          setState(() {
                            savedFormData.removeAt(index);
                          });
                        });
                      },
                      icon: Icon(Icons.delete, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.all(4),
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
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
        actions: [
          if (isCreate && currentSection == 3) _buildPositionedBottomPill()
        ],
      ),
      floatingActionButton: (isCreate && currentSection == 3)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: FloatingActionButton(
                onPressed: _initiateSKUAddition,
                backgroundColor: constant.appDark, // background
                child: const Icon(Icons.add, size: 20, color: Colors.white),
              ),
            )
          : null,
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
                      "Selected Counting Area: ${warehouse['selected'].name}",
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
                // LocationPageList(
                //   loading: location['loading'],
                //   list: location['data'].data,
                //   selected: location['selected'],
                //   selectMethod: (index) {
                //     setState(() {
                //       location['selected'] = location['data'].data[index];
                //     });
                //   },
                // ),
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

                if (isCreate)
                  buildSheetPage()
                else if (formData.skuType == "FG")
                  buildSKUForm(null)
                else
                  buildNFGSKUForm(null),

                // buildSKUForm(),
                // buildNFGSKUForm(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (currentSection != 1 && goback && currentSection != 3)
                Expanded(
                  child: Button(
                      onPressed: _previousSection,
                      style: constant.buttonSecondary,
                      text: "Previous"),
                ),
              const SizedBox(
                width: 10,
              ),
              if (currentSection != 3)
                Expanded(child: Button(onPressed: _nextSection, text: "Next"))
              else if ((isCreate && savedFormData.length > 0) || !isCreate)
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
          : list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Column(children: [
                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                          dashPattern: [10, 5],
                          strokeWidth: 2,
                          padding: EdgeInsets.all(16),
                          color: Colors.black12,
                          radius: Radius.circular(15)),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("No availble warehouse",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text("Please contact your administrator",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ]),
                      ),
                    )
                  ]))
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      // padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          list[index].name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
          : list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Column(children: [
                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                          dashPattern: [10, 5],
                          strokeWidth: 2,
                          padding: EdgeInsets.all(16),
                          color: Colors.black12,
                          radius: Radius.circular(15)),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("No availble bin",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text("Please select a different Counting Area",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ]),
                      ),
                    )
                  ]))
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      // padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          list[index].name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
