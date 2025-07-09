import 'package:flutter/material.dart';
import 'package:simple/services/printer_service.dart';
import 'package:simple/services/mock_printer_service.dart';

class MockTestPrinter extends StatefulWidget {
  const MockTestPrinter({super.key});

  @override
  State<MockTestPrinter> createState() => _MockTestPrinterState();
}

class _MockTestPrinterState extends State<MockTestPrinter> {
  late final PrinterService printer;

  @override
  void initState() {
    super.initState();
    printer = MockPrinterService(); // 👈 Using mock service
    printer.init();
    print("Mock printer test screen initialized");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Mock Printer Test"),
        backgroundColor: const Color(0xFF522F1F),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            print(" Print button tapped");
            try {
              await printer.setAlignment("center");
              await printer.printText("🍽️ MOCK HOTEL XYZ");
              await printer.setAlignment("left");
              await printer.printText("Item: Veg Burger x1");
              await printer.printText("Price: ₹59.32");
              await printer.printAndLineFeed();
              await printer.cut();
              print("Mock print completed");
            } catch (e) {
              print("Print failed: $e");
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF522F1F),
            minimumSize: const Size(200, 50),
          ),
          child: const Text(
            "Print (Mock)",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
