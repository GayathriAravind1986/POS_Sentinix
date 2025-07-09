import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';

import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Cart/Widget/payment_option.dart';
import 'package:simple/services/printer_service.dart';
import 'package:simple/services/mock_printer_service.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCategoryBloc(),
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
  PostAddToBillingModel postAddToBillingModel = PostAddToBillingModel();
  late final PrinterService printer;
  bool isSplitPayment = false;
  bool cartLoad = false;

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
              // cartLoad
              //     ? Container(
              //         padding: EdgeInsets.only(
              //             top: MediaQuery.of(context).size.height * 0.2),
              //         alignment: Alignment.center,
              //         child: const SpinKitChasingDots(
              //             color: appPrimaryColor, size: 30))
              //     : postAddToBillingModel.items == null ||
              //             postAddToBillingModel.items!.isEmpty
              //         ? SingleChildScrollView(
              //             child: Container(
              //               margin: EdgeInsets.only(top: 30),
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Row(
              //                     children: [
              //                       Expanded(
              //                         child: GestureDetector(
              //                           onTap: () {
              //                             // Add functionality for "Dine In" button
              //                           },
              //                           child: Container(
              //                             padding:
              //                                 EdgeInsets.symmetric(vertical: 10),
              //                             decoration: BoxDecoration(
              //                               color: appPrimaryColor,
              //                               borderRadius: BorderRadius.circular(30),
              //                             ),
              //                             child: Center(
              //                               child: Text(
              //                                 "Dine In",
              //                                 style: MyTextStyle.f14(whiteColor),
              //                               ),
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       Expanded(
              //                         child: GestureDetector(
              //                           onTap: () {
              //                             // Add functionality for "Take Away" button
              //                           },
              //                           child: Center(
              //                             child: Text("Take Away",
              //                                 style: MyTextStyle.f14(blackColor,
              //                                     weight: FontWeight.bold)),
              //                           ),
              //                         ),
              //                       ),
              //
              //                       SizedBox(height: 8), // instead of Spacer
              //                       Text(
              //                         "Bills",
              //                         style: MyTextStyle.f16(blackColor,
              //                             weight: FontWeight.bold),
              //                       ),
              //                       IconButton(
              //                         onPressed: () {},
              //                         icon: const Icon(Icons.refresh),
              //                       ),
              //                     ],
              //                   ),
              //                   SizedBox(height: 25),
              //                   Row(
              //                       mainAxisAlignment:
              //                           MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         Text(
              //                           "No.items in bill",
              //                           style: MyTextStyle.f14(greyColor,
              //                               weight: FontWeight.w400),
              //                         ),
              //                         SizedBox(height: 8),
              //                         Text("₹ 00.00")
              //                       ]),
              //                   Divider(),
              //                   Row(
              //                       mainAxisAlignment:
              //                           MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         Text(
              //                           "Subtotal",
              //                           style: MyTextStyle.f14(greyColor,
              //                               weight: FontWeight.w400),
              //                         ),
              //                         SizedBox(height: 8),
              //                         Text("₹ 00.00")
              //                       ]),
              //                   Row(
              //                       mainAxisAlignment:
              //                           MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         Text(
              //                           "Total Tax",
              //                           style: MyTextStyle.f14(greyColor,
              //                               weight: FontWeight.w400),
              //                         ),
              //                         Text("₹ 00.00"),
              //                       ]),
              //                   SizedBox(height: 8),
              //                   Divider(),
              //                   Row(
              //                       mainAxisAlignment:
              //                           MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         Text(
              //                           "Total",
              //                           style: MyTextStyle.f14(blackColor,
              //                               weight: FontWeight.w600),
              //                         ),
              //                         Text("₹ 00.00",
              //                             style: MyTextStyle.f18(blackColor,
              //                                 weight: FontWeight.w600)),
              //                       ]),
              //                   SizedBox(height: 12),
              //                   Container(
              //                     decoration: BoxDecoration(
              //                       color: greyColor200,
              //                       borderRadius: BorderRadius.circular(30),
              //                     ),
              //                     child: Row(
              //                       children: [
              //                         Expanded(
              //                           child: Container(
              //                             padding:
              //                                 EdgeInsets.symmetric(vertical: 8),
              //                             decoration: BoxDecoration(
              //                                 color: appPrimaryColor,
              //                                 borderRadius:
              //                                     BorderRadius.circular(30)),
              //                             child: Center(
              //                               child: Text("Full Payment",
              //                                   style: MyTextStyle.f12(whiteColor)),
              //                             ),
              //                           ),
              //                         ),
              //                         Expanded(
              //                           child: Center(
              //                               child: Text(
              //                             "Split Payment",
              //                             style: MyTextStyle.f12(whiteColor),
              //                           )),
              //                         )
              //                       ],
              //                     ),
              //                   ),
              //                   SizedBox(height: 12),
              //                   Text("Payment Method",
              //                       style: MyTextStyle.f12(blackColor,
              //                           weight: FontWeight.bold)),
              //                   SizedBox(height: 12),
              //                   SingleChildScrollView(
              //                     scrollDirection: Axis.horizontal,
              //                     child: Wrap(
              //                       spacing: 12,
              //                       runSpacing: 12,
              //                       children: [
              //                         PaymentOption(
              //                             icon: Icons.money,
              //                             label: "Cash",
              //                             selected: true),
              //                         PaymentOption(
              //                             icon: Icons.credit_card,
              //                             label: "Card",
              //                             selected: false),
              //                         PaymentOption(
              //                             icon: Icons.qr_code,
              //                             label: "UPI",
              //                             selected: false),
              //                       ],
              //                     ),
              //                   ),
              //                   SizedBox(height: 12),
              //                   ElevatedButton(
              //                     onPressed: () {},
              //                     style: ElevatedButton.styleFrom(
              //                       backgroundColor: appPrimaryColor,
              //                       minimumSize: Size(double.infinity, 50),
              //                       shape: RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.circular(30)),
              //                     ),
              //                     child: Text(
              //                       "Print Bills",
              //                       style: MyTextStyle.f12(whiteColor,
              //                           weight: FontWeight.bold),
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           )
              //         :
              Container(
            margin: EdgeInsets.only(top: 30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: appPrimaryColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child:
                            Text("Dine In", style: MyTextStyle.f12(whiteColor)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                        child: Text("Take Away",
                            style: MyTextStyle.f12(blackColor))),
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
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/image/sentinix_logo.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("veg bur",
                          style: MyTextStyle.f12(blackColor,
                              weight: FontWeight.bold)),
                      Text("x 1"),
                    ],
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.remove_circle_outline)),
                        Text("1"),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.add_circle_outline)),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.delete, color: Colors.red)),
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Base Price   ₹ 105.93"),
                        Text("SGST (9%)   ₹ 9.53}"),
                        Text("CGST (9%)   ₹ 9.53"),
                        Text("Item Total   ₹ 105.93",
                            style: MyTextStyle.f12(blackColor,
                                weight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Subtotal", style: MyTextStyle.f12(greyColor)),
                SizedBox(height: 8),
                Text("₹ 105.93")
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Total Tax", style: MyTextStyle.f12(greyColor)),
                Text("₹ 19.07"),
              ]),
              SizedBox(height: 8),
              Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Total",
                    style:
                        MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
                Text("₹ 125.00",
                    style:
                        MyTextStyle.f18(blackColor, weight: FontWeight.bold)),
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
                              style: MyTextStyle.f12(
                                isSplitPayment ? whiteColor : blackColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                        Row(
                          children: [
                            SizedBox(width: 12),
                            Expanded(
                                child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Select ",
                                labelStyle: MyTextStyle.f12(
                                  weight: FontWeight.w500,
                                  greyColor.shade700,
                                ),
                                filled: true,
                                fillColor: whiteColor,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: appPrimaryColor, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: appPrimaryColor, width: 2),
                                ),
                              ),
                              dropdownColor: whiteColor,
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: appPrimaryColor),
                              style: TextStyle(
                                fontSize: 16,
                                color: blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: "Cash", child: Text("Cash")),
                                DropdownMenuItem(
                                    value: "Card", child: Text("Card")),
                                DropdownMenuItem(
                                    value: "UPI", child: Text("UPI")),
                              ],
                              onChanged: (value) {
                                // handle change
                              },
                            )),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: " ₹ Amount",
                                  filled: true,
                                  fillColor: whiteColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: appPrimaryColor, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: appPrimaryColor, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "+ Add Another Payment",
                            style: MyTextStyle.f14(
                              textDecoration: TextDecoration.underline,
                              decorationColor: blueColor,
                              blueColor,
                            ),
                          ),
                        ),
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
              Text("Payment Method",
                  style: MyTextStyle.f14(blackColor, weight: FontWeight.bold)),
              SizedBox(height: 12),
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
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter amount paid (₹)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
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
        ),
      );
    }

    return BlocBuilder<FoodCategoryBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is PostAddToBillingModel) {
          postAddToBillingModel = current;
          debugPrint("Billing response: ${postAddToBillingModel.items}");
          setState(() {
            cartLoad = false;
          });
          return true;
        }
        return false;
      }),
      builder: (context, dynamic) {
        return mainContainer();
      },
    );
  }
}
