import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentFields extends StatefulWidget {
  @override
  _PaymentFieldsState createState() => _PaymentFieldsState();
}

class _PaymentFieldsState extends State<PaymentFields> {
  int _paymentFieldCount = 0; // start with one field

  void addPaymentField() {
    if (_paymentFieldCount < 2) { // max 2 fields total
      setState(() => _paymentFieldCount++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _paymentFieldCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select",
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF522F1F), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF522F1F), width: 2),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF522F1F)),
                    style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                    items: const [
                      DropdownMenuItem(value: "Cash", child: Text("Cash")),
                      DropdownMenuItem(value: "Card", child: Text("Card")),
                      DropdownMenuItem(value: "UPI", child: Text("UPI")),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "₹ Amount",
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF522F1F), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF522F1F), width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // "Add Another" link
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _paymentFieldCount < 2 ? addPaymentField : null,
            child: Text(
              _paymentFieldCount < 2
                  ? "+ Add Another Payment"
                  : "Maximum 2 payments reached",
              style: TextStyle(
                decoration: _paymentFieldCount < 2 ? TextDecoration.underline : null,
                color: _paymentFieldCount < 2 ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
