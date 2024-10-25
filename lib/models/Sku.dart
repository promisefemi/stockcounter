import 'package:stock_count_app/models/Model.dart';

class Sku implements Model {
  final String id;
  final String name;
  final String skuCode;
  final String description;
  final String casePerPallet;

  Sku({
    this.id = "",
    this.name = "",
    this.skuCode = "",
    this.description = "",
    this.casePerPallet = "",
  });

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      skuCode: json['sku_code'] ?? "",
      description: json['description'] ?? "",
      casePerPallet: json['cases_per_pallet'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku_code': skuCode,
      'description': description,
      'cases_per_pallet': casePerPallet,
    };
  }
}

class SkuList implements Model {
  List<Sku> data;

  SkuList({List<Sku>? data}) : data = data ?? [];

  factory SkuList.fromJson(dynamic json) {
    // json = json as List<dynamic>;
    List<Sku> jsonList = [];
    if (json.isNotEmpty) {
      json = json as List<dynamic>;
      for (var item in json) {
        Map<String, dynamic> parseItem = item as Map<String, dynamic>;
        jsonList.add(Sku.fromJson(parseItem));
      }
    }
    // List<FuelStation> jsonList = [];
    return SkuList(data: jsonList);
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
