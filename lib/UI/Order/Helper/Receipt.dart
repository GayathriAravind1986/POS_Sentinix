import 'package:flutter/material.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'name': 'Noodles', 'qty': 1, 'price': 7212.129},
      {'name': 'Fried Rice', 'qty': 2, 'price': 125.93},
      {'name': 'Sandwiches', 'qty': 1, 'price': 91.97},
      {'name': 'Hot Dogs', 'qty': 1, 'price': 63.99},
      {'name': 'Greek Salad', 'qty': 2, 'price': 72.75},
      {'name': 'Caesar Salad', 'qty': 1, 'price': 72.75},
      {'name': 'Dumplings', 'qty': 2, 'price': 91.93},
      {'name': 'Brownie', 'qty': 1, 'price': 66.74},
      {'name': 'Gulab Jamun', 'qty': 1, 'price': 71.24},
      {'name': 'Pav Bhaji', 'qty': 1, 'price': 67.90},
      {'name': 'Pakora', 'qty': 1, 'price': 42.37},
    {'name': 'Noodles', 'qty': 1, 'price': 7212.129},
  {'name': 'Fried Rice', 'qty': 2, 'price': 125.93},
  {'name': 'Sandwiches', 'qty': 1, 'price': 91.97},
  {'name': 'Hot Dogs', 'qty': 1, 'price': 63.99},
  {'name': 'Greek Salad', 'qty': 2, 'price': 72.75},
  {'name': 'Caesar Salad', 'qty': 1, 'price': 72.75},
  {'name': 'Dumplings', 'qty': 2, 'price': 91.93},
  {'name': 'Brownie', 'qty': 1, 'price': 66.74},
  {'name': 'Gulab Jamun', 'qty': 1, 'price': 71.24},
  {'name': 'Pav Bhaji', 'qty': 1, 'price': 67.90},
  {'name': 'Pakora', 'qty': 1, 'price': 42.37},
    ];

    // ✅ Calculate subtotal
    final double subtotal = items.fold(0.0, (sum, e) {
      return sum + ((e['qty'] as int) * (e['price'] as double));
    });

    const double tax = 70.85;
    final double total = subtotal + tax;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------- HEADER ----------
                  Text('Roja Restaurant',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('123 Main St, Chennai, Tamil Nadu 600001'),
                  Text('Phone: +91-9876543210'),
                  Text('GST: 29ABCDE1234FZ5'),
                  SizedBox(height: 8),

                  // ----------- ORDER DETAILS ----------
                  Text('Order#: ORD20250712-0028'),
                  Text('12/07/2025 10:27 PM'),
                  Text('Type: TAKE AWAY'),
                  Text('Table: N/A'),
                  SizedBox(height: 10),
                  Divider(thickness: 1),

                  // ----------- TABLE HEADERS ----------
                  Row(
                    children: const [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Item',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Qty',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Price',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  Divider(thickness: 1),

                  // ----------- ITEM LIST ----------
                  ...items.map((e) {
                    final itemTotal = (e['qty'] as int) * (e['price'] as double);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: Text('${e['name']}')),
                          Expanded(flex: 1, child: Text('${e['qty']}')),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '₹${(e['price'] as double).toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '₹${itemTotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  Divider(thickness: 1),

                  _buildAmountRow('Subtotal', subtotal),
                  _buildAmountRow('Tax', tax),
                  _buildAmountRow('TOTAL', total, isBold: true),
                  _buildAmountRow('Paid By: UPI', total),

                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Thank You, Visit Again!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          SizedBox(
            width: 100,
            child: Text(
              '₹${amount.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
