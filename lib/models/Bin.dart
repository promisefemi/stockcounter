import 'package:stock_count_app/models/Model.dart';

class Bin implements Model {
  final String id;
  final String name;
  final String qrCode;
  final String warehouseLocationId;

  Bin({
    this.id = "",
    this.name = "",
    this.qrCode = "",
    this.warehouseLocationId = "",
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      qrCode: json['qr_code'] ?? "",
      warehouseLocationId: json['warehouse_location_id'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qr_code': qrCode,
      'warehouse_location_id': warehouseLocationId,
    };
  }
}

class BinList implements Model {
  List<Bin> data;

  BinList({List<Bin>? data}) : data = data ?? [];

  factory BinList.fromJson(dynamic json) {
    // json = json as List<dynamic>;
    List<Bin> jsonList = [];
    if (json.isNotEmpty) {
      json = json as List<dynamic>;
      for (var item in json) {
        Map<String, dynamic> parseItem = item as Map<String, dynamic>;
        jsonList.add(Bin.fromJson(parseItem));
      }
    }
    // List<FuelStation> jsonList = [];
    return BinList(data: jsonList);
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
