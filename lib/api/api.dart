import "dart:convert";

import "package:flutter/widgets.dart";
import "package:stock_count_app/models/Bin.dart";
import "package:stock_count_app/models/Location.dart";

import "package:stock_count_app/models/Login.dart";
import "package:stock_count_app/models/Sku.dart";
import "package:stock_count_app/models/User.dart";
import "package:stock_count_app/models/Warehouse.dart";
import "package:stock_count_app/util/shared_preference_helper.dart";
import "package:http/http.dart" as http;
import 'package:stock_count_app/models/ApiResponse.dart';
import "package:stock_count_app/util/constant.dart" as constant;
import "package:stock_count_app/models/Model.dart";

// ignore: constant_identifier_names

// const BaseUrl = "http://192.168.1.215:8080/";
const BaseUrl = "https://stockcount.ciphernet.net/";

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
      print(parsedUri);
      var response = await http.get(parsedUri, headers: headers);
      print(response.statusCode);
      print(response.body);
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
    dynamic data,
  ) async {
    try {
      await _loadApiKey();
      var parsedUri = Uri.parse("$BaseUrl$uri");
      Map<String, String> headers = {'x-api-key': _apiKey};
      var body = data is List ? jsonEncode(data) : data;

      var response = await http.post(parsedUri, body: body, headers: headers);

      // var response =
      // await http.post(parsedUri, body: jsonEncode(data), headers: headers);

      return {
        "responseBody": jsonDecode(response.body),
        "statusCode": response.statusCode
      };
    } catch (error, stacktrace) {
      print("Error from try Catch: ${error.toString()}");
      print("stacktrace $stacktrace");
      return null;
    }
  }

  String prepMessage(Map<String, dynamic> responseBody) {
    String message = "";
    if (responseBody.containsKey("messsage") &&
        responseBody['message'] is String) {
      message = responseBody['message'];
    } else if (responseBody.containsKey("messages") &&
        responseBody['messages'] is String) {
      message = responseBody['messages'];
    } else if (responseBody.containsKey("messages") &&
        responseBody['messages'] is Map) {
      message = responseBody['messages']['error'];
    }

    return message;
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
    String countingExerciseID,
    String userID,
  ) async {
    var response =
        await _get("getteammemberwarehouses/$countingExerciseID/$userID", {});

    if (response == null) {
      return null;
    }
    print(response);
    return ApiResponse<WarehouseList>(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody'].contains('message')
            ? response['responseBody']['message']
            : "",
        data: WarehouseList.fromJson(response['responseBody']), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<ApiResponse<Team>?> fetchActiveTeamCounting(
    String userId,
  ) async {
    var response = await _get("getactiveteamcountingsession/$userId", {});

    if (response == null) {
      return null;
    }

    return ApiResponse<Team>(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: prepMessage(response['responseBody']),
        data: Team.fromJson(response['responseBody']), // Safe cast
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
        message: response['responseBody'].contains('message')
            ? response['responseBody']['message']
            : "",
        data: LocationList.fromJson(response['responseBody']), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<ApiResponse<BinList>?> fetchBins(
    String warehouseID,
  ) async {
    var response = await _get("getbinbywarehouseid/$warehouseID", {});

    if (response == null) {
      return null;
    }

    return ApiResponse<BinList>(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody'].contains('message')
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
    print(response);

    return ApiResponse<SkuList>(
        status: response['statusCode'] != null && response['statusCode'] == 201
            ? true
            : false,
        message: response['responseBody'].contains('message')
            ? response['responseBody']['message']
            : "",
        data: SkuList.fromJson(response['responseBody']), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<ApiResponse<Sku>?> submitCount(
      List<Map<String, String>> postData) async {
    print(postData);
    var response = await _post("count", postData);

    if (response == null) {
      return null;
    }

    print("SUBMIT COUNT RESPONSE");
    print(response);

    return ApiResponse(
        status: response['statusCode'] != null && response['statusCode'] == 200
            ? true
            : false,
        message: response['responseBody']['message'] ?? "",
        data: Sku(), // Safe cast
        statusCode: response['statusCode']);
  }

  Future<Map?> getDashboard(String id) async {
    var response = await _get("getdashboarddata/$id", {});

    if (response == null) {
      return null;
    }

    return {
      "status": response['statusCode'] != null && response['statusCode'] == 200
          ? true
          : false,

      "data": response['responseBody'], // Safe cast
      "statusCode": response['statusCode']
    };
  }

  Future<Map?> getDiscrepancies() async {
    var response = await _get("discrepancies-list", {});

    if (response == null) {
      return null;
    }

    return {
      "status": response['statusCode'] != null && response['statusCode'] == 200
          ? true
          : false,

      "data": response['responseBody'], // Safe cast
      "statusCode": response['statusCode']
    };
  }

  Future<Map?> getHistory(
    String id,
    int limit,
    int offset, {
    String? fromDate,
    String? toDate,
  }) async {
    var response = await _get("get-history/${id}", {
      "limit": limit.toString(),
      "offset": offset.toString(),
      "fromDate": fromDate,
      "toDate": toDate,
    });

    if (response == null) {
      return null;
    }

    return {
      "status": response['statusCode'] != null && response['statusCode'] == 200
          ? true
          : false,

      "data": response['responseBody'], // Safe cast
      "statusCode": response['statusCode']
    };
  }

  Future<Map?> updatePassword(Map<String, String> postData) async {
    var response = await _post("change-password", postData);

    if (response == null) {
      return null;
    }

    return {
      "status": response['statusCode'] != null && response['statusCode'] == 200
          ? true
          : false,
      "message": prepMessage(response['responseBody']),

      "data": response['responseBody'], // Safe cast
      "statusCode": response['statusCode']
    };
  }

  Future<Map?> removeCount(String countId, String userId) async {
    var response = await _post("remove-count", {
      "count_id": countId,
      "user_id": userId,
    });

    if (response == null) {
      return null;
    }

    return {
      "status": response['statusCode'] != null && response['statusCode'] == 200
          ? true
          : false,
      "message": prepMessage(response['responseBody']),

      "data": response['responseBody'], // Safe cast
      "statusCode": response['statusCode']
    };
  }
}
