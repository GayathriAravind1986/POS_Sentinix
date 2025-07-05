import 'package:flutter/material.dart';

class PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const PaymentOption({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? Colors.brown.shade100 : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
