import 'package:stock_count_app/models/Model.dart';

class ApiResponse<T extends Model> {
  final bool status;
  final String message;
  final T data;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<dynamic, dynamic> json,
    T Function(dynamic) innerModelAbstract,
  ) {
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}
