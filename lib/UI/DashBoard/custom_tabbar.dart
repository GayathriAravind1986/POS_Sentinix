import 'package:flutter/material.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/UI/CustomAppBar/custom_appbar.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/UI/Order/order_tab_page.dart';

import '../../Alertbox/AlertDialogBox.dart';

class DashBoardScreen extends StatefulWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;
  const DashBoardScreen(
      {super.key, this.selectTab, this.existingOrder, this.isEditingOrder});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    debugPrint("selectTab:${widget.selectTab}");
    debugPrint("isEditDash:${widget.isEditingOrder}");
    debugPrint("getViewDash:${widget.existingOrder}");
    if (widget.selectTab != null) {
      selectedIndex = widget.selectTab!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          selectedIndex: selectedIndex,
          onTabSelected: (index) {
            setState(() {
              selectedIndex = index;
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
            OrdersTabbedScreen()
          ],
        ),
      ),
    );
  }
}
