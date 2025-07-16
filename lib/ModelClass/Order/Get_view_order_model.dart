import 'package:simple/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"_id":"68778779ff518ce12520f056","orderNumber":"ORD-20250716-0023","items":[{"product":"6856fd071544bf146f676858","name":"Garden Salad","quantity":1,"unitPrice":63.56,"addons":[{"addon":"60a7e4f8a2f8f3b6e8d9b7c5","name":"Cheese","price":10,"_id":"68778779ff518ce12520f058"}],"tax":0,"subtotal":63.56,"_id":"68778779ff518ce12520f057"}],"subtotal":63.56,"tax":11.44,"total":75,"tableNo":null,"orderType":"TAKE-AWAY","orderStatus":"COMPLETED","operator":"6858f4ac1544bf146f676c8b","notes":"Take Away order","createdAt":"2025-07-16T11:10:59.577Z","updatedAt":"2025-07-16T11:05:29.844Z","__v":0}

class GetViewOrderModel {
  GetViewOrderModel({
    bool? success,
    Data? data,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
  }

  GetViewOrderModel.fromJson(dynamic json) {
    _success = json['success'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  bool? _success;
  Data? _data;
  ErrorResponse? errorResponse;
  GetViewOrderModel copyWith({
    bool? success,
    Data? data,
  }) =>
      GetViewOrderModel(
        success: success ?? _success,
        data: data ?? _data,
      );
  bool? get success => _success;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    return map;
  }
}

/// _id : "68778779ff518ce12520f056"
/// orderNumber : "ORD-20250716-0023"
/// items : [{"product":"6856fd071544bf146f676858","name":"Garden Salad","quantity":1,"unitPrice":63.56,"addons":[{"addon":"60a7e4f8a2f8f3b6e8d9b7c5","name":"Cheese","price":10,"_id":"68778779ff518ce12520f058"}],"tax":0,"subtotal":63.56,"_id":"68778779ff518ce12520f057"}]
/// subtotal : 63.56
/// tax : 11.44
/// total : 75
/// tableNo : null
/// orderType : "TAKE-AWAY"
/// orderStatus : "COMPLETED"
/// operator : "6858f4ac1544bf146f676c8b"
/// notes : "Take Away order"
/// createdAt : "2025-07-16T11:10:59.577Z"
/// updatedAt : "2025-07-16T11:05:29.844Z"
/// __v : 0

class Data {
  Data({
    String? id,
    String? orderNumber,
    List<Items>? items,
    num? subtotal,
    num? tax,
    num? total,
    dynamic tableNo,
    String? orderType,
    String? orderStatus,
    String? operator,
    String? notes,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _id = id;
    _orderNumber = orderNumber;
    _items = items;
    _subtotal = subtotal;
    _tax = tax;
    _total = total;
    _tableNo = tableNo;
    _orderType = orderType;
    _orderStatus = orderStatus;
    _operator = operator;
    _notes = notes;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _orderNumber = json['orderNumber'];
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }
    _subtotal = json['subtotal'];
    _tax = json['tax'];
    _total = json['total'];
    _tableNo = json['tableNo'];
    _orderType = json['orderType'];
    _orderStatus = json['orderStatus'];
    _operator = json['operator'];
    _notes = json['notes'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _id;
  String? _orderNumber;
  List<Items>? _items;
  num? _subtotal;
  num? _tax;
  num? _total;
  dynamic _tableNo;
  String? _orderType;
  String? _orderStatus;
  String? _operator;
  String? _notes;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Data copyWith({
    String? id,
    String? orderNumber,
    List<Items>? items,
    num? subtotal,
    num? tax,
    num? total,
    dynamic tableNo,
    String? orderType,
    String? orderStatus,
    String? operator,
    String? notes,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Data(
        id: id ?? _id,
        orderNumber: orderNumber ?? _orderNumber,
        items: items ?? _items,
        subtotal: subtotal ?? _subtotal,
        tax: tax ?? _tax,
        total: total ?? _total,
        tableNo: tableNo ?? _tableNo,
        orderType: orderType ?? _orderType,
        orderStatus: orderStatus ?? _orderStatus,
        operator: operator ?? _operator,
        notes: notes ?? _notes,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get id => _id;
  String? get orderNumber => _orderNumber;
  List<Items>? get items => _items;
  num? get subtotal => _subtotal;
  num? get tax => _tax;
  num? get total => _total;
  dynamic get tableNo => _tableNo;
  String? get orderType => _orderType;
  String? get orderStatus => _orderStatus;
  String? get operator => _operator;
  String? get notes => _notes;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['orderNumber'] = _orderNumber;
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    map['subtotal'] = _subtotal;
    map['tax'] = _tax;
    map['total'] = _total;
    map['tableNo'] = _tableNo;
    map['orderType'] = _orderType;
    map['orderStatus'] = _orderStatus;
    map['operator'] = _operator;
    map['notes'] = _notes;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

/// product : "6856fd071544bf146f676858"
/// name : "Garden Salad"
/// quantity : 1
/// unitPrice : 63.56
/// addons : [{"addon":"60a7e4f8a2f8f3b6e8d9b7c5","name":"Cheese","price":10,"_id":"68778779ff518ce12520f058"}]
/// tax : 0
/// subtotal : 63.56
/// _id : "68778779ff518ce12520f057"

class Items {
  Items({
    String? product,
    String? name,
    num? quantity,
    num? unitPrice,
    List<Addons>? addons,
    num? tax,
    num? subtotal,
    String? id,
  }) {
    _product = product;
    _name = name;
    _quantity = quantity;
    _unitPrice = unitPrice;
    _addons = addons;
    _tax = tax;
    _subtotal = subtotal;
    _id = id;
  }

  Items.fromJson(dynamic json) {
    _product = json['product'];
    _name = json['name'];
    _quantity = json['quantity'];
    _unitPrice = json['unitPrice'];
    if (json['addons'] != null) {
      _addons = [];
      json['addons'].forEach((v) {
        _addons?.add(Addons.fromJson(v));
      });
    }
    _tax = json['tax'];
    _subtotal = json['subtotal'];
    _id = json['_id'];
  }
  String? _product;
  String? _name;
  num? _quantity;
  num? _unitPrice;
  List<Addons>? _addons;
  num? _tax;
  num? _subtotal;
  String? _id;
  Items copyWith({
    String? product,
    String? name,
    num? quantity,
    num? unitPrice,
    List<Addons>? addons,
    num? tax,
    num? subtotal,
    String? id,
  }) =>
      Items(
        product: product ?? _product,
        name: name ?? _name,
        quantity: quantity ?? _quantity,
        unitPrice: unitPrice ?? _unitPrice,
        addons: addons ?? _addons,
        tax: tax ?? _tax,
        subtotal: subtotal ?? _subtotal,
        id: id ?? _id,
      );
  String? get product => _product;
  String? get name => _name;
  num? get quantity => _quantity;
  num? get unitPrice => _unitPrice;
  List<Addons>? get addons => _addons;
  num? get tax => _tax;
  num? get subtotal => _subtotal;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['product'] = _product;
    map['name'] = _name;
    map['quantity'] = _quantity;
    map['unitPrice'] = _unitPrice;
    if (_addons != null) {
      map['addons'] = _addons?.map((v) => v.toJson()).toList();
    }
    map['tax'] = _tax;
    map['subtotal'] = _subtotal;
    map['_id'] = _id;
    return map;
  }
}

/// addon : "60a7e4f8a2f8f3b6e8d9b7c5"
/// name : "Cheese"
/// price : 10
/// _id : "68778779ff518ce12520f058"

class Addons {
  Addons({
    String? addon,
    String? name,
    num? price,
    String? id,
  }) {
    _addon = addon;
    _name = name;
    _price = price;
    _id = id;
  }

  Addons.fromJson(dynamic json) {
    _addon = json['addon'];
    _name = json['name'];
    _price = json['price'];
    _id = json['_id'];
  }
  String? _addon;
  String? _name;
  num? _price;
  String? _id;
  Addons copyWith({
    String? addon,
    String? name,
    num? price,
    String? id,
  }) =>
      Addons(
        addon: addon ?? _addon,
        name: name ?? _name,
        price: price ?? _price,
        id: id ?? _id,
      );
  String? get addon => _addon;
  String? get name => _name;
  num? get price => _price;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['addon'] = _addon;
    map['name'] = _name;
    map['price'] = _price;
    map['_id'] = _id;
    return map;
  }
}
