import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RazorpayQRScreen extends StatelessWidget {
  final String paymentUrl;

  const RazorpayQRScreen({super.key, required this.paymentUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan to Pay")),
      body: Center(
        child: QrImageView(
          // Updated for qr_flutter v4+
          data: paymentUrl.trim(),
          version: QrVersions.auto,
          size: 250.0,
        ),
      ),
    );
  }
}
