import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';

class OrderView extends StatelessWidget {
  final String type;
  const OrderView({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: OrderViewView(),
    );
  }
}

class OrderViewView extends StatefulWidget {
  const OrderViewView({
    super.key,
  });

  @override
  OrderViewViewState createState() => OrderViewViewState();
}

class OrderViewViewState extends State<OrderViewView> {
//  GetCategoryModel getCategoryModel = GetCategoryModel();

  @override
  void initState() {
    super.initState();

    //context.read<FoodCategoryBloc>().add(FoodCategory());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 2 per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            // final order = orders[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order ID: ORD-20250714-0010",
                            style: MyTextStyle.f14(appPrimaryColor,
                                weight: FontWeight.bold)),
                        Text("Total: ₹ 150.00",
                            style: MyTextStyle.f14(appPrimaryColor,
                                weight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Time: 02:23 PM"),
                        Text("Payment: CASH: ₹150.00",
                            style: MyTextStyle.f12(greyColor,
                                weight: FontWeight.w400)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Type: DINE-IN"),
                        Text("Status: COMPLETED",
                            style: TextStyle(color: greenColor)),
                      ],
                    ),
                    // if (order['table'] != null)
                    Text("Table: 3"),
                    SizedBox(height: 4),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.remove_red_eye, color: appPrimaryColor),
                        Icon(Icons.edit, color: appPrimaryColor),
                        Icon(Icons.copy, color: appPrimaryColor),
                        Icon(Icons.delete, color: appPrimaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return BlocBuilder<DemoBloc, dynamic>(
      buildWhen: ((previous, current) {
        // if (current is GetCategoryModel) {
        //   getCategoryModel = current;
        //   if (getCategoryModel.success == true) {
        //     debugPrint("category: ${getCategoryModel.data}");
        //     setState(() {
        //       categoryLoad = false;
        //     });
        //   } else {
        //     setState(() {
        //       categoryLoad = false;
        //     });
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
