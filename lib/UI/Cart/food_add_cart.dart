import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/Cart/Widget/payment_option.dart';

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

  @override
  void initState() {
    super.initState();
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
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: Color(0xFF522F1F),
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                      child: Text("Dine In",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(child: Text("Take Away")),
                )
              ],
            ),

            SizedBox(height: 8), // instead of Spacer
            Row(
              children: [
                const Spacer(),
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

            Divider(),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/image/almond.jpg',
                      width: 10, height: 10),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Veg Burger",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("x 1"),
                      SizedBox(height: 4),
                      Text("Base Price   ₹ 59.32"),
                      Text("SGST (9%)   ₹ 5.34"),
                      Text("CGST (9%)   ₹ 5.34"),
                      Text("Item Total   ₹ 59.32",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.remove_circle_outline)),
                    Text("1"),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.add_circle_outline)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.delete, color: Colors.red)),
                  ],
                )
              ],
            ),
            Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Subtotal", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 8),
              Text("₹ 50.00")
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Total Tax", style: TextStyle(color: Colors.grey)),
              Text("₹ 10.68"),
            ]),
            SizedBox(height: 8),
            Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("₹ 70.00",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      icon: Icons.credit_card, label: "Card", selected: false),
                  PaymentOption(
                      icon: Icons.qr_code, label: "UPI", selected: false),
                ],
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter amount paid (₹)",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF522F1F),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                "Print Bills",
                style: TextStyle(color: Colors.white),
              ),
            ),
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
        return mainContainer(context);
      },
    );
  }
}
