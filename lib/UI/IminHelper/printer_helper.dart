import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String formatReceiptForMiniPrinter(dynamic order, dynamic invoice) {
  dynamic getProperty(dynamic obj, String property, [dynamic defaultValue]) {
    try {
      if (obj == null) return defaultValue;
      if (obj is Map) {
        return obj[property] ?? defaultValue;
      }
      try {
        final json = obj.toJson();
        if (json is Map) {
          return json[property] ?? defaultValue;
        }
      } catch (e) {
        // Object doesn't have toJson method
      }

      try {
        return obj.runtimeType.toString().contains(property)
            ? obj
            : defaultValue;
      } catch (e) {
        // Continue to return default
      }

      return defaultValue;
    } catch (e) {
      debugPrint('Error getting property $property: $e');
      return defaultValue;
    }
  }

  String centerText(String text, int width) {
    if (text.length >= width) return text;
    int leftPadding = ((width - text.length) / 2).floor();
    return ' ' * leftPadding + text;
  }

  String formatAmountRow(String label, double amount, {bool isBold = false}) {
    String amountStr = '₹${amount.toStringAsFixed(2)}';
    int totalWidth = 32;
    int spaces = totalWidth - label.length - amountStr.length;
    if (spaces < 1) {
      spaces = 1;
    }

    String row = label + ' ' * spaces + amountStr;
    return isBold ? row.toUpperCase() : row;
  }

  String formatItemRow(String name, int qty, double price, double total) {
    String qtyStr = qty.toString();
    String priceStr = '₹${price.toStringAsFixed(2)}';
    String totalStr = '₹${total.toStringAsFixed(2)}';

    int nameWidth = 16; // width for name
    int qtyWidth = 3;
    int priceWidth = 8;
    int totalWidth = 8;

    String truncatedName =
        name.length > nameWidth ? '${name.substring(0, nameWidth - 1)}…' : name;
    String paddedName = truncatedName.padRight(nameWidth);
    String paddedQty = qtyStr.padLeft(qtyWidth);
    String paddedPrice = priceStr.padLeft(priceWidth);
    String paddedTotal = totalStr.padLeft(totalWidth);

    return '$paddedName $paddedQty $paddedPrice $paddedTotal';
  }

  String formatOrderItems(dynamic order) {
    try {
      dynamic items;

      if (order is Map) {
        items = order['items'] ?? order['orderItems'] ?? [];
      } else {
        try {
          items = order.items ?? order.orderItems ?? [];
        } catch (e) {
          try {
            final json = order.toJson();
            items = json['items'] ?? json['orderItems'] ?? [];
          } catch (e) {
            items = [];
          }
        }
      }

      if (items == null || (items is List && items.isEmpty)) {
        return 'No items';
      }

      if (items is! List) {
        return 'Invalid items format';
      }

      return items.map<String>((item) {
        try {
          String name = getProperty(item, 'name', 'Unknown Item')?.toString() ??
              'Unknown Item';
          int quantity = (getProperty(item, 'quantity', 0) ?? 0).toInt();
          double unitPrice =
              (getProperty(item, 'unitPrice', 0.0) ?? 0.0).toDouble();
          double itemTotal = quantity * unitPrice;

          return formatItemRow(name, quantity, unitPrice, itemTotal);
        } catch (e) {
          debugPrint('Error formatting item: $e');
          return 'Error formatting item';
        }
      }).join('\n');
    } catch (e) {
      debugPrint('Error formatting order items: $e');
      return 'Error loading items';
    }
  }

  try {
    debugPrint('Order type: ${order.runtimeType}');
    debugPrint('Invoice type: ${invoice.runtimeType}');

    String orderNumber =
        getProperty(order, 'orderNumber', 'N/A')?.toString() ?? 'N/A';
    String orderType =
        getProperty(order, 'orderType', 'TAKE-AWAY')?.toString() ?? 'TAKE-AWAY';
    String tableName =
        getProperty(order, 'tableName', 'N/A')?.toString() ?? 'N/A';
    double subtotal = (getProperty(order, 'subtotal', 0.0) ?? 0.0).toDouble();
    double tax = (getProperty(order, 'tax', 0.0) ?? 0.0).toDouble();
    double total = (getProperty(order, 'total', 0.0) ?? 0.0).toDouble();

    String businessName =
        getProperty(invoice, 'businessName', 'Restaurant')?.toString() ??
            'Restaurant';
    String address =
        getProperty(invoice, 'address', 'N/A')?.toString() ?? 'N/A';
    String phone = getProperty(invoice, 'phone', 'N/A')?.toString() ?? 'N/A';
    String gstNumber =
        getProperty(invoice, 'gstNumber', 'N/A')?.toString() ?? 'N/A';
    String paidBy =
        getProperty(invoice, 'paidBy', 'Cash')?.toString() ?? 'Cash';

    String formattedDate;
    try {
      String dateStr =
          getProperty(invoice, 'date', DateTime.now().toString())?.toString() ??
              DateTime.now().toString();
      DateTime dateTime;

      try {
        dateTime = DateFormat('M/d/yyyy, h:mm:ss a').parse(dateStr);
      } catch (e) {
        try {
          dateTime = DateTime.parse(dateStr);
        } catch (e) {
          dateTime = DateTime.now();
        }
      }

      formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
    } catch (e) {
      formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
    }
    String headerRow =
        '${'Item'.padRight(16)} ${'Qty'.padLeft(3)} ${'Price'.padLeft(8)} ${'Total'.padLeft(8)}';

    String separator = '-' * headerRow.length;
    String receipt = '''
${centerText(businessName, 32)}
${centerText(address, 32)}
${centerText("Phone: $phone", 32)}
${centerText("GST: $gstNumber", 32)}

Order#: $orderNumber
$formattedDate
Type: $orderType
Table: ${orderType == 'DINE-IN' ? tableName : 'N/A'}

$separator
$headerRow
$separator
${formatOrderItems(order)}
$separator
${formatAmountRow('Subtotal', subtotal)}
${formatAmountRow('Tax', tax)}
${formatAmountRow('TOTAL', total, isBold: true)}
${formatAmountRow('Paid By: $paidBy', total)}

${centerText("Thank You, Visit Again!", 32)}
''';

    return receipt;
  } catch (e) {
    debugPrint('Error formatting receipt: $e');
    return '''
${centerText("Receipt Error", 32)}
${centerText("Unable to format receipt", 32)}
Error: $e

Order completed successfully
Thank you for your business!
''';
  }
}
