import 'package:flutter/material.dart';
import 'package:simple/services/printer_service.dart';
import 'package:simple/services/mock_printer_service.dart';

class MockSplitPaymentTest extends StatefulWidget {
  const MockSplitPaymentTest({super.key});

  @override
  State<MockSplitPaymentTest> createState() => _MockSplitPaymentTestState();
}

class _MockSplitPaymentTestState extends State<MockSplitPaymentTest> {
  late final PrinterService printer;

  @override
  void initState() {
    super.initState();
    printer = MockPrinterService();
    printer.init();
    print("Split Payment Test initialized");
  }

  Future<void> _printSplitBill() async {
    try {
      await printer.setAlignment("center");
      await printer.printText(" ROJA RESTAURANT\n");
      await printer.setAlignment("left");

      await printer.printText("Customer: Malar Vizhi\n");
      await printer.printText("Table: 4 (Dine In)\n");
      await printer.printText("-----------------------------\n");

      await printer.printText("1 x Veg Burger      ₹59.32\n");
      await printer.printText("SGST (9%)            ₹5.34\n");
      await printer.printText("CGST (9%)            ₹5.34\n");

      await printer.printText("-----------------------------\n");
      await printer.printText("Total               ₹70.00\n\n");

      await printer.printText(" Payment Summary:\n");
      await printer.printText("- Cash Paid         ₹50.00\n");
      await printer.printText("- UPI Paid          ₹20.00\n");

      await printer.printText("-----------------------------\n");
      await printer.printText("Thank You! Visit Again!\n\n");

      await printer.printAndLineFeed();
      await printer.cut();

      print("Split payment printed");
    } catch (e) {
      print("Print error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Split Payment (Mock)"),
        backgroundColor: const Color(0xFF522F1F),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _printSplitBill,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF522F1F),
            minimumSize: const Size(200, 50),
          ),
          child: const Text(
            "Print Split Payment",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
