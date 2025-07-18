import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/ModelClass/Order/Delete_order_model.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/DashBoard/custom_tabbar.dart';
import 'package:simple/UI/Order/Helper/time_formatter.dart';
import 'package:simple/UI/Order/pop_view_order.dart';

class OrderView extends StatelessWidget {
  final String type;
  const OrderView({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderTodayBloc(),
      child: OrderViewView(
        type: type,
      ),
    );
  }
}

class OrderViewView extends StatefulWidget {
  final String type;
  const OrderViewView({
    super.key,
    required this.type,
  });

  @override
  OrderViewViewState createState() => OrderViewViewState();
}

class OrderViewViewState extends State<OrderViewView> {
  GetOrderListTodayModel getOrderListTodayModel = GetOrderListTodayModel();
  DeleteOrderModel deleteOrderModel = DeleteOrderModel();
  GetViewOrderModel getViewOrderModel = GetViewOrderModel();
  bool orderLoad = false;
  bool view = false;
  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? fromDate;
  String? type;
  @override
  void initState() {
    super.initState();
    DateTime dateNow = DateTime.now();
    fromDate = formatToApiDate(dateNow);
    context.read<OrderTodayBloc>().add(OrderTodayList(todayDate, todayDate));
    orderLoad = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    type = widget.type == "Takeaway" ? "TAKE-AWAY" : "DINE-IN";
    final filteredOrders = getOrderListTodayModel.data?.where((order) {
          if (widget.type == "All") return true;
          return order.orderType?.toUpperCase() == type;
        }).toList() ??
        [];
    Widget mainContainer() {
      return orderLoad
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
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: filteredOrders.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.8,
                    ),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final payment = order.payments?.isNotEmpty == true
                          ? order.payments!.first
                          : null;

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
                              // 🔹 Order ID & Total
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Order ID: ${order.orderNumber ?? '--'}",
                                      style: MyTextStyle.f14(appPrimaryColor,
                                          weight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "₹${order.total?.toStringAsFixed(2) ?? '0.00'}",
                                    style: MyTextStyle.f14(appPrimaryColor,
                                        weight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Time: ${formatTime(order.invoice?.date)}",
                                  ),
                                  Text(
                                    payment?.paymentMethod != null &&
                                            payment!.paymentMethod!.isNotEmpty
                                        ? "Payment: ${payment.paymentMethod}: ₹${payment.amount?.toStringAsFixed(2) ?? '0.00'}"
                                        : "Payment: N/A",
                                    style: MyTextStyle.f12(greyColor),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Type: ${order.orderType ?? '--'}"),
                                  Text(
                                    "Status: ${order.orderStatus}",
                                    style: TextStyle(
                                      color: order.orderStatus == 'COMPLETED'
                                          ? greenColor
                                          : orangeColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // 🔹 Table Info
                              Text("Table: ${order.tableName ?? 'N/A'}"),

                              const Spacer(),

                              // 🔹 Action Icons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: appPrimaryColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        view = true;
                                      });
                                      context
                                          .read<OrderTodayBloc>()
                                          .add(ViewOrder(order.id));
                                    },
                                  ),
                                  SizedBox(width: 5),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: appPrimaryColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        view = false;
                                      });
                                      context
                                          .read<OrderTodayBloc>()
                                          .add(ViewOrder(order.id));
                                    },
                                  ),
                                  SizedBox(width: 5),
                                  IconButton(
                                    icon: Icon(
                                      Icons.print_outlined,
                                      color: appPrimaryColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        view = true;
                                      });
                                      context
                                          .read<OrderTodayBloc>()
                                          .add(ViewOrder(order.id));
                                    },
                                  ),
                                  SizedBox(width: 5),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: appPrimaryColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<OrderTodayBloc>()
                                          .add(DeleteOrder(order.id));
                                    },
                                  ),
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
        if (current is DeleteOrderModel) {
          deleteOrderModel = current;
          if (deleteOrderModel.success == true) {
            showToast("${deleteOrderModel.message}", context, color: true);
            context
                .read<OrderTodayBloc>()
                .add(OrderTodayList(todayDate, todayDate));
          } else {
            showToast("${deleteOrderModel.message}", context, color: false);
          }
          return true;
        }
        if (current is GetViewOrderModel) {
          getViewOrderModel = current;
          if (getViewOrderModel.success == true) {
            if (view == true) {
              showDialog(
                context: context,
                builder: (context) => OrderInvoiceDialog(getViewOrderModel),
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => DashBoardScreen(
                            selectTab: 0,
                            existingOrder: getViewOrderModel,
                            isEditingOrder: true,
                          )),
                  (Route<dynamic> route) => false);
            }
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
