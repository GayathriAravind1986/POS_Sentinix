import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/Order/order_list.dart';

class OrdersTabbedScreen extends StatelessWidget {
  const OrdersTabbedScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderTodayBloc(),
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
  GetOrderListTodayModel getOrderListTodayModel = GetOrderListTodayModel();
  bool orderLoad = false;
  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  @override
  void initState() {
    super.initState();
    context.read<OrderTodayBloc>().add(OrderTodayList(todayDate, todayDate));
    orderLoad = true;
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContainer() {
      return orderLoad
          ? Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1),
              alignment: Alignment.center,
              child: const SpinKitChasingDots(color: appPrimaryColor, size: 30))
          : DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Today's Orders",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF522F1F),
                      ),
                    ),
                  ),

                  // Tabs
                  const TabBar(
                    labelColor: appPrimaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: appPrimaryColor,
                    tabs: [
                      Tab(text: "All"),
                      Tab(text: "Takeaway"),
                      Tab(text: "Dine-in"),
                    ],
                  ),

                  // TabBarView with order lists
                  const Expanded(
                    child: TabBarView(
                      children: [
                        OrderView(type: 'All'),
                        OrderView(type: 'Takeaway'),
                        OrderView(type: 'Dine-in'),
                      ],
                    ),
                  ),
                ],
              ),
            );
    }

    return BlocBuilder<OrderTodayBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetOrderListTodayModel) {
          getOrderListTodayModel = current;
          if (getOrderListTodayModel.success == true) {
            debugPrint("orderToday: ${getOrderListTodayModel.data}");
            setState(() {
              orderLoad = false;
            });
          } else {
            setState(() {
              orderLoad = false;
            });
          }
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
