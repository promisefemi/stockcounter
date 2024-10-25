import 'package:stock_count_app/models/Model.dart';

class Team implements Model {
  final String teamId;
  final String userId;
  final String countingExcerciseId;

  Team({this.teamId = "", this.userId = "", this.countingExcerciseId = ""});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: json['team_id'] ?? "",
      userId: json['user_id'] ?? "",
      countingExcerciseId: json['counting_exercise_id'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'user_id': userId,
      'counting_exercise_id': countingExcerciseId,
    };
  }
}

class User implements Model {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String plant;
  final String role;
  final String status;
  final Team? team;

  User({
    this.id = "",
    this.username = "",
    this.email = "",
    this.fullName = "",
    this.phone = "",
    this.plant = "",
    this.role = "",
    this.status = "",
    this.team,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? "",
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      fullName: json['full_name'] ?? "",
      phone: json['phone'] ?? "",
      plant: json['plant'] ?? "",
      role: json['role'] ?? "",
      status: json['status'] ?? "",
      team: json.isNotEmpty
          ? (json['teamInformation'] != null &&
                  json['teamInformation'].isNotEmpty
              ? Team.fromJson(json['teamInformation'])
              : null)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'plant': plant,
      'role': role,
      'status': status,
      'teamInformation': team?.toJson(),
    };
  }
}
