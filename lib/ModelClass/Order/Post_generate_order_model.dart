import 'package:simple/Bloc/Response/errorResponse.dart';

/// message : "Order created successfully"
/// order : {"_id":"687641b8ff518ce12520c9b3","orderNumber":"ORD-20250715-0008","items":[{"product":"685b7fa98753e2ece10465e7","name":"White forest","quantity":3,"unitPrice":56.49666666666667,"addons":[{"addon":"60a7e4f8a2f8f3b6e8d9b7c5","name":"Cheese","price":10,"_id":"687641b8ff518ce12520c9b5"}],"tax":0,"subtotal":189.49,"_id":"687641b8ff518ce12520c9b4"}],"subtotal":169.49,"tax":30.51,"total":200,"createdAt":"2025-07-15T11:10:59.577Z"}
/// payments : []
/// invoice : {"businessName":"Roja Restaurant","address":"11 Big street, Madrasa, Tamil Nadu 600001","phone":"+91-9876543210","gstNumber":"29ABCDE1234F2Z5","currencySymbol":"₹","printType":"imin","items":[{"name":"White forest","basePrice":56.49666666666667,"qty":3,"taxPrice":34.11021240191162,"totalPrice":223.60021240191162}],"subtotal":169.49,"salesTax":30.51,"total":200,"orderNumber":"ORD-20250715-0008","orderStatus":"WAITLIST","date":"7/15/2025, 5:25:36 PM","paidBy":"N/A","transactionId":"TXN-20250715-082781","tableNo":"N/A"}

class PostGenerateOrderModel {
  PostGenerateOrderModel({
    String? message,
    Order? order,
    List<Payments>? payments,
    Invoice? invoice,
    ErrorResponse? errorResponse,
  }) {
    _message = message;
    _order = order;
    _payments = payments;
    _invoice = invoice;
  }

  PostGenerateOrderModel.fromJson(dynamic json) {
    _message = json['message'];
    _order = json['order'] != null ? Order.fromJson(json['order']) : null;
    if (json['payments'] != null) {
      _payments = [];
      json['payments'].forEach((v) {
        _payments?.add(Payments.fromJson(v));
      });
    }
    _invoice =
        json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null;
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  String? _message;
  Order? _order;
  List<Payments>? _payments;
  Invoice? _invoice;
  ErrorResponse? errorResponse;
  PostGenerateOrderModel copyWith({
    String? message,
    Order? order,
    List<Payments>? payments,
    Invoice? invoice,
  }) =>
      PostGenerateOrderModel(
        message: message ?? _message,
        order: order ?? _order,
        payments: payments ?? _payments,
        invoice: invoice ?? _invoice,
      );
  String? get message => _message;
  Order? get order => _order;
  List<Payments>? get payments => _payments;
  Invoice? get invoice => _invoice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    if (_order != null) {
      map['order'] = _order?.toJson();
    }
    if (_payments != null) {
      map['payments'] = _payments?.map((v) => v.toJson()).toList();
    }
    if (_invoice != null) {
      map['invoice'] = _invoice?.toJson();
    }
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    return map;
  }
}

/// businessName : "Roja Restaurant"
/// address : "11 Big street, Madrasa, Tamil Nadu 600001"
/// phone : "+91-9876543210"
/// gstNumber : "29ABCDE1234F2Z5"
/// currencySymbol : "₹"
/// printType : "imin"
/// items : [{"name":"White forest","basePrice":56.49666666666667,"qty":3,"taxPrice":34.11021240191162,"totalPrice":223.60021240191162}]
/// subtotal : 169.49
/// salesTax : 30.51
/// total : 200
/// orderNumber : "ORD-20250715-0008"
/// orderStatus : "WAITLIST"
/// date : "7/15/2025, 5:25:36 PM"
/// paidBy : "N/A"
/// transactionId : "TXN-20250715-082781"
/// tableNo : "N/A"
class Payments {
  Payments({
    String? order,
    String? paymentMethod,
    num? amount,
    num? balanceAmount,
    String? status,
    String? createdAt,
    String? id,
    String? updatedAt,
    num? v,
  }) {
    _order = order;
    _paymentMethod = paymentMethod;
    _amount = amount;
    _balanceAmount = balanceAmount;
    _status = status;
    _createdAt = createdAt;
    _id = id;
    _updatedAt = updatedAt;
    _v = v;
  }

