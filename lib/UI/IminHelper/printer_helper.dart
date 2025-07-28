import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

// String formatReceiptForMiniPrinter(dynamic order, dynamic invoice) {
//   dynamic getProperty(dynamic obj, String property, [dynamic defaultValue]) {
//     try {
//       if (obj == null) return defaultValue;
//       if (obj is Map) {
//         return obj[property] ?? defaultValue;
//       }
//       try {
//         final json = obj.toJson();
//         if (json is Map) {
//           return json[property] ?? defaultValue;
//         }
//       } catch (e) {
//         // Object doesn't have toJson method
//       }
//
//       try {
//         return obj.runtimeType.toString().contains(property)
//             ? obj
//             : defaultValue;
//       } catch (e) {
//         // Continue to return default
//       }
//
//       return defaultValue;
//     } catch (e) {
//       debugPrint('Error getting property $property: $e');
//       return defaultValue;
//     }
//   }
//
//   String centerText(String text, int width) {
//     if (text.length >= width) return text;
//     int leftPadding = ((width - text.length) / 2).floor();
//     return ' ' * leftPadding + text;
//   }
//
//   String centerTamilText(String text, int lineWidth) {
//     int charCount = text.runes.length;
//     int padding = ((lineWidth - charCount) / 2).floor();
//     if (padding < 0) padding = 0;
//     return ' ' * padding + text;
//   }
//
//   String formatAddress(String rawAddress, int lineWidth) {
//     List<String> addressLines = [];
//
//     for (int i = 0; i < rawAddress.length; i += lineWidth) {
//       int end = (i + lineWidth < rawAddress.length)
//           ? i + lineWidth
//           : rawAddress.length;
//       String line = rawAddress.substring(i, end);
//       int padding = ((lineWidth - line.length) / 2).floor();
//       addressLines.add(' ' * padding + line);
//     }
//
//     return addressLines.join('\n');
//   }
//
//   String formatAmountRow(String label, double amount, {bool isBold = false}) {
//     String amountStr = '₹${amount.toStringAsFixed(2)}';
//     int totalWidth = 32;
//     int spaces = totalWidth - label.length - amountStr.length;
//     if (spaces < 1) {
//       spaces = 1;
//     }
//
//     String row = label + ' ' * spaces + amountStr;
//     return isBold ? row.toUpperCase() : row;
//   }
//
//   String formatLabelOnlyRow(String label, {bool isBold = false}) {
//     return isBold ? label.toUpperCase() : label;
//   }
//
//   String formatItemRow(String name, int qty, double price, double total) {
//     String qtyStr = qty.toString();
//     String priceStr = '₹${price.toStringAsFixed(2)}';
//     String totalStr = '₹${total.toStringAsFixed(2)}';
//
//     int nameWidth = 14;
//     int qtyWidth = 5;
//     int priceWidth = 8;
//     int totalWidth = 8;
//
//     List<String> nameLines = [];
//     for (int i = 0; i < name.length; i += nameWidth) {
//       int end = (i + nameWidth < name.length) ? i + nameWidth : name.length;
//       nameLines.add(name.substring(i, end));
//     }
//
//     String result = '';
//     for (int i = 0; i < nameLines.length; i++) {
//       if (i == 0) {
//         String paddedName = nameLines[i].padRight(nameWidth);
//         String paddedQty = qtyStr.padLeft(qtyWidth);
//         String paddedPrice = priceStr.padLeft(priceWidth);
//         String paddedTotal = totalStr.padLeft(totalWidth);
//         result += '$paddedName$paddedQty$paddedPrice$paddedTotal';
//       } else {
//         result += '\n${nameLines[i]}';
//       }
//     }
//
//     return result;
//   }
//
//   String formatOrderItems(dynamic order) {
//     try {
//       dynamic items;
//
//       if (order is Map) {
//         items = order['items'] ?? order['orderItems'] ?? [];
//       } else {
//         try {
//           items = order.items ?? order.orderItems ?? [];
//         } catch (e) {
//           try {
//             final json = order.toJson();
//             items = json['items'] ?? json['orderItems'] ?? [];
//           } catch (e) {
//             items = [];
//           }
//         }
//       }
//
//       if (items == null || (items is List && items.isEmpty)) {
//         return 'No items';
//       }
//
//       if (items is! List) {
//         return 'Invalid items format';
//       }
//
//       return items.map<String>((item) {
//         try {
//           String name = getProperty(item, 'name', 'Unknown Item')?.toString() ??
//               'Unknown Item';
//           int quantity = (getProperty(item, 'quantity', 0) ?? 0).toInt();
//           double unitPrice =
//               (getProperty(item, 'unitPrice', 0.0) ?? 0.0).toDouble();
//           double itemTotal = quantity * unitPrice;
//
//           return formatItemRow(name, quantity, unitPrice, itemTotal);
//         } catch (e) {
//           debugPrint('Error formatting item: $e');
//           return 'Error formatting item';
//         }
//       }).join('\n\n');
//     } catch (e) {
//       debugPrint('Error formatting order items: $e');
//       return 'Error loading items';
//     }
//   }
//
//   try {
//     debugPrint('Order type: ${order.runtimeType}');
//     debugPrint('Invoice type: ${invoice.runtimeType}');
//
//     String orderNumber =
//         getProperty(order, 'orderNumber', 'N/A')?.toString() ?? 'N/A';
//     String orderType =
//         getProperty(order, 'orderType', 'TAKE-AWAY')?.toString() ?? 'TAKE-AWAY';
//     String formattedOrderType =
//         orderType == 'DINE-IN' ? 'DINE-IN' : 'TAKE-AWAY';
//     String tableName =
//         getProperty(invoice, 'tableName', 'N/A')?.toString() ?? 'N/A';
//     String formattedTableName = orderType == 'DINE-IN' ? tableName : 'N/A';
//     double subtotal = (getProperty(order, 'subtotal', 0.0) ?? 0.0).toDouble();
//     double tax = (getProperty(order, 'tax', 0.0) ?? 0.0).toDouble();
//     double total = (getProperty(order, 'total', 0.0) ?? 0.0).toDouble();
//
//     String businessName =
//         getProperty(invoice, 'businessName', 'Restaurant')?.toString() ??
//             'Restaurant';
//     String address =
//         getProperty(invoice, 'address', 'N/A')?.toString() ?? 'N/A';
//
//     String phone = getProperty(invoice, 'phone', 'N/A')?.toString() ?? 'N/A';
//     // String gstNumber =
//     //     getProperty(invoice, 'gstNumber', 'N/A')?.toString() ?? 'N/A';
//     String paidBy =
//         getProperty(invoice, 'paidBy', 'Cash')?.toString() ?? 'Cash';
//
//     String formattedDate;
//     try {
//       String dateStr =
//           getProperty(invoice, 'date', DateTime.now().toString())?.toString() ??
//               DateTime.now().toString();
//       DateTime dateTime;
//
//       try {
//         dateTime = DateFormat('M/d/yyyy, h:mm:ss a').parse(dateStr);
//       } catch (e) {
//         try {
//           dateTime = DateTime.parse(dateStr);
//         } catch (e) {
//           dateTime = DateTime.now();
//         }
//       }
//
//       formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
//     } catch (e) {
//       formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
//     }
//     String headerRow =
//         '${'Item'.padRight(13)}${'Qty'.padLeft(4)}${'Price'.padLeft(7)}${'Total'.padLeft(7)}';
//
//     String separator = '-' * headerRow.length;
//     String receipt = '''
// ${centerTamilText("ஒரே ஒரு முறை சுவைத்து பாருங்கள்", 32)}
// ${centerText(businessName, 32)}
// ${formatAddress(address, 32)}
// ${centerText("Phone: $phone", 32)}
//
// Order#: $orderNumber
// $formattedDate
// Type: $formattedOrderType
// Table: $formattedTableName
//
// $separator
// $headerRow
// $separator
// ${formatOrderItems(order)}
// $separator
// ${formatAmountRow('Subtotal', subtotal)}
// ${formatAmountRow('Tax', tax)}
// ${formatAmountRow('TOTAL', total, isBold: true)}
// ${formatLabelOnlyRow('Paid By: $paidBy')}
//
// ${centerText("Thank You, Visit Again!", 32)}
// ''';
//
//     return receipt;
//   } catch (e) {
//     debugPrint('Error formatting receipt: $e');
//     return '''
// ${centerText("Receipt Error", 32)}
// ${centerText("Unable to format receipt", 32)}
// Error: $e
//
// Order completed successfully
// Thank you for your business!
// ''';
//   }
// }

