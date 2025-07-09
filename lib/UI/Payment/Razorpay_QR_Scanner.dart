import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayQRScreen extends StatefulWidget {
  final String paymentUrl;
  const RazorpayQRScreen({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  _RazorpayQRScreenState createState() => _RazorpayQRScreenState();
}

class _RazorpayQRScreenState extends State<RazorpayQRScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _onPayPressed() {
    _razorpay.open({
      'key': 'YOUR_KEY_ID',
      'method': 'upi_qr',
      'upi_qr': widget.paymentUrl.trim(),
    });
  }

  void _onSuccess(PaymentSuccessResponse rsp) {
    print('Payment completed: ${rsp.paymentId}');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PaymentCompletedScreen()),
    );
  }

  void _onError(PaymentFailureResponse rsp) {
    print('Payment failed: ${rsp.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${rsp.message}')),
    );
  }

  void _onWallet(ExternalWalletResponse rsp) {
    print('Wallet used: ${rsp.walletName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan to Pay")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: widget.paymentUrl.trim(),
              version: QrVersions.auto,
              size: 250,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text("Pay via UPI"),
              onPressed: _onPayPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentCompletedScreen extends StatelessWidget {
  const PaymentCompletedScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Done")),
      body: const Center(child: Text(" Payment Completed!")),
    );
  }
}
