import 'package:stock_count_app/models/Model.dart';

class Warehouse implements Model {
  final String id;
  final String name;
  final String description;
  final String plantId;

  Warehouse({
    this.id = "",
    this.name = "",
    this.description = "",
    this.plantId = "",
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      plantId: json['plant_id'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'plant_id': plantId,
    };
  }
}

class WarehouseList implements Model {
  List<Warehouse> data;

  WarehouseList({List<Warehouse>? data}) : data = data ?? [];

  factory WarehouseList.fromJson(dynamic json) {
    // json = json as List<dynamic>;
    List<Warehouse> jsonList = [];
    if (json.isNotEmpty) {
      json = json as List<dynamic>;
      for (var item in json) {
        Map<String, dynamic> parseItem = item as Map<String, dynamic>;
        jsonList.add(Warehouse.fromJson(parseItem));
      }
    }
    // List<FuelStation> jsonList = [];
    return WarehouseList(data: jsonList);
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
