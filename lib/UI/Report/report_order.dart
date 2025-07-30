import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/Bloc/Report/report_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/ModelClass/Order/Delete_order_model.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/ModelClass/Report/Get_report_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/imin_abstract.dart';
import 'package:simple/UI/Report/pop_view_report.dart';

class ReportView extends StatelessWidget {
  final GlobalKey<ReportViewViewState>? reportKey;
  bool? hasRefreshedReport;
  ReportView({
    super.key,
    this.reportKey,
    this.hasRefreshedReport,
  });

  @override
  Widget build(BuildContext context) {
    return ReportViewView(
        reportKey: reportKey, hasRefreshedReport: hasRefreshedReport);
  }
}

class ReportViewView extends StatefulWidget {
  final GlobalKey<ReportViewViewState>? reportKey;
  bool? hasRefreshedReport;
  ReportViewView({
    super.key,
    this.reportKey,
    this.hasRefreshedReport,
  });

  @override
  ReportViewViewState createState() => ReportViewViewState();
}

class ReportViewViewState extends State<ReportViewView> {
  GetReportModel getReportModel = GetReportModel();
  late IPrinterService printerService;
  final GlobalKey receiptKey = GlobalKey();
  String? errorMessage;
  bool reportLoad = false;
  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final yesterdayDate = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: 1)));
  String? fromDate;
  final List<Map<String, dynamic>> items = [
    {
      'no': 1,
      'product': 'Chicken Biryani',
      'qty': 2,
      'amount': 250,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
    {
      'no': 2,
      'product': 'Mutton Biryani',
      'qty': 4,
      'amount': 1200,
    },
  ];
  void refreshReport() {
    if (!mounted || !context.mounted) return;
    context.read<ReportTodayBloc>().add(
          ReportTodayList(yesterdayDate, todayDate),
        );
    setState(() {
      reportLoad = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.hasRefreshedReport == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.reportKey?.currentState?.refreshReport();
        setState(() {
          reportLoad = true;
        });
      });
    } else {
      debugPrint("reportInit");
      debugPrint("reportInit:${widget.hasRefreshedReport}");
      debugPrint("reportInit:${widget.reportKey}");
      context.read<ReportTodayBloc>().add(
            ReportTodayList(yesterdayDate, todayDate),
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalQty =
        items.fold(0, (sum, item) => sum + (item['qty'] as num).toInt());
    double totalAmount = items.fold(
        0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
    Widget mainContainer() {
      return reportLoad
          ? Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1),
              alignment: Alignment.center,
              child: const SpinKitChasingDots(color: appPrimaryColor, size: 30))
          : getReportModel.data == null ||
                  getReportModel.data == [] ||
                  getReportModel.data!.isEmpty
              ? Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  alignment: Alignment.center,
                  child: Text(
                    "No Report Today !!!",
                    style: MyTextStyle.f16(
                      greyColor,
                      weight: FontWeight.w500,
                    ),
                  ))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text("Report",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        verticalSpace(height: 10),
                        Table(
                          border: TableBorder.all(),
                          columnWidths: const {
                            0: FixedColumnWidth(50), // S.No
                            1: FlexColumnWidth(), // Product Name
                            2: FixedColumnWidth(75), // Quantity
                            3: FixedColumnWidth(80), // Amount
                          },
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(color: appPrimaryColor),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("S.No",
                                      style: TextStyle(
                                          color: whiteColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Product Name",
                                      style: TextStyle(
                                          color: whiteColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Quantity",
                                      style: TextStyle(
                                          color: whiteColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("Amount",
                                      style: TextStyle(
                                          color: whiteColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            // Data Rows
                            ...List.generate(getReportModel.data!.length,
                                (index) {
                              final item = getReportModel.data![index];
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Center(
                                        child: Text("${index + 1}")), // S.No
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(item.productName ?? ""),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Center(
                                        child: Text("${item.totalQty ?? ""}")),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Center(
                                        child: Text(item.totalAmount
                                                ?.toStringAsFixed(2) ??
                                            "")),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Total Section
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Total Quantity: $totalQty",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Total Amount: ₹$totalAmount",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    ThermalReportReceiptDialog(getReportModel),
                              );
                            },
                            icon: const Icon(Icons.print),
                            label: const Text("Print"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              foregroundColor: whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
    }

    return BlocBuilder<ReportTodayBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetReportModel) {
          getReportModel = current;
          if (getReportModel.errorResponse?.isUnauthorized == true) {
            _handle401Error();
            return true;
          }
          if (getReportModel.success == true) {
            setState(() {
              reportLoad = false;
            });
          } else {
            setState(() {
              reportLoad = false;
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

  void _handle401Error() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("token");
    await sharedPreferences.clear();
    showToast("Session expired. Please login again.", context, color: false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
