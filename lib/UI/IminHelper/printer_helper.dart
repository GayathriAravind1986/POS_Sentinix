import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:simple/Reusable/color.dart';

Widget getThermalReceiptWidget({
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
  required String status,
  //required ScreenshotController controller,
}) {
  return Container(
    width: 384, // Standard thermal printer width
    color: whiteColor, // Ensure white background
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Center(
            child: Column(
              children: [
                Text(
                  tamilTagline,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: blackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Phone: $phone",
                  style: const TextStyle(
                    fontSize: 12,
                    color: blackColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Separator line
          Container(
            height: 1,
            color: blackColor,
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),

          // Order details
          _buildThermalLabelRow("Order#: ", orderNumber),
          _buildThermalLabelRow("Date: ", date),
          _buildThermalLabelRow("Type: ", orderType),
          _buildThermalLabelRow("Status: ", status),
          _buildThermalLabelRow(
              "Table: ", orderType == 'DINE-IN' ? tableName : "N/A"),

          // Separator line
          Container(
            height: 1,
            color: blackColor,
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),

          // Items header
          _buildThermalHeaderRow(),

          // Separator line
          Container(
            height: 1,
            color: blackColor,
            margin: const EdgeInsets.symmetric(vertical: 2),
          ),

          // Items
          ...items.map((item) => _buildThermalItemRow(
                item['name'],
                item['qty'],
                item['price'],
                item['total'],
              )),

          // Separator line
          Container(
            height: 1,
            color: blackColor,
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),

          // Totals
          _buildThermalTotalRow("Subtotal", subtotal),
          _buildThermalTotalRow("Tax", tax),
          _buildThermalTotalRow("TOTAL", total, isBold: true),

          // Separator line
          Container(
            height: 1,
            color: blackColor,
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),

          Text(
            "Paid via: $paidBy",
            style: const TextStyle(
              fontSize: 12,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "Thank You, Visit Again!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: blackColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "Powered By",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: blackColor,
              ),
            ),
          ),
          const Center(
            child: Text(
              "www.sentinixtechsolutions.com",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: blackColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Widget _buildThermalLabelRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: blackColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: blackColor),
        ),
      ],
    ),
  );
}

Widget _buildThermalHeaderRow() {
  return const Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        flex: 4,
        child: Text(
          "Item",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: blackColor),
          textAlign: TextAlign.left,
        ),
      ),
      Expanded(
        flex: 2,
        child: Text(
          "Qty",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: blackColor),
          textAlign: TextAlign.center,
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(
          "Price",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: blackColor),
          textAlign: TextAlign.center,
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(
          "Total",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: blackColor),
          textAlign: TextAlign.end,
        ),
      ),
    ],
  );
}

Widget _buildThermalItemRow(String name, int qty, double price, double total) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            name,
            style: const TextStyle(fontSize: 12, color: blackColor),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: blackColor),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '₹${price.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: blackColor,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '₹${total.toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              color: blackColor,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildThermalTotalRow(String label, double amount,
    {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
            color: blackColor,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
            color: blackColor,
          ),
        ),
      ],
    ),
  );
}

// Enhanced image capture function optimized for thermal printing
Future<Uint8List?> captureThermalReceiptAsImage(GlobalKey key) async {
  try {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Capture at higher resolution for better quality
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return null;

    return byteData.buffer.asUint8List();
  } catch (e) {
    print("Error capturing thermal image: $e");
    return null;
  }
}

// Alternative: Convert to monochrome bitmap for better thermal printing
Future<Uint8List?> captureMonochromeReceipt(GlobalKey key) async {
  try {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Capture the widget as an image
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (byteData == null) return null;

    Uint8List pixels = byteData.buffer.asUint8List();
    int width = image.width;
    int height = image.height;

    // Convert to monochrome (black and white only)
    List<int> monochromePixels = [];

    for (int i = 0; i < pixels.length; i += 4) {
      int r = pixels[i];
      int g = pixels[i + 1];
      int b = pixels[i + 2];
      int a = pixels[i + 3];

      // Calculate luminance
      double luminance = (0.299 * r + 0.587 * g + 0.114 * b);

      // Convert to black or white based on threshold
      int value = luminance > 128 ? 255 : 0;

      monochromePixels.addAll([value, value, value, a]);
    }

    // Create new image from monochrome pixels
    ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
        Uint8List.fromList(monochromePixels));

    ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    ui.Codec codec = await descriptor.instantiateCodec();
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image monochromeImage = frameInfo.image;

    ByteData? finalByteData =
        await monochromeImage.toByteData(format: ui.ImageByteFormat.png);

    return finalByteData?.buffer.asUint8List();
  } catch (e) {
    print("Error creating monochrome image: $e");
    return null;
  }
}
