import 'package:simple/Bloc/Response/errorResponse.dart';

/// items : [{"name":"Apple juice","qty":1,"basePrice":120,"addonTotal":0,"subtotal":120,"totalTax":21.6,"total":141.6,"appliedTaxes":[{"name":"CGST","percentage":9,"amount":10.8,"isInclusive":false},{"name":"SGST","percentage":9,"amount":10.8,"isInclusive":false}]}]
/// subtotal : 240
/// totalTax : 43.2
/// total : 283.2

class PostAddToBillingModel {
  PostAddToBillingModel({
    List<Items>? items,
    num? subtotal,
    num? totalTax,
    num? total,
    ErrorResponse? errorResponse,
  }) {
    _items = items;
    _subtotal = subtotal;
    _totalTax = totalTax;
    _total = total;
  }

  PostAddToBillingModel.fromJson(dynamic json) {
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }
    _subtotal = json['subtotal'];
    _totalTax = json['totalTax'];
    _total = json['total'];
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  List<Items>? _items;
  num? _subtotal;
  num? _totalTax;
  num? _total;
  ErrorResponse? errorResponse;
  PostAddToBillingModel copyWith({
    List<Items>? items,
    num? subtotal,
    num? totalTax,
    num? total,
  }) =>
      PostAddToBillingModel(
        items: items ?? _items,
        subtotal: subtotal ?? _subtotal,
        totalTax: totalTax ?? _totalTax,
        total: total ?? _total,
      );
  List<Items>? get items => _items;
  num? get subtotal => _subtotal;
  num? get totalTax => _totalTax;
  num? get total => _total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    map['subtotal'] = _subtotal;
    map['totalTax'] = _totalTax;
    map['total'] = _total;
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    return map;
  }
}

/// name : "Apple juice"
/// qty : 1
/// basePrice : 120
/// addonTotal : 0
/// subtotal : 120
/// totalTax : 21.6
/// total : 141.6
/// appliedTaxes : [{"name":"CGST","percentage":9,"amount":10.8,"isInclusive":false},{"name":"SGST","percentage":9,"amount":10.8,"isInclusive":false}]
/// hasAddons : false // Added this property
/// addons : [] // Added this property

class Items {
  Items({
    String? id,
    String? name,
    String? image,
    num? qty,
    num? basePrice,
    num? addonTotal,
    num? subtotal,
    num? totalTax,
    num? total,
    List<AppliedTaxes>? appliedTaxes,
    bool? hasAddons, // Added
    List<Addons>? addons, // Added
  }) {
    _id = id;
    _name = name;
    _image = image;
    _qty = qty;
    _basePrice = basePrice;
    _addonTotal = addonTotal;
    _subtotal = subtotal;
    _totalTax = totalTax;
    _total = total;
    _appliedTaxes = appliedTaxes;
    _hasAddons = hasAddons; // Initialized
    _addons = addons; // Initialized
  }

