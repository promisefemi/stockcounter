import "dart:convert";

import "package:flutter/widgets.dart";
import "package:stock_count_app/models/Bin.dart";
import "package:stock_count_app/models/Location.dart";

import "package:stock_count_app/models/Login.dart";
import "package:stock_count_app/models/Sku.dart";
import "package:stock_count_app/models/Warehouse.dart";
import "package:stock_count_app/util/shared_preference_helper.dart";
import "package:http/http.dart" as http;
import 'package:stock_count_app/models/ApiResponse.dart';
import "package:stock_count_app/util/constant.dart" as constant;
import "package:stock_count_app/models/Model.dart";

// ignore: constant_identifier_names

// const BaseUrl = "http://192.168.0.134/fuelapp/api/v1/";
// const BaseUrl = "http://192.168.0.103/fuelapp/api/v1/";
// const BaseUrl = "https://fuelapp.ciphernetsandbox.com.ng/api/v1/";
const BaseUrl = "https://stockcount.ciphernetsandbox.com.ng/public/";

class Api {
  String _apiKey = '';
  static final Api _instance = Api._internal();

  static Api get instance => _instance;

  Api._internal() {
    _loadApiKey();
  }

  _loadApiKey() async {
    var instance = await SharedPreferencesHelper.getInstance();
    _apiKey = instance.getString(constant.apiKey) ?? '';
  }

  ApiResponse<Model>? _handleResponse(
      http.Response response, Model Function(dynamic) decodeInnerModel) {
    debugPrint("Request failed with response code: ${response.statusCode}");
    debugPrint("Failed response body ${response.body}");

    var decodedResponse = jsonDecode(response.body);

    print(jsonEncode(decodedResponse));

    var finalResponse = ApiResponse.fromJson(
        decodedResponse, decodeInnerModel, response.statusCode);

    print(jsonEncode(finalResponse));

    return finalResponse;
  }

  Future<Map<String, dynamic>?> _get(
    String uri,
    Map<String, dynamic> param,
  ) async {
    try {
      await _loadApiKey();
      var parsedUri = Uri.parse("$BaseUrl$uri");

      Map<String, String> headers = {'x-api-key': _apiKey};
      // print(_apiKey);
      if (param.isNotEmpty) {
        parsedUri = parsedUri.replace(queryParameters: param);
      }
      // print(parsedUri);
      var response = await http.get(parsedUri, headers: headers);
      return {
        "responseBody": jsonDecode(response.body),
        "statusCode": response.statusCode
      };
    } catch (error) {
      print("Error from try Catch: ${error.toString()}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> _post(
    String uri,
    Map<String, dynamic> data,
  ) async {
    try {
      await _loadApiKey();
      var parsedUri = Uri.parse("$BaseUrl$uri");
      Map<String, String> headers = {'x-api-key': _apiKey};
      //  print(parsedUri);
      var response = await http.post(parsedUri, body: data, headers: headers);
      return {
        "responseBody": jsonDecode(response.body),
        "statusCode": response.statusCode
      };
    } catch (error) {
      print("Error from try Catch: ${error.toString()}");
      return null;
    }
  }

  Future<ApiResponse<Login>?> login(
    String username,
    String password,
  ) async {
    var response = await _post(
      "apiauthenticate",
      {
        'username': username,
        'password_hash': password,
      },
    );

    if (response == null) {
      return null;
    }

    if (response['responseBody']['user'] != null) {
      response['responseBody']['user']['teamInformation'] =
          response['responseBody']['teamInformation'];
    }

    return ApiResponse<Login>(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody']['message'] != null
            ? response['responseBody']['message']
            : "",
        data: Login.fromJson(response['responseBody']), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<ApiResponse<WarehouseList>?> fetchWarehouses(
    String plant,
  ) async {
    var response = await _get("getwarehousesbyplantid/$plant", {});

    if (response == null) {
      return null;
    }

    return ApiResponse<WarehouseList>(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody']['message'] != null
            ? response['responseBody']['message']
            : "",
        data: WarehouseList.fromJson(response['responseBody']), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<ApiResponse<LocationList>?> fetchWarehouseLocations(
    String warehouseId,
  ) async {
    var response = await _get("getlocationbywarehouseid/$warehouseId", {});

    if (response == null) {
      return null;
    }

    return ApiResponse<LocationList>(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody']['message'] != null
            ? response['responseBody']['message']
            : "",
        data: LocationList.fromJson(response['responseBody']), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<ApiResponse<BinList>?> fetchBins(
    String locationId,
  ) async {
    var response = await _get("getbinbylocationid/$locationId", {});

    if (response == null) {
      return null;
    }

    return ApiResponse<BinList>(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody']['message'] != null
            ? response['responseBody']['message']
            : "",
        data: BinList.fromJson(response['responseBody']), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<ApiResponse<SkuList>?> fetchSKUs() async {
    var response = await _get("getallskus", {});

    if (response == null) {
      return null;
    }

    return ApiResponse<SkuList>(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody']['message'] != null
            ? response['responseBody']['message']
            : "",
        data: SkuList.fromJson(response['responseBody']), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<ApiResponse<Sku>?> submitCount(Map<String, String> postData) async {
    var response = await _post("count", postData);

    if (response == null) {
      return null;
    }

    return ApiResponse(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody']['message'] != null
            ? response['responseBody']['message']
            : "",
        data: Sku(), // Safe cast
        statusCode: response['statusCode']);
  }
}
