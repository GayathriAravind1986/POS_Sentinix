Map<String, dynamic> buildOrderPayload({
  required List<Map<String, dynamic>> billingItems,
  required String tableNo,
  required String orderStatus,
  required String orderType,
  required double paymentAmount,
  required double basePrice,
  required double subtotal,
  required double totalTax,
  required double total,
  required String paymentMethod,
}) {
  // double subtotal = 0;
  // double totalTax = 0;

  List<Map<String, dynamic>> items = billingItems.map((item) {
    // double unitPrice = (item['basePrice'] ?? 0).toDouble();
    int qty = (item['qty'] ?? 1);

    List<Map<String, dynamic>> addons =
        (item['selectedAddons'] ?? []).map<Map<String, dynamic>>((addon) {
      return {
        "addon": addon["_id"],
        "name": addon["name"],
        "price": addon["price"] ?? 0,
      };
    }).toList();

    double addonTotal =
        addons.fold(0.0, (sum, addon) => sum + (addon['price'] ?? 0.0));
    // double itemSubtotal = (unitPrice + addonTotal) * qty;
    // double itemTax = itemSubtotal * 0.05;

    //subtotal += itemSubtotal;
    //totalTax += itemTax;
    // totalTax = item["totalTax"];

    return {
      "product": item["_id"],
      "name": item["name"],
      "quantity": qty,
      "unitPrice": basePrice,
      "addons": addons,
      "subtotal": subtotal,
    };
  }).toList();

  //double total = subtotal + totalTax;

  return {
    "date": DateTime.now().toIso8601String(),
    "items": items,
    "payments": [
      {
        "amount": paymentAmount,
        "balanceAmount": 0,
        "method": paymentMethod,
      }
    ],
    "orderStatus": orderStatus,
    "orderType": orderType,
    "subtotal": subtotal,
    "tableNo": tableNo,
    "tax": totalTax,
    "total": total,
  };
}
