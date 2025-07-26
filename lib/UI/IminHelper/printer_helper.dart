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

  String centerTextTamil(String text, int lineWidth) {
    final plainText = text.replaceAll(RegExp(r'\x1B.*?\x00'), '');

    int padding = ((lineWidth - plainText.length) / 2).floor();
    if (padding < 0) padding = 0;

    return ' ' * padding + text;
  }

  String formatAddress(String rawAddress, int lineWidth) {
    List<String> addressLines = [];

    for (int i = 0; i < rawAddress.length; i += lineWidth) {
      int end = (i + lineWidth < rawAddress.length)
          ? i + lineWidth
          : rawAddress.length;
      String line = rawAddress.substring(i, end);
      int padding = ((lineWidth - line.length) / 2).floor();
      addressLines.add(' ' * padding + line);
    }

    return addressLines.join('\n');
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

  String formatLabelOnlyRow(String label, {bool isBold = false}) {
    return isBold ? label.toUpperCase() : label;
  }

  String formatItemRow(String name, int qty, double price, double total) {
    String qtyStr = qty.toString();
    String priceStr = '₹${price.toStringAsFixed(2)}';
    String totalStr = '₹${total.toStringAsFixed(2)}';

    int nameWidth = 14;
    int qtyWidth = 5;
    int priceWidth = 8;
    int totalWidth = 8;

    List<String> nameLines = [];
    for (int i = 0; i < name.length; i += nameWidth) {
      int end = (i + nameWidth < name.length) ? i + nameWidth : name.length;
      nameLines.add(name.substring(i, end));
    }

    String result = '';
    for (int i = 0; i < nameLines.length; i++) {
      if (i == 0) {
        String paddedName = nameLines[i].padRight(nameWidth);
        String paddedQty = qtyStr.padLeft(qtyWidth);
        String paddedPrice = priceStr.padLeft(priceWidth);
        String paddedTotal = totalStr.padLeft(totalWidth);
        result += '$paddedName$paddedQty$paddedPrice$paddedTotal';
      } else {
        result += '\n${nameLines[i]}';
      }
    }

    return result;
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
    String formattedOrderType =
        orderType == 'DINE-IN' ? 'DINE-IN' : 'TAKE-AWAY';
    String tableName =
        getProperty(invoice, 'tableName', 'N/A')?.toString() ?? 'N/A';
    String formattedTableName = orderType == 'DINE-IN' ? tableName : 'N/A';
    double subtotal = (getProperty(order, 'subtotal', 0.0) ?? 0.0).toDouble();
    double tax = (getProperty(order, 'tax', 0.0) ?? 0.0).toDouble();
    double total = (getProperty(order, 'total', 0.0) ?? 0.0).toDouble();

    String businessName =
        getProperty(invoice, 'businessName', 'Restaurant')?.toString() ??
            'Restaurant';
    String address =
        getProperty(invoice, 'address', 'N/A')?.toString() ?? 'N/A';

    String phone = getProperty(invoice, 'phone', 'N/A')?.toString() ?? 'N/A';
    // String gstNumber =
    //     getProperty(invoice, 'gstNumber', 'N/A')?.toString() ?? 'N/A';
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
        '${'Item'.padRight(14)}${'Qty'.padLeft(5)}${'Price'.padLeft(8)}${'Total'.padLeft(8)}';

    String separator = '-' * headerRow.length;
    String receipt = '''
${centerTextTamil("ஒரே ஒரு முறை சுவைத்து பாருங்கள்", 28)}
${centerText(businessName, 32)}
${formatAddress(address, 32)}
${centerText("Phone: $phone", 32)}

Order#: $orderNumber
$formattedDate
Type: $formattedOrderType
Table: $formattedTableName

$separator
$headerRow
$separator
${formatOrderItems(order)}
$separator
${formatAmountRow('Subtotal', subtotal)}
${formatAmountRow('Tax', tax)}
${formatAmountRow('TOTAL', total, isBold: true)}
${formatLabelOnlyRow('Paid By: $paidBy')}

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
