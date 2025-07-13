// // Add these imports at the top
// import 'package:another_imin_printer/another_imin_printer.dart';
// import 'package:another_imin_printer/enums.dart';
// import 'package:another_imin_printer/models/print_style.dart';
// import 'package:flutter/material.dart';
//
// class AnotherIminPrinterHelper {
//   static AnotherIminPrinter? _printer;
//
//   static AnotherIminPrinter get printer {
//     _printer ??= AnotherIminPrinter.instance;
//     return _printer!;
//   }
//
//   // Alternative initialization if needed
//   static Future<void> initializePrinter() async {
//     try {
//       _printer = AnotherIminPrinter.instance;
//       await _printer!.initPrinter();
//       debugPrint('✅ Printer initialized successfully');
//     } catch (e) {
//       debugPrint('❌ Printer initialization failed: $e');
//       rethrow;
//     }
//   }
//
//   // Test basic printer functionality
//   static Future<void> testBasicPrint() async {
//     try {
//       debugPrint('🔄 Starting basic print test...');
//
//       // Initialize printer
//       await printer.initPrinter();
//       debugPrint('✅ Printer initialized');
//
//       // Test simple text print
//       await printer.printText("Test Print\n");
//       debugPrint('✅ Text printed');
//
//       // Test line feed
//       await printer.printText("\n");
//       debugPrint('✅ Line feed works');
//
//       // Test cut
//       await printer.fullCut();
//       debugPrint('✅ Paper cut successful');
//
//       debugPrint('🎉 Basic print test completed successfully!');
//     } catch (e) {
//       debugPrint('❌ Basic print test failed: $e');
//       rethrow;
//     }
//   }
//
//   // Test printer status and capabilities
//   static Future<Map<String, dynamic>> checkPrinterStatus() async {
//     try {
//       debugPrint('🔄 Checking printer status...');
//
//       // Initialize first
//       await printer.initPrinter();
//
//       // Get printer status
//       var status = await printer.getPrinterStatus();
//       debugPrint('📊 Printer status: $status');
//
//       // Check if printer is connected
//       bool isConnected = status == 0; // 0 usually means OK
//
//       return {
//         'isConnected': isConnected,
//         'status': status,
//         'statusMessage': _getStatusMessage(status),
//       };
//     } catch (e) {
//       debugPrint('❌ Status check failed: $e');
//       return {
//         'isConnected': false,
//         'status': -1,
//         'statusMessage': 'Error: $e',
//       };
//     }
//   }
//
//   // Get human-readable status message
//   static String _getStatusMessage(int status) {
//     switch (status) {
//       case 0:
//         return 'Printer Ready';
//       case 1:
//         return 'Printer Busy';
//       case 2:
//         return 'Out of Paper';
//       case 3:
//         return 'Paper Jam';
//       case 4:
//         return 'Printer Error';
//       default:
//         return 'Unknown Status ($status)';
//     }
//   }
//
//   // Test different print styles
//   static Future<void> testPrintStyles() async {
//     try {
//       debugPrint('🔄 Testing print styles...');
//
//       await printer.initPrinter();
//
//       // Test different text sizes
//       await printer.printText(
//         "Normal Size Text\n",
//         printStyle: PrintStyle(
//           textAlign: PrintStyleAlign.left,
//           fontSize: 20,
//         ),
//       );
//
//       await printer.printText(
//         "Large Text\n",
//         printStyle: PrintStyle(
//           textAlign: PrintStyleAlign.center,
//           fontSize: 30,
//         ),
//       );
//
//       await printer.printText(
//         "Bold Text\n",
//         printStyle: PrintStyle(
//           textAlign: PrintStyleAlign.left,
//           fontSize: 20,
//           bold: true,
//         ),
//       );
//
//       // Test line
//       await printer.printText("${'=' * 32}\n");
//
//       // Test 2 columns
//       await printer.print2ColumnsText(
//         leftText: "Item",
//         rightText: "Price",
//       );
//
//       await printer.print2ColumnsText(
//         leftText: "Burger",
//         rightText: "₹59.32",
//       );
//
//       await printer.printText("${'=' * 32}\n");
//
//       await printer.fullCut();
//
//       debugPrint('✅ Print styles test completed');
//     } catch (e) {
//       debugPrint('❌ Print styles test failed: $e');
//       rethrow;
//     }
//   }
//
//   // Test complete receipt printing
//   static Future<void> testFullReceipt() async {
//     try {
//       debugPrint('🔄 Testing full receipt printing...');
//
//       await printer.initPrinter();
//
//       // Header
//       await printer.printText(
//         "🍽️ Roja Restaurant\n",
//         printStyle: PrintStyle(
//           textAlign: PrintStyleAlign.center,
//           fontSize: 28,
//           bold: true,
//         ),
//       );
//
//       await printer.printText(
//         "${'=' * 32}\n",
//         printStyle: PrintStyle(
//           textAlign: PrintStyleAlign.center,
//         ),
//       );
//
//       // Items
//       await printer.printText("Items:\n");
//       await printer.print2ColumnsText(
//         leftText: "Veg Burger x1",
//         rightText: "₹59.32",
//       );
//
//       await printer.print2ColumnsText(
//         leftText: "French Fries x2",
//         rightText: "₹89.50",
//       );
//
//       await printer.printText("${'-' * 32}\n");
//
//       // Totals
//       await printer.print2ColumnsText(
//         leftText: "Subtotal",
//         rightText: "₹148.82",
//       );
//
//       await printer.print2ColumnsText(
//         leftText: "Tax (18%)",
//         rightText: "₹26.79",
//       );
//
//       await printer.print2ColumnsText(
//         leftText: "TOTAL",
//         rightText: "₹175.61",
//       );
//
//       await printer.printText("${'=' * 32}\n");
//
//       // Footer
//       await printer.printText(
//         "Thank you for your visit!\n",
//         printStyle: PrintStyle(
//           textAlign: PrintStyleAlign.center,
//           fontSize: 18,
//         ),
//       );
//
//       await printer.printText(
//         "${DateTime.now().toString().substring(0, 19)}\n",
//         printStyle: PrintStyle(
//           textAlign: PrintStyleAlign.center,
//           fontSize: 16,
//         ),
//       );
//
//       await printer.printText("\n\n");
//       await printer.fullCut();
//
//       debugPrint('✅ Full receipt test completed');
//     } catch (e) {
//       debugPrint('❌ Full receipt test failed: $e');
//       rethrow;
//     }
//   }
//
//   // Comprehensive printer test
//   static Future<Map<String, dynamic>> runComprehensiveTest() async {
//     Map<String, dynamic> results = {
//       'basicPrint': false,
//       'statusCheck': false,
//       'styleTest': false,
//       'fullReceipt': false,
//       'errors': <String>[],
//     };
//
//     try {
//       // Test 1: Basic Print
//       await testBasicPrint();
//       results['basicPrint'] = true;
//
//       // Test 2: Status Check
//       var statusResult = await checkPrinterStatus();
//       results['statusCheck'] = statusResult['isConnected'];
//       results['printerStatus'] = statusResult;
//
//       // Test 3: Print Styles
//       await testPrintStyles();
//       results['styleTest'] = true;
//
//       // Test 4: Full Receipt
//       await testFullReceipt();
//       results['fullReceipt'] = true;
//     } catch (e) {
//       results['errors'].add(e.toString());
//     }
//
//     return results;
//   }
// }
//
// // Updated button with comprehensive testing
// class PrinterTestWidget extends StatefulWidget {
//   @override
//   _PrinterTestWidgetState createState() => _PrinterTestWidgetState();
// }
//
// class _PrinterTestWidgetState extends State<PrinterTestWidget> {
//   bool _isLoading = false;
//   String _statusMessage = "Ready to test";
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Status Display
//         Container(
//           padding: EdgeInsets.all(16),
//           margin: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             _statusMessage,
//             style: TextStyle(fontSize: 16),
//           ),
//         ),
//
//         // Test Buttons
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _testBasicPrint,
//                 child: Text("Basic Test"),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _checkStatus,
//                 child: Text("Check Status"),
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 8),
//
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _testStyles,
//                 child: Text("Test Styles"),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _testFullReceipt,
//                 child: Text("Full Receipt"),
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 8),
//
//         // Comprehensive Test Button
//         ElevatedButton(
//           onPressed: _isLoading ? null : _runComprehensiveTest,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: appPrimaryColor,
//             minimumSize: Size(double.infinity, 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           child: _isLoading
//               ? CircularProgressIndicator(color: Colors.white)
//               : Text(
//                   "Run All Tests",
//                   style: TextStyle(color: whiteColor),
//                 ),
//         ),
//
//         SizedBox(height: 16),
//
//         // Your original print button
//         ElevatedButton(
//           onPressed: _isLoading ? null : _printBills,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             minimumSize: Size(double.infinity, 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           child: Text(
//             "Print Bills",
//             style: TextStyle(color: whiteColor),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _setLoading(bool loading) {
//     setState(() {
//       _isLoading = loading;
//     });
//   }
//
//   void _setStatus(String message) {
//     setState(() {
//       _statusMessage = message;
//     });
//   }
//
//   Future<void> _testBasicPrint() async {
//     _setLoading(true);
//     _setStatus("Testing basic print...");
//
//     try {
//       await AnotherIminPrinterHelper.testBasicPrint();
//       _setStatus("✅ Basic print test passed!");
//     } catch (e) {
//       _setStatus("❌ Basic print failed: $e");
//     }
//
//     _setLoading(false);
//   }
//
//   Future<void> _checkStatus() async {
//     _setLoading(true);
//     _setStatus("Checking printer status...");
//
//     try {
//       var result = await AnotherIminPrinterHelper.checkPrinterStatus();
//       _setStatus("Status: ${result['statusMessage']}");
//     } catch (e) {
//       _setStatus("❌ Status check failed: $e");
//     }
//
//     _setLoading(false);
//   }
//
//   Future<void> _testStyles() async {
//     _setLoading(true);
//     _setStatus("Testing print styles...");
//
//     try {
//       await AnotherIminPrinterHelper.testPrintStyles();
//       _setStatus("✅ Print styles test passed!");
//     } catch (e) {
//       _setStatus("❌ Print styles test failed: $e");
//     }
//
//     _setLoading(false);
//   }
//
//   Future<void> _testFullReceipt() async {
//     _setLoading(true);
//     _setStatus("Testing full receipt...");
//
//     try {
//       await AnotherIminPrinterHelper.testFullReceipt();
//       _setStatus("✅ Full receipt test passed!");
//     } catch (e) {
//       _setStatus("❌ Full receipt test failed: $e");
//     }
//
//     _setLoading(false);
//   }
//
//   Future<void> _runComprehensiveTest() async {
//     _setLoading(true);
//     _setStatus("Running comprehensive tests...");
//
//     try {
//       var results = await AnotherIminPrinterHelper.runComprehensiveTest();
//
//       String statusMsg = "Test Results:\n";
//       statusMsg += "Basic Print: ${results['basicPrint'] ? '✅' : '❌'}\n";
//       statusMsg += "Status Check: ${results['statusCheck'] ? '✅' : '❌'}\n";
//       statusMsg += "Style Test: ${results['styleTest'] ? '✅' : '❌'}\n";
//       statusMsg += "Full Receipt: ${results['fullReceipt'] ? '✅' : '❌'}";
//
//       if (results['errors'].isNotEmpty) {
//         statusMsg += "\nErrors: ${results['errors'].join(', ')}";
//       }
//
//       _setStatus(statusMsg);
//     } catch (e) {
//       _setStatus("❌ Comprehensive test failed: $e");
//     }
//
//     _setLoading(false);
//   }
//
//   Future<void> _printBills() async {
//     _setLoading(true);
//     _setStatus("Printing bills...");
//
//     try {
//       await AnotherIminPrinterHelper.printer.initPrinter();
//
//       await AnotherIminPrinterHelper.printer.printText(
//         "🍽️ Roja Restaurant\n",
//         printStyle: PrintStyle(
//           textAlign: PrintStyleAlign.center,
//           fontSize: 26,
//           bold: true,
//         ),
//       );
//
//       await AnotherIminPrinterHelper.printer.printText(
//         "Item: Veg Burger x1\nPrice: ₹59.32\n\n",
//       );
//
//       await AnotherIminPrinterHelper.printer.print2ColumnsText(
//         leftText: "Total",
//         rightText: "₹59.32",
//       );
//
//       await AnotherIminPrinterHelper.printer.fullCut();
//
//       _setStatus("✅ Bills printed successfully!");
//     } catch (e) {
//       _setStatus("❌ Print failed: $e");
//     }
//
//     _setLoading(false);
//   }
// }
