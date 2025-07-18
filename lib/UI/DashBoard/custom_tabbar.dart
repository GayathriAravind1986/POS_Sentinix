import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:simple/Alertbox/AlertDialogBox.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/UI/CustomAppBar/custom_appbar.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/UI/Order/order_tab_page.dart';

class DashBoardScreen extends StatelessWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;
  const DashBoardScreen(
      {super.key, this.selectTab, this.existingOrder, this.isEditingOrder});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: DashBoard(
        selectTab: selectTab,
        existingOrder: existingOrder,
        isEditingOrder: isEditingOrder,
      ),
    );
  }
}

class DashBoard extends StatefulWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;

  const DashBoard({
    super.key,
    this.selectTab,
    this.existingOrder,
    this.isEditingOrder,
  });

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final GlobalKey<OrderViewViewState> orderTabKey =
      GlobalKey<OrderViewViewState>();
  int selectedIndex = 0;
  bool orderLoad = false;
  @override
  void initState() {
    super.initState();
    debugPrint("selectTab: ${widget.selectTab}");
    debugPrint("isEditDash: ${widget.isEditingOrder}");
    debugPrint("getViewDash: ${widget.existingOrder}");
    if (widget.selectTab != null) {
      selectedIndex = widget.selectTab!;
    }
  }

  Widget mainContainer() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          selectedIndex: selectedIndex,
          onTabSelected: (index) {
            setState(() {
              selectedIndex = index;
              if (index == 1) {
                orderTabKey.currentState?.refreshOrders();
              }
            });
          },
          onLogout: () {
            showLogoutDialog(context);
          },
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: [
            FoodOrderingScreen(
              existingOrder: widget.existingOrder,
              isEditingOrder: widget.isEditingOrder,
            ),
            OrdersTabbedScreen(
              key: orderTabKey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DemoBloc, dynamic>(
      buildWhen: (previous, current) {
        return false;
      },
      builder: (context, state) {
        return mainContainer();
      },
    );
  }
}
