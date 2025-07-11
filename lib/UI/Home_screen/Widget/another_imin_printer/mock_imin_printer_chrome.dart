import 'package:flutter/material.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/imin_abstract.dart';

class MockPrinterService implements IPrinterService {
  @override
  Future<void> init() async {
    debugPrint("MockPrinter: init");
  }

  @override
  Future<void> printText(String text) async {
    debugPrint("MockPrinter: printText -> $text");
  }

  @override
  Future<void> fullCut() async {
    debugPrint("MockPrinter: fullCut");
  }
}
