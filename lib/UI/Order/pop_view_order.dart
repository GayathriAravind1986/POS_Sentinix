import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
                      TextSpan(text: "Roja Restaurant"),
                    ])),
                    const SizedBox(height: 4),
                    Text("Address:N/A"),
                    Text("Phone:  N/A"),
                    Text("GST Number: N/A"),
                    Text(
                        "Order ID:${widget.getViewOrderModel.data!.orderNumber}"),
                    Text("Date:363688"),
                    Text("Type:${widget.getViewOrderModel.data!.orderType}"),
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
                    Text("Transaction ID:  'N/A'"),
                    const Divider(),
                    const Text("Items:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ...widget.getViewOrderModel.data!.items!
                        .map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                  "${item.name} x${item.quantity} - ₹${item.subtotal!.toStringAsFixed(2)}"),
                            )),
                    const SizedBox(height: 5),
                    Text(
                        "Total: ₹${widget.getViewOrderModel.data!.subtotal!.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                    const Divider(),
                    Text(
                        "Subtotal: ₹${widget.getViewOrderModel.data!.subtotal!.toStringAsFixed(2)}"),
                    Text(
                        "Tax: ₹${widget.getViewOrderModel.data!.tax!.toStringAsFixed(2)}"),
                    Text(
                        "Total: ₹${widget.getViewOrderModel.data!.total!.toStringAsFixed(2)}"),
                    // if(getViewOrderModel.data!.)
                    Text(
                        "PaidBy:CARD : ₹ ${widget.getViewOrderModel.data!.total!.toStringAsFixed(2)}"),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final order = widget.getViewOrderModel.data!;
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
Date: ${DateTime.now().toString().substring(0, 16)}
Status: ${order.orderStatus}
-----------------------------
Items:
${order.items!.map((item) => "${item.name} x${item.quantity}  ₹${item.subtotal!.toStringAsFixed(2)}").join("\n")}
-----------------------------
Subtotal: ₹${order.subtotal!.toStringAsFixed(2)}
Tax: ₹${order.tax!.toStringAsFixed(2)}
Total: ₹${order.total!.toStringAsFixed(2)}
-----------------------------
Payment: CARD ₹${order.total!.toStringAsFixed(2)}
Thank you!
''';

                            await printerService.init();
                            await printerService.printText(receipt);
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
