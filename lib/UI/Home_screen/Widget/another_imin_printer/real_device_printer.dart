import 'dart:io' show Platform;
import 'package:another_imin_printer/imin_printer.dart';

import 'imin_abstract.dart';

class RealPrinterService implements IPrinterService {
  final IminPrinter _printer = IminPrinter();

  @override
  Future<void> init() async {
    await _printer.initPrinter();
  }

  @override
  Future<void> printText(String text) async {
    await _printer.printText(text);
  }

  @override
  Future<void> fullCut() async {
    await _printer.fullCut();
  }
}
