import "dart:convert";

import "package:flutter/widgets.dart";

import "package:stock_count_app/models/Login.dart";
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

    debugPrint(response.body);
    var finalResponse = ApiResponse.fromJson(
        decodedResponse, decodeInnerModel, response.statusCode);
    return finalResponse;
  }

  Future<ApiResponse<Model>?> _get(
    String uri,
    Map<String, dynamic> param,
    Model Function(dynamic) decodeInnerModel,
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
      return _handleResponse(response, decodeInnerModel);
    } catch (error) {
      print("Error from try Catch: ${error.toString()}");
      return null;
    }
  }

  Future<ApiResponse<Model>?> _post(
    String uri,
    Map<String, dynamic> data,
    Model Function(dynamic) decodeInnerModel,
  ) async {
    try {
      await _loadApiKey();
      var parsedUri = Uri.parse("$BaseUrl$uri");
      Map<String, String> headers = {'x-api-key': _apiKey};
      //  print(parsedUri);
      var response = await http.post(parsedUri, body: data, headers: headers);
      return _handleResponse(response, decodeInnerModel);
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
      Login.fromJson,
    );
    if (response == null) {
      return null;
    }

    if (response.data is Login) {
      return ApiResponse<Login>(
          status: response.status,
          message: response.message,
          data: response.data as Login, // Safe cast
          statusCode: response.statusCode);
    } else {
      return null;
    }
  }
}
