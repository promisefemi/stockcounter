import 'package:stock_count_app/models/Model.dart';

class User implements Model {
  final String id;
  final String username;
  final String lineManager;
  final String email;
  final String firstName;
  final String lastName;
  final String roleId;
  final String role;
  final String companyCode;

  User({
    this.id = "",
    this.username = "",
    this.lineManager = "",
    this.email = "",
    this.firstName = "",
    this.lastName = "",
    this.roleId = "",
    this.role = "",
    this.companyCode = "",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? "",
      username: json['username'] ?? "",
      lineManager: json['line_manager'] ?? "",
      email: json['email'] ?? "",
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      roleId: json['role_id'] ?? "",
      role: json['role'] ?? "",
      companyCode: json['company_code'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'line_manager': lineManager,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role_id': roleId,
      'role': role,
      'company_code': companyCode,
    };
  }
}