  Payments.fromJson(dynamic json) {
    _order = json['order'];
    _paymentMethod = json['paymentMethod'];
    _amount = json['amount'];
    _balanceAmount = json['balanceAmount'];
    _status = json['status'];
    _createdAt = json['createdAt'];
    _id = json['_id'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _order;
  String? _paymentMethod;
  num? _amount;
  num? _balanceAmount;
  String? _status;
  String? _createdAt;
  String? _id;
  String? _updatedAt;
  num? _v;
  Payments copyWith({
    String? order,
    String? paymentMethod,
    num? amount,
    num? balanceAmount,
    String? status,
    String? createdAt,
    String? id,
    String? updatedAt,
    num? v,
  }) =>
      Payments(
        order: order ?? _order,
        paymentMethod: paymentMethod ?? _paymentMethod,
        amount: amount ?? _amount,
        balanceAmount: balanceAmount ?? _balanceAmount,
        status: status ?? _status,
        createdAt: createdAt ?? _createdAt,
        id: id ?? _id,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get order => _order;
  String? get paymentMethod => _paymentMethod;
  num? get amount => _amount;
  num? get balanceAmount => _balanceAmount;
  String? get status => _status;
  String? get createdAt => _createdAt;
  String? get id => _id;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['order'] = _order;
    map['paymentMethod'] = _paymentMethod;
    map['amount'] = _amount;
    map['balanceAmount'] = _balanceAmount;
    map['status'] = _status;
    map['createdAt'] = _createdAt;
    map['_id'] = _id;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}

class Invoice {
  Invoice({
    String? businessName,
    String? address,
    String? phone,
    String? gstNumber,
    String? currencySymbol,
    String? printType,
    List<Items>? items,
    num? subtotal,
    num? salesTax,
    num? total,
    String? orderNumber,
    String? orderStatus,
    String? date,
    String? paidBy,
    String? transactionId,
    String? tableNo,
  }) {
    _businessName = businessName;
    _address = address;
    _phone = phone;
    _gstNumber = gstNumber;
    _currencySymbol = currencySymbol;
    _printType = printType;
    _items = items;
    _subtotal = subtotal;
    _salesTax = salesTax;
    _total = total;
    _orderNumber = orderNumber;
    _orderStatus = orderStatus;
    _date = date;
    _paidBy = paidBy;
    _transactionId = transactionId;
    _tableNo = tableNo;
  }

  Invoice.fromJson(dynamic json) {
    _businessName = json['businessName'];
    _address = json['address'];
    _phone = json['phone'];
    _gstNumber = json['gstNumber'];
    _currencySymbol = json['currencySymbol'];
    _printType = json['printType'];
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(Items.fromJson(v));
      });
    }
    _subtotal = json['subtotal'];
    _salesTax = json['salesTax'];
    _total = json['total'];
    _orderNumber = json['orderNumber'];
    _orderStatus = json['orderStatus'];
    _date = json['date'];
    _paidBy = json['paidBy'];
    _transactionId = json['transactionId'];
    _tableNo = json['tableNo'];
  }
  String? _businessName;
  String? _address;
  String? _phone;
  String? _gstNumber;
  String? _currencySymbol;
  String? _printType;
  List<Items>? _items;
  num? _subtotal;
  num? _salesTax;
  num? _total;
  String? _orderNumber;
  String? _orderStatus;
  String? _date;
  String? _paidBy;
  String? _transactionId;
  String? _tableNo;
  Invoice copyWith({
    String? businessName,
    String? address,
    String? phone,
    String? gstNumber,
    String? currencySymbol,
    String? printType,
    List<Items>? items,
    num? subtotal,
    num? salesTax,
    num? total,
    String? orderNumber,
    String? orderStatus,
    String? date,
    String? paidBy,
    String? transactionId,
    String? tableNo,
  }) =>
      Invoice(
        businessName: businessName ?? _businessName,
        address: address ?? _address,
        phone: phone ?? _phone,
        gstNumber: gstNumber ?? _gstNumber,
        currencySymbol: currencySymbol ?? _currencySymbol,
        printType: printType ?? _printType,
        items: items ?? _items,
        subtotal: subtotal ?? _subtotal,
        salesTax: salesTax ?? _salesTax,
        total: total ?? _total,
        orderNumber: orderNumber ?? _orderNumber,
        orderStatus: orderStatus ?? _orderStatus,
        date: date ?? _date,
        paidBy: paidBy ?? _paidBy,
        transactionId: transactionId ?? _transactionId,
        tableNo: tableNo ?? _tableNo,
      );
  String? get businessName => _businessName;
  String? get address => _address;
  String? get phone => _phone;
  String? get gstNumber => _gstNumber;
  String? get currencySymbol => _currencySymbol;
  String? get printType => _printType;
  List<Items>? get items => _items;
  num? get subtotal => _subtotal;
  num? get salesTax => _salesTax;
  num? get total => _total;
  String? get orderNumber => _orderNumber;
  String? get orderStatus => _orderStatus;
  String? get date => _date;
  String? get paidBy => _paidBy;
  String? get transactionId => _transactionId;
  String? get tableNo => _tableNo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['businessName'] = _businessName;
    map['address'] = _address;
    map['phone'] = _phone;
    map['gstNumber'] = _gstNumber;
    map['currencySymbol'] = _currencySymbol;
    map['printType'] = _printType;
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    map['subtotal'] = _subtotal;
    map['salesTax'] = _salesTax;
    map['total'] = _total;
    map['orderNumber'] = _orderNumber;
    map['orderStatus'] = _orderStatus;
    map['date'] = _date;
    map['paidBy'] = _paidBy;
    map['transactionId'] = _transactionId;
    map['tableNo'] = _tableNo;
    return map;
  }
}

