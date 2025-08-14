import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import "package:flutter/material.dart";
import 'package:stock_count_app/components/FullPageLoader.dart';
import 'package:stock_count_app/models/ApiResponse.dart';
import 'package:stock_count_app/models/User.dart';
import 'package:stock_count_app/screens/Dashboard.dart';
import 'package:stock_count_app/util/dialog.dart';
import 'package:stock_count_app/util/shared_preference_helper.dart';
import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:intl/intl.dart';

String formatDate(String dateString,
    {String? outputFormat,
    String dateInputFormat = "yyyy-MM-dd HH:mm:ss",
    bool addTime = false}) {
  if (dateString == "") {
    return "";
  }
  DateFormat inputFormat = DateFormat(dateInputFormat);
  DateTime dateTime = inputFormat.parse(dateString);
  if (outputFormat != null) {
    return DateFormat(outputFormat).format(dateTime);
  } else {
    var outFmt = "dd<--> MMMM y ";
    if (addTime) {
      outFmt = "dd<--> MMMM y h:mm a";
    }
    var formattedDate = DateFormat(outFmt).format(dateTime);
    return formattedDate.replaceAll("<-->", _ordinalIndicator(dateTime.day));
  }
}

String _ordinalIndicator(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String formatCurrency(dynamic amount) {
  String currencyCode = 'NGN';
  amount = amount.toString();
  if (amount == "") {
    return (0).toString();
  }

  double amountValue = double.parse(amount);
  NumberFormat nairaCurrencyFormat = NumberFormat.simpleCurrency(
    locale: Platform.localeName, // Use the Nigerian locale
    name: 'NGN', // Specify the currency code for Nigerian Naira
    decimalDigits: 0, // Set the number of decimal places to 2
  );

  return nairaCurrencyFormat.format(amountValue);
}

Future<User?> getActiveUser() async {
  final prefs = await SharedPreferencesHelper.getInstance();
  var userMap = prefs.getMap(constant.userKey);
  if (userMap != null) {
    return User.fromJson(userMap);
  }
  return null;
}

bool handleResponse(BuildContext context, dynamic response) {
  print(response);
  if (response == null) {
    showAlert(context, AlertState.error, constant.somethingError,
        okCallback: () {
      Navigator.pushNamed(context, Dashboard.routeName);
    });
    return false;
  }

  if (!response!.status) {
    showAlert(context, AlertState.error, response.message);
    return false;
  }

  return true;
}

Color getStatusColor(String status) {
  if (status.toUpperCase() == constant.APPROVED) {
    return const Color.fromRGBO(22, 132, 205, 1);
  } else if (status.toUpperCase() == constant.PENDING) {
    return const Color.fromRGBO(52, 73, 94, 1);
  } else if (status.toUpperCase() == constant.COMPLETED ||
      status.toUpperCase() == constant.PENDING_PAYMENT) {
    return const Color.fromRGBO(46, 204, 113, 1);
  } else if (status.toUpperCase() == constant.CANCELLED) {
    return const Color.fromRGBO(250, 77, 45, 1);
  }

  return const Color.fromRGBO(22, 132, 205, 1);
}

String encodeImageToBase64(String path) {
  final bytes = File(path).readAsBytesSync();
  final encoded = base64Encode(Uint8List.fromList(bytes));
  return 'data:image/jpg;base64,$encoded';
}