  Items.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _image = json['image'];
    _qty = json['qty'];
    _basePrice = json['basePrice'];
    _addonTotal = json['addonTotal'];
    _subtotal = json['subtotal'];
    _totalTax = json['totalTax'];
    _total = json['total'];
    if (json['appliedTaxes'] != null) {
      _appliedTaxes = [];
      json['appliedTaxes'].forEach((v) {
        _appliedTaxes?.add(AppliedTaxes.fromJson(v));
      });
    }
    _hasAddons = json['hasAddons']; // Parsed
    if (json['addons'] != null) {
      _addons = [];
      json['addons'].forEach((v) {
        _addons?.add(Addons.fromJson(v));
      });
    }
  }
  String? _id;
  String? _name;
  String? _image;
  num? _qty;
  num? _basePrice;
  num? _addonTotal;
  num? _subtotal;
  num? _totalTax;
  num? _total;
  List<AppliedTaxes>? _appliedTaxes;
  bool? _hasAddons; // Private field
  List<Addons>? _addons; // Private field

  Items copyWith({
    String? id,
    String? name,
    String? image,
    num? qty,
    num? basePrice,
    num? addonTotal,
    num? subtotal,
    num? totalTax,
    num? total,
    List<AppliedTaxes>? appliedTaxes,
    bool? hasAddons, // Updated copyWith
    List<Addons>? addons, // Updated copyWith
  }) =>
      Items(
        id: id ?? _id,
        name: name ?? _name,
        image: image ?? _image,
        qty: qty ?? _qty,
        basePrice: basePrice ?? _basePrice,
        addonTotal: addonTotal ?? _addonTotal,
        subtotal: subtotal ?? _subtotal,
        totalTax: totalTax ?? _totalTax,
        total: total ?? _total,
        appliedTaxes: appliedTaxes ?? _appliedTaxes,
        hasAddons: hasAddons ?? _hasAddons, // Updated copyWith
        addons: addons ?? _addons, // Updated copyWith
      );
  String? get id => _id;
  String? get name => _name;
  String? get image => _image;
  num? get qty => _qty;
  num? get basePrice => _basePrice;
  num? get addonTotal => _addonTotal;
  num? get subtotal => _subtotal;
  num? get totalTax => _totalTax;
  num? get total => _total;
  List<AppliedTaxes>? get appliedTaxes => _appliedTaxes;
  bool? get hasAddons => _hasAddons; // Getter
  List<Addons>? get addons => _addons; // Getter

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['image'] = _image;
    map['qty'] = _qty;
    map['basePrice'] = _basePrice;
    map['addonTotal'] = _addonTotal;
    map['subtotal'] = _subtotal;
    map['totalTax'] = _totalTax;
    map['total'] = _total;
    if (_appliedTaxes != null) {
      map['appliedTaxes'] = _appliedTaxes?.map((v) => v.toJson()).toList();
    }
    map['hasAddons'] = _hasAddons; // Serialized
    if (_addons != null) {
      map['addons'] = _addons?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// name : "CGST"
/// percentage : 9
/// amount : 10.8
/// isInclusive : false

class AppliedTaxes {
  AppliedTaxes({
    String? name,
    num? percentage,
    num? amount,
    bool? isInclusive,
  }) {
    _name = name;
    _percentage = percentage;
    _amount = amount;
    _isInclusive = isInclusive;
  }

  AppliedTaxes.fromJson(dynamic json) {
    _name = json['name'];
    _percentage = json['percentage'];
    _amount = json['amount'];
    _isInclusive = json['isInclusive'];
  }
  String? _name;
  num? _percentage;
  num? _amount;
  bool? _isInclusive;
  AppliedTaxes copyWith({
    String? name,
    num? percentage,
    num? amount,
    bool? isInclusive,
  }) =>
      AppliedTaxes(
        name: name ?? _name,
        percentage: percentage ?? _percentage,
        amount: amount ?? _amount,
        isInclusive: isInclusive ?? _isInclusive,
      );
  String? get name => _name;
  num? get percentage => _percentage;
  num? get amount => _amount;
  bool? get isInclusive => _isInclusive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['percentage'] = _percentage;
    map['amount'] = _amount;
    map['isInclusive'] = _isInclusive;
    return map;
  }
}

// New Addons class to model the addon structure
class Addons {
  Addons({
    String? id,
    String? name,
    num? price,
    bool? isSelected,
    bool? isAvailable,
    num? maxQuantity,
    bool? isFree,
  }) {
    _id = id;
    _name = name;
    _price = price;
    _isSelected = isSelected;
    _isAvailable = isAvailable;
    _maxQuantity = maxQuantity;
    _isFree = isFree;
  }

  Addons.fromJson(dynamic json) {
    _id = json['_id'];
    _name = json['name'];
    _price = json['price'];
    _isSelected = json['isSelected'];
    _isAvailable = json['isAvailable'];
    _maxQuantity = json['maxQuantity'];
    _isFree = json['isFree'];
  }

  String? _id;
  String? _name;
  num? _price;
  bool? _isSelected;
  bool? _isAvailable;
  num? _maxQuantity;
  bool? _isFree;

  String? get id => _id;
  String? get name => _name;
  num? get price => _price;
  bool? get isSelected => _isSelected;
  bool? get isAvailable => _isAvailable;
  num? get maxQuantity => _maxQuantity;
  bool? get isFree => _isFree;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['name'] = _name;
    map['price'] = _price;
    map['isSelected'] = _isSelected;
    map['isAvailable'] = _isAvailable;
    map['maxQuantity'] = _maxQuantity;
    map['isFree'] = _isFree;
    return map;
  }
}
