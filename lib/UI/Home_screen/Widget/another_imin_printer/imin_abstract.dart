abstract class IPrinterService {
  Future<void> init();
  Future<void> printText(String text);
  Future<void> fullCut();
}
