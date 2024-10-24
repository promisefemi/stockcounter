import 'package:stock_count_app/models/Model.dart';
import 'package:stock_count_app/models/User.dart';

class Login implements Model {
  final String apiKey;
  final User? user;

  Login({
    this.apiKey = "",
    this.user,
  });

  factory Login.fromJson(dynamic json) {
    // json = json as Map<String, dynamic>;
    return Login(
      apiKey: json.isNotEmpty ? (json['apiKey'] ?? "") : "",
      user: json.isNotEmpty
          ? (json['user'] != null && json['user'].isNotEmpty
              ? User.fromJson(json['user'])
              : null)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'user': user?.toJson(),
    };
  }
}
