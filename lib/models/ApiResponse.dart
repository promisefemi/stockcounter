import 'package:stock_count_app/models/Model.dart';

class ApiResponse<T extends Model> {
  final bool status;
  final String message;
  final int statusCode;
  final T data;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(Map<dynamic, dynamic> json,
      T Function(dynamic) innerModelAbstract, int statusCode) {
    var data;

    if (json['data'] != null && json['data'].isNotEmpty) {
      data = innerModelAbstract(json['data']);
    } else {
      data = innerModelAbstract({});
    }
    return ApiResponse(
        status: json['status'] ?? false,
        message: json['message'] ?? "",
        data: data,
        statusCode: statusCode);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}
