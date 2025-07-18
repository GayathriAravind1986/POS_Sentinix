import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/Order/order_list.dart';

class OrdersTabbedScreen extends StatelessWidget {
  final VoidCallback? onRefresh;
  const OrdersTabbedScreen({super.key, this.onRefresh});

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
  void refreshOrders() {
    context.read<OrderTodayBloc>().add(OrderTodayList(
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
        ));
    orderLoad = true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContainer() {
      return DefaultTabController(
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