/// name : "White forest"
/// basePrice : 56.49666666666667
/// qty : 3
/// taxPrice : 34.11021240191162
/// totalPrice : 223.60021240191162

// class Items {
//   Items({
//     String? name,
//     num? basePrice,
//     num? qty,
//     num? taxPrice,
//     num? totalPrice,
//   }) {
//     _name = name;
//     _basePrice = basePrice;
//     _qty = qty;
//     _taxPrice = taxPrice;
//     _totalPrice = totalPrice;
//   }
//
//   Items.fromJson(dynamic json) {
//     _name = json['name'];
//     _basePrice = json['basePrice'];
//     _qty = json['qty'];
//     _taxPrice = json['taxPrice'];
//     _totalPrice = json['totalPrice'];
//   }
//   String? _name;
//   num? _basePrice;
//   num? _qty;
//   num? _taxPrice;
//   num? _totalPrice;
//   Items copyWith({
//     String? name,
//     num? basePrice,
//     num? qty,
//     num? taxPrice,
//     num? totalPrice,
//   }) =>
//       Items(
//         name: name ?? _name,
//         basePrice: basePrice ?? _basePrice,
//         qty: qty ?? _qty,
//         taxPrice: taxPrice ?? _taxPrice,
//         totalPrice: totalPrice ?? _totalPrice,
//       );
//   String? get name => _name;
//   num? get basePrice => _basePrice;
//   num? get qty => _qty;
//   num? get taxPrice => _taxPrice;
//   num? get totalPrice => _totalPrice;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     map['basePrice'] = _basePrice;
//     map['qty'] = _qty;
//     map['taxPrice'] = _taxPrice;
//     map['totalPrice'] = _totalPrice;
//     return map;
//   }
// }

/// _id : "687641b8ff518ce12520c9b3"
/// orderNumber : "ORD-20250715-0008"
/// items : [{"product":"685b7fa98753e2ece10465e7","name":"White forest","quantity":3,"unitPrice":56.49666666666667,"addons":[{"addon":"60a7e4f8a2f8f3b6e8d9b7c5","name":"Cheese","price":10,"_id":"687641b8ff518ce12520c9b5"}],"tax":0,"subtotal":189.49,"_id":"687641b8ff518ce12520c9b4"}]
/// subtotal : 169.49
/// tax : 30.51
/// total : 200
/// createdAt : "2025-07-15T11:10:59.577Z"

class Order {
  Order({
    String? id,
    String? orderNumber,
    List<Items>? items,
    num? subtotal,
    num? tax,
    num? total,
    String? createdAt,
  }) {
    _id = id;
    _orderNumber = orderNumber;
    _items = items;
    _subtotal = subtotal;
    _tax = tax;
    _total = total;
    _createdAt = createdAt;
  }

  Order.fromJson(dynamic json) {
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
    _createdAt = json['createdAt'];
  }
  String? _id;
  String? _orderNumber;
  List<Items>? _items;
  num? _subtotal;
  num? _tax;
  num? _total;
  String? _createdAt;
  Order copyWith({
    String? id,
    String? orderNumber,
    List<Items>? items,
    num? subtotal,
    num? tax,
    num? total,
    String? createdAt,
  }) =>
      Order(
        id: id ?? _id,
        orderNumber: orderNumber ?? _orderNumber,
        items: items ?? _items,
        subtotal: subtotal ?? _subtotal,
        tax: tax ?? _tax,
        total: total ?? _total,
        createdAt: createdAt ?? _createdAt,
      );
  String? get id => _id;
  String? get orderNumber => _orderNumber;
  List<Items>? get items => _items;
  num? get subtotal => _subtotal;
  num? get tax => _tax;
  num? get total => _total;
  String? get createdAt => _createdAt;

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
    map['createdAt'] = _createdAt;
    return map;
  }
}

/// product : "685b7fa98753e2ece10465e7"
/// name : "White forest"
/// quantity : 3
/// unitPrice : 56.49666666666667
/// addons : [{"addon":"60a7e4f8a2f8f3b6e8d9b7c5","name":"Cheese","price":10,"_id":"687641b8ff518ce12520c9b5"}]
/// tax : 0
/// subtotal : 189.49
/// _id : "687641b8ff518ce12520c9b4"

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
/// _id : "687641b8ff518ce12520c9b5"

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
