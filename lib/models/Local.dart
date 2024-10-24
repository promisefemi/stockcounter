import 'package:stock_count_app/models/Model.dart';

class State implements Model {
  final String id;
  final String name;

  State({
    this.id = "",
    this.name = "",
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Lga implements Model {
  final String id;
  final String name;

  Lga({
    this.id = "",
    this.name = "",
  });

  factory Lga.fromJson(Map<String, dynamic> json) {
    return Lga(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class LgaList implements Model {
  List<Lga> data;

  LgaList({List<Lga>? data}) : this.data = data ?? [];

  factory LgaList.fromJson(dynamic json) {
    // json = json as List<dynamic>;
    List<Lga> jsonList = [];
    if (json.isNotEmpty) {
      json = json as List<dynamic>;
      for (var item in json) {
        Map<String, dynamic> parseItem = item as Map<String, dynamic>;
        jsonList.add(Lga.fromJson(parseItem));
      }
    }
    // List<FuelStation> jsonList = [];
    return LgaList(data: jsonList);
  }

  @override
  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> jsonList = [];
    for (var i = 0; i < data.length; i++) {
      jsonList.add(data[i].toJson());
    }

    return jsonList;
  }
}
