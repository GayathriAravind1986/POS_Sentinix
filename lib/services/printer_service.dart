abstract class PrinterService {
  Future<void> init();
  Future<void> setAlignment(dynamic align);
  Future<void> printText(String text, {dynamic style});
  Future<void> printAndLineFeed();
  Future<void> cut();
}
