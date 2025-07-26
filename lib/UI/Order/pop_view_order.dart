import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/imin_abstract.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/mock_imin_printer_chrome.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/real_device_printer.dart';

class OrderInvoiceDialog extends StatefulWidget {
  final GetViewOrderModel getViewOrderModel;

  const OrderInvoiceDialog(this.getViewOrderModel, {super.key});

  @override
  State<OrderInvoiceDialog> createState() => _OrderInvoiceDialogState();
}

class _OrderInvoiceDialogState extends State<OrderInvoiceDialog> {
  late IPrinterService printerService;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      printerService = MockPrinterService();
      debugPrint("Using MockPrinterService (Web)");
    } else if (Platform.isAndroid) {
      printerService = RealPrinterService();
      debugPrint("Using RealPrinterService (Android)");
    } else {
      printerService = MockPrinterService();
      debugPrint("Using fallback MockPrinterService");
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.getViewOrderModel.data!.invoice;
    var size = MediaQuery.of(context).size;
    return widget.getViewOrderModel.data == null
        ? Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
            alignment: Alignment.center,
            child: Text(
              "No Orders found",
              style: MyTextStyle.f16(
                greyColor,
                weight: FontWeight.w500,
              ),
            ))
        : Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400, // 🔽 reduce width here
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Order Invoice",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text.rich(TextSpan(children: [
                      const TextSpan(
                          text: "Shop: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: invoice!.businessName ?? 'N/A'),
                    ])),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Address: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            invoice.address ?? 'N/A',
                            style: TextStyle(color: Colors.black),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Phone:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(invoice.phone ?? 'N/A'),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     Text("GST Number:",
                    //         style: TextStyle(fontWeight: FontWeight.bold)),
                    //     Text(invoice.gstNumber ?? 'N/A'),
                    //   ],
                    // ),
                    Row(
                      children: [
                        Text("Order ID:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(invoice.orderNumber.toString()),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Date:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('dd/MM/yyyy hh:mm a').format(
                            DateFormat('M/d/yyyy, h:mm:ss a')
                                .parse(invoice.date.toString()))),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Type:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${widget.getViewOrderModel.data!.orderType}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Table:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(invoice.tableNum ?? 'N/A'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Status: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${widget.getViewOrderModel.data!.orderStatus}",
                            style: TextStyle(
                              color:
                                  widget.getViewOrderModel.data!.orderStatus ==
                                          "COMPLETED"
                                      ? greenColor
                                      : redColor,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    Text("Transaction ID:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${invoice.transactionId ?? 'N/A'} "),
                    const Divider(),
                    const Text("Items:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ...invoice.invoiceItems!.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "${item.name} x${item.qty} - ${invoice.currencySymbol}${invoice.subtotal!.toStringAsFixed(2)}${item.isAddon == true ? " (Addon)" : ""}",
                            style: TextStyle(
                              color: item.isAddon == true
                                  ? greyColor[600]
                                  : blackColor,
                            ),
                          ),
                        )),
                    const SizedBox(height: 5),
                    Text("Total: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        "${invoice.currencySymbol}${invoice.subtotal!.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      children: [
                        Text("Subtotal:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "${invoice.currencySymbol}${invoice.subtotal!.toStringAsFixed(2)}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Tax:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "${invoice.currencySymbol}${invoice.salesTax!.toStringAsFixed(2)}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Total:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "${invoice.currencySymbol}${invoice.total!.toStringAsFixed(2)}"),
                      ],
                    ),
                    if (widget.getViewOrderModel.data!.orderStatus ==
                        "COMPLETED")
                      Row(
                        children: [
                          Text("PaidBy:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${invoice.paidBy}"),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final order = widget.getViewOrderModel.data!;
                            final invoice =
                                widget.getViewOrderModel.data!.invoice;
                            String centerText(String text, int width) {
                              if (text.length >= width) return text;
                              int leftPadding =
                                  ((width - text.length) / 3).floor();
                              return ' ' * leftPadding + text;
                            }

                            String receipt = '''
${centerText("🧾 ${order.orderType == 'DINE-IN' ? "Dine-in Receipt" : "Takeaway Receipt"}", 32)}
-----------------------------
Order ID: ${order.orderNumber}
Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateFormat('M/d/yyyy, h:mm:ss a').parse(invoice!.date.toString()))}
Status: ${order.orderStatus}
-----------------------------
Items:
${order.items!.map((item) => "${item.name} x${item.quantity}  ₹${item.subtotal!.toStringAsFixed(2)}").join("\n")}
-----------------------------
Subtotal: ₹${order.subtotal!.toStringAsFixed(2)}
Tax: ₹${order.tax!.toStringAsFixed(2)}
Tips: ₹${order.tipAmount!.toStringAsFixed(2)}
Total: ₹${(order.total! + order.tipAmount!).toStringAsFixed(2)}
-----------------------------
Payment: ${invoice.paidBy}
Thank you! Visit Again 🙏
\n\n\n\n\n
''';

                            await printerService.init();
                            receipt = receipt
                                .replaceAll('\r\n', '\n')
                                .replaceAll('\r', '\n');
                            await printerService.printText(receipt);
                            Navigator.pop(context);
                            await Future.delayed(Duration(seconds: 2));
                            await printerService.fullCut();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor),
                          child: const Text("PRINT"),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CLOSE"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ));
  }
}
