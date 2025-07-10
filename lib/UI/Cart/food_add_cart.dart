import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/ModelClass/payment_split/split.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Cart/Widget/payment_option.dart';
// import 'package:imin_printer/imin_printer.dart';
// import 'package:imin_printer/enums.dart';
// import 'package:imin_printer/imin_style.dart';
import 'package:simple/services/printer_service.dart';
import 'package:simple/services/mock_printer_service.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: const CartSummaryView(),
    );
  }
}

class CartSummaryView extends StatefulWidget {
  const CartSummaryView({
    super.key,
  });

  @override
  CartSummaryViewState createState() => CartSummaryViewState();
}

class CartSummaryViewState extends State<CartSummaryView> {
  // PostLoginModel postLoginModel = PostLoginModel();
  late final PrinterService printer;
  bool isSplitPayment = false;
  bool isDineIn = true;
  String selectedFullPaymentMethod = "Cash";


  @override
  void initState() {
    super.initState();
    printer = MockPrinterService();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    Widget mainContainer() {
      return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        height: double.infinity,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDineIn = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDineIn ? appPrimaryColor : greyColor200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Dine In",
                          style: MyTextStyle.f12(isDineIn ? whiteColor : blackColor),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDineIn = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !isDineIn ? appPrimaryColor : greyColor200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Take Away",
                          style: MyTextStyle.f12(!isDineIn ? whiteColor : blackColor),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),

            SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                Text(
                  "Bills",
                  style: MyTextStyle.f16(blackColor, weight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/image/sentinix_logo.png',
                  width: 50,
                  height: 50,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Quantity Controls in One Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // "Noodles x1"
                          Row(
                            children: [
                              Text(
                                "Noodles",
                                style: MyTextStyle.f12(blackColor, weight: FontWeight.bold),
                              ),
                              SizedBox(width: 6),
                              Text(
                                "x1",
                                style: MyTextStyle.f12(greyColor),
                              ),
                            ],
                          ),
                          // Quantity & Delete Icons
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.remove_circle_outline, color: blackColor),
                                iconSize: 20,
                              ),
                              Text("1", style: MyTextStyle.f12(blackColor)),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.add_circle_outline, color: blackColor),
                                iconSize: 20,
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.delete, color: Colors.red),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Base Price", style: MyTextStyle.f12(greyColor)),
                          Text("₹ 127.12", style: MyTextStyle.f12(blackColor)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("SGST (9%)", style: MyTextStyle.f12(greyColor)),
                          Text("₹ 11.44", style: MyTextStyle.f12(blackColor)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("CGST (9%)", style: MyTextStyle.f12(greyColor)),
                          Text("₹ 11.44", style: MyTextStyle.f12(blackColor)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Item Total", style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
                          Text("₹ 127.12", style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Subtotal",style:  MyTextStyle.f12(greyColor)),
              SizedBox(height: 12),
              Text("₹ 50.00",style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
            ]),
            SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Total Tax", style: MyTextStyle.f12(greyColor)),
              Text("₹ 10.68",style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
            ]),
            SizedBox(height: 8),
            Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Total",
                  style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
              Text("₹ 70.00",
                  style: MyTextStyle.f18(blackColor, weight: FontWeight.bold)),
            ]),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: greyColor200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isSplitPayment = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                          isSplitPayment ? greyColor200 : appPrimaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Full Payment",
                            style: MyTextStyle.f12(
                              isSplitPayment ? blackColor : whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isSplitPayment = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                          isSplitPayment ? appPrimaryColor : greyColor200,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Split Payment",
                            style: TextStyle(
                              color: isSplitPayment ? whiteColor : blackColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            !isSplitPayment ? Column(
             crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Text("Payment Method", style: MyTextStyle.f14(blackColor, weight: FontWeight.bold)),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFullPaymentMethod = "Cash";
                          });
                        },
                        child: PaymentOption(
                          icon: Icons.money,
                          label: "Cash",
                          selected: selectedFullPaymentMethod == "Cash",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFullPaymentMethod = "Card";
                          });
                        },
                        child: PaymentOption(
                          icon: Icons.credit_card,
                          label: "Card",
                          selected: selectedFullPaymentMethod == "Card",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFullPaymentMethod = "UPI";
                          });
                        },
                        child: PaymentOption(
                          icon: Icons.qr_code,
                          label: "UPI",
                          selected: selectedFullPaymentMethod == "UPI",
                        ),
                      ),
                    ],
                  ),

                ),
              ],
            ) : Container(),
            if (!isSplitPayment && selectedFullPaymentMethod == "Cash") ...[
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter amount paid (₹)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],



            isSplitPayment
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Split Payment",
                  style: MyTextStyle.f20(blackColor,
                      weight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
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


                PaymentFields(),
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     "+ Add Another Payment",
                //     style: MyTextStyle.f14(
                //       textDecoration: TextDecoration.underline,
                //       decorationColor: blueColor,
                //       blueColor,
                //     ),
                //   ),
                // ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Split:",
                      style: MyTextStyle.f17(blackColor,
                          weight: FontWeight.bold),
                    ),
                    Text(
                      "₹0.00",
                      style: MyTextStyle.f17(blackColor,
                          weight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            )
                : Container(),
            SizedBox(height: 12),
            // Text("Payment Method",
            //     style: MyTextStyle.f14(blackColor, weight: FontWeight.bold)),
            // SizedBox(height: 12),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Wrap(
            //     spacing: 12,
            //     runSpacing: 12,
            //     children: [
            //       PaymentOption(
            //           icon: Icons.money, label: "Cash", selected: true),
            //       PaymentOption(
            //           icon: Icons.credit_card, label: "Card", selected: false),
            //       PaymentOption(
            //           icon: Icons.qr_code, label: "UPI", selected: false),
            //     ],
            //   ),
            // ),

            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                debugPrint(' Button tapped');
                try {
                  await printer.init();
                  await printer
                      .setAlignment("center"); // For mock, just a string
                  await printer.printText("🍽️ Roja Restaurant\n");
                  await printer.setAlignment("left");
                  await printer.printText("Item: Veg Burger x1\n");
                  await printer.printText("Price: ₹59.32\n");
                  await printer.printAndLineFeed();
                  await printer.cut();
                } catch (e) {
                  debugPrint("[MOCK] Print failed: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appPrimaryColor,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Print Bills",
                style: TextStyle(color: whiteColor),
              ),
            )
          ]),
        ),
      );
    }

    return BlocBuilder<DemoBloc, dynamic>(
      buildWhen: ((previous, current) {
        // if (current is PostLoginModel) {
        //   postLoginModel = current;
        //
        //   if (postLoginModel.success == true) {
        //     debugPrint("LoginIn success: ${postLoginModel.data?.errorMsg}");
        //     if (postLoginModel.data?.status == true) {
        //       debugPrint("Login: ${postLoginModel.success}");
        //
        //       setState(() {
        //         loginLoad = false;
        //       });
        //       Navigator.of(context).pushAndRemoveUntil(
        //         MaterialPageRoute(
        //             builder: (context) => const DashboardScreen()),
        //             (Route<dynamic> route) => false,
        //       );
        //     } else if (postLoginModel.data?.status == false) {
        //       debugPrint("LoginError: ${postLoginModel.data?.errorMsg}");
        //       setState(() {
        //         loginLoad = false;
        //         showToast('${postLoginModel.data?.errorMsg}', context,
        //             color: false);
        //       });
        //     }
        //   }
        //   return true;
        // }
        return false;
      }),
      builder: (context, dynamic) {
        return mainContainer();
      },
    );
  }
}
