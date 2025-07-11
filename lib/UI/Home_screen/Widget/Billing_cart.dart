import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/UI/Cart/Widget/payment_option.dart';
import 'package:simple/services/printer_service.dart';
import 'package:simple/services/mock_printer_service.dart';

class Pop extends StatelessWidget {
  const Pop({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: const Popview(),
    );
  }
}

class Popview extends StatefulWidget {
  const Popview({super.key});

  @override
  State<Popview> createState() => _PopviewState();
}

class _PopviewState extends State<Popview> {
  late final PrinterService printer;
  @override
  void initState() {
    super.initState();
    printer = MockPrinterService();
    printer.init();
    print("🟢 TestPrintScreen loaded");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    Widget mainContainer(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(10),
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Add functionality for "Dine In" button
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF522F1F),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Dine In",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Add functionality for "Take Away" button
                      },
                      child: Center(
                        child: Text(
                          "Take Away",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8), // instead of Spacer

                  const Text(
                    "Bills",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              SizedBox(height: 25), // instead of Spacer

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("No.items in bill", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text("₹ 00.00")
              ]),
              Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Subtotal", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text("₹ 00.00")
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Total Tax", style: TextStyle(color: Colors.grey)),
                Text("₹ 00.00"),
              ]),
              SizedBox(height: 8),
              Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("₹ 00.00",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ]),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: Color(0xFF522F1F),
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                          child: Text("Full Payment",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(child: Text("Split Payment")),
                    )
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text("Payment Method",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    PaymentOption(
                        icon: Icons.money, label: "Cash", selected: true),
                    PaymentOption(
                        icon: Icons.credit_card,
                        label: "Card",
                        selected: false),
                    PaymentOption(
                        icon: Icons.qr_code, label: "UPI", selected: false),
                  ],
                ),
              ),

              SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      print("🟡 Button tapped");
                      // await printer.setAlignment("center");
                      // await printer.printText("🍽️ HOTEL XYZ");
                      // await printer.setAlignment("left");
                      // await printer.printText("Item: Veg Burger x1");
                      // await printer.printText("Price: ₹59.32");
                      // await printer.printAndLineFeed();
                      // await printer.cut();
                      // print("✅ Mock print complete");
                    } catch (e) {
                      print("❌ Print error: $e");
                    }
                  },
                  child: Text("Print"))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: mainContainer(context),
    );
  }
}
