import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Alertbox/AlertDialogBox.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/UI/CustomAppBar/custom_appbar.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/UI/Order/order_list.dart';
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
  final GlobalKey<OrderViewViewState> orderAllTabKey =
      GlobalKey<OrderViewViewState>();
  final GlobalKey<FoodOrderingScreenViewState> foodKey =
      GlobalKey<FoodOrderingScreenViewState>();
  int selectedIndex = 0;
  bool orderLoad = false;
  bool hasRefreshedOrder = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectTab != null) {
      selectedIndex = widget.selectTab!;
    }
  }

  void _refreshOrders() {
    final orderAllTabState = orderAllTabKey.currentState;
    if (orderAllTabState != null) {
      debugPrint("foodKeyState exists, calling refreshOrder()");
      orderAllTabState.refreshOrders();
    }
  }

  void _refreshHome() {
    final foodKeyState = foodKey.currentState;
    if (foodKeyState != null) {
      debugPrint("foodKeyState exists, calling refreshHome()");
      foodKeyState?.refreshHome();
    } else {
      debugPrint("foodKeyState is NULL — check if key is assigned properly");
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
            });
            if (index == 0 && !hasRefreshedOrder) {
              hasRefreshedOrder = true;
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _refreshHome());
            }
            if (index == 1) {
              hasRefreshedOrder = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshOrders();
              });
            }
          },
          onLogout: () {
            showLogoutDialog(context);
          },
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: [
            hasRefreshedOrder == true
                ? BlocProvider(
                    create: (_) => FoodCategoryBloc(),
                    child: FoodOrderingScreenView(
                      key: foodKey,
                      existingOrder: widget.existingOrder,
                      isEditingOrder: widget.isEditingOrder,
                      hasRefreshedOrder: hasRefreshedOrder,
                    ))
                : BlocProvider(
                    create: (_) => FoodCategoryBloc(),
                    child: FoodOrderingScreen(
                      key: foodKey,
                      existingOrder: widget.existingOrder,
                      isEditingOrder: widget.isEditingOrder,
                      hasRefreshedOrder: hasRefreshedOrder,
                    ),
                  ),
            OrdersTabbedScreen(
              key: PageStorageKey('OrdersTabbedScreen'),
              orderAllKey: orderAllTabKey,
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
