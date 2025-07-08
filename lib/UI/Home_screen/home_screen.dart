import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/Cart/food_add_cart.dart';
import 'package:simple/UI/Home_screen/Widget/food_category_chips.dart';

class FoodOrderingScreen extends StatelessWidget {
  const FoodOrderingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: const FoodOrderingScreenView(),
    );
  }
}

class FoodOrderingScreenView extends StatefulWidget {
  const FoodOrderingScreenView({
    super.key,
  });

  @override
  FoodOrderingScreenViewState createState() => FoodOrderingScreenViewState();
}

class FoodOrderingScreenViewState extends State<FoodOrderingScreenView> {


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
    Widget mainContainer() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
            Container(
              height: size.height * 1.5,
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CategoryChips(),
                  ]),
            ),
            SizedBox(width: 16), // spacing between product & cart

            // Right: Cart Summary
            SizedBox(width: size.width * 0.32, child: CartSummary()),
          ],
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
          backgroundColor: whiteColor,
          body: BlocBuilder<DemoBloc, dynamic>(
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
          )),
    );
  }
}
