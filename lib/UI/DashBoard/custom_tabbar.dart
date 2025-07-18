import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:simple/Alertbox/AlertDialogBox.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/CustomAppBar/custom_appbar.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/UI/Order/order_tab_page.dart';



class DashBoard extends StatelessWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderTodayBloc(),
      child: const DashBoardScreen(),
    );
  }
}

class DashBoardScreen extends StatefulWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;

  const DashBoardScreen({
    super.key,
    this.selectTab,
    this.existingOrder,
    this.isEditingOrder,
  });

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int selectedIndex = 0;
  bool orderLoad = false;
  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  GetOrderListTodayModel getOrderListTodayModel = GetOrderListTodayModel();

  @override
  void initState() {
    super.initState();
    context.read<OrderTodayBloc>().add(OrderTodayList(todayDate, todayDate));
    orderLoad = true;
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
            });
          },
          onLogout: () {
            showLogoutDialog(context);
          },
        ),
        body: orderLoad
            ? Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1),
            alignment: Alignment.center,
            child: const SpinKitChasingDots(color: appPrimaryColor, size: 30))
            : getOrderListTodayModel.data == null ||
            getOrderListTodayModel.data == [] ||
            getOrderListTodayModel.data!.isEmpty
            ? Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1),
            alignment: Alignment.center,
            child: Text(
              "No Orders Today !!!",
              style: MyTextStyle.f16(
                greyColor,
                weight: FontWeight.w500,
              ),
            ))
            :IndexedStack(
          index: selectedIndex,
          children: [
            FoodOrderingScreen(
              existingOrder: widget.existingOrder,
              isEditingOrder: widget.isEditingOrder,
            ),
            const OrdersTabbedScreen(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderTodayBloc, dynamic>(
      buildWhen: (previous, current) {
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
      },
      builder: (context, state) {
        return mainContainer();
      },
    );
  }
}
