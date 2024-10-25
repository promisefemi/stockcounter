import 'package:stock_count_app/models/Model.dart';

class Location implements Model {
  final String id;
  final String name;
  final String description;
  final String warehouseId;

  Location({
    this.id = "",
    this.name = "",
    this.description = "",
    this.warehouseId = "",
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      warehouseId: json['warehouse_id'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'warehouse_id': warehouseId,
    };
  }
}

class LocationList implements Model {
  List<Location> data;

  LocationList({List<Location>? data}) : data = data ?? [];

  factory LocationList.fromJson(dynamic json) {
    // json = json as List<dynamic>;
    List<Location> jsonList = [];
    if (json.isNotEmpty) {
      json = json as List<dynamic>;
      for (var item in json) {
        Map<String, dynamic> parseItem = item as Map<String, dynamic>;
        jsonList.add(Location.fromJson(parseItem));
      }
    }
    // List<FuelStation> jsonList = [];
    return LocationList(data: jsonList);
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