Widget getReceiptWidget({
  required String businessName,
  required String tamilTagline,
  required String address,
  required String phone,
  required List<Map<String, dynamic>> items,
  required double subtotal,
  required double tax,
  required double total,
  required String orderNumber,
  required String tableName,
  required String orderType,
  required String paidBy,
  required String date,
}) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  tamilTagline,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  businessName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Phone: $phone",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(),
          _buildLabelRow("Order#: ", orderNumber),
          _buildLabelRow("Date: ", date),
          _buildLabelRow("Type: ", orderType),
          _buildLabelRow("Table: ", orderType == 'DINE-IN' ? tableName : "N/A"),
          Divider(),
          _buildHeaderRow(),
          Divider(),
          ...items.map((item) => _buildItemRow(
                item['name'],
                item['qty'],
                item['price'],
                item['total'],
              )),
          Divider(),
          _buildTotalRow("Subtotal", subtotal),
          _buildTotalRow("Tax", tax),
          _buildTotalRow("TOTAL", total, isBold: true),
          Divider(),
          Text("Paid via: $paidBy"),
          const SizedBox(height: 8),
          const Center(
              child: Text(
            "Thank You, Visit Again!",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ],
      ),
    ),
  );
}

Widget _buildLabelRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value),
      ],
    ),
  );
}

Widget _buildHeaderRow() {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
          flex: 4,
          child: Text("Item",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center)),
      Expanded(
          flex: 2,
          child: Text("Qty",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center)),
      Expanded(
          flex: 3,
          child: Text("Price",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center)),
      Expanded(
          flex: 3,
          child: Text("Total",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end)),
    ],
  );
}

Widget _buildItemRow(String name, int qty, double price, double total) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(flex: 4, child: Text(name)),
      Expanded(flex: 2, child: Text('$qty', textAlign: TextAlign.center)),
      Expanded(
          flex: 3,
          child: Text('₹${price.toStringAsFixed(2)}',
              textAlign: TextAlign.center)),
      Expanded(
          flex: 3,
          child:
              Text('₹${total.toStringAsFixed(2)}', textAlign: TextAlign.end)),
    ],
  );
}

Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text('₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    ),
  );
}

Future<Uint8List?> captureReceiptAsImage(GlobalKey key) async {
  try {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (e) {
    print("Error capturing image: $e");
    return null;
  }
}
