import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/ModelClass/Order/Post_generate_order_model.dart';
import 'package:simple/ModelClass/Order/Update_generate_order_model.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/image.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Cart/Widget/payment_option.dart';
import 'package:simple/UI/Home_screen/Helper/order_helper.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/imin_abstract.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/mock_imin_printer_chrome.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/real_device_printer.dart';
import 'package:simple/UI/Home_screen/Widget/category_card.dart';
import 'package:simple/UI/IminHelper/printer_helper.dart';

class FoodOrderingScreen extends StatelessWidget {
  final GetViewOrderModel? existingOrder;
  bool? isEditingOrder;
  FoodOrderingScreen({
    super.key,
    this.existingOrder,
    this.isEditingOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCategoryBloc(),
      child: FoodOrderingScreenView(
          existingOrder: existingOrder, isEditingOrder: isEditingOrder),
    );
  }
}

class FoodOrderingScreenView extends StatefulWidget {
  final GetViewOrderModel? existingOrder;
  bool? isEditingOrder;
  FoodOrderingScreenView({
    super.key,
    this.existingOrder,
    this.isEditingOrder,
  });

  @override
  FoodOrderingScreenViewState createState() => FoodOrderingScreenViewState();
}

class FoodOrderingScreenViewState extends State<FoodOrderingScreenView> {
  GetCategoryModel getCategoryModel = GetCategoryModel();
  GetProductByCatIdModel getProductByCatIdModel = GetProductByCatIdModel();
  PostAddToBillingModel postAddToBillingModel = PostAddToBillingModel();
  PostGenerateOrderModel postGenerateOrderModel = PostGenerateOrderModel();
  GetTableModel getTableModel = GetTableModel();
  UpdateGenerateOrderModel updateGenerateOrderModel =
      UpdateGenerateOrderModel();

  TextEditingController searchController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  List<TextEditingController> splitAmountControllers = [];
  List<String?> selectedPaymentMethods = [];
  double totalSplit = 0.0;

  String selectedCategory = "All";
  String? selectedCatId = "";
  bool selectDineIn = true;

  bool isSplitPayment = false;
  bool splitChange = false;
  bool isCompleteOrder = false;
  int _paymentFieldCount = 1;
  bool allSplitAmountsFilled() {
    return splitAmountControllers
        .every((controller) => controller.text.trim().isNotEmpty);
  }

  bool allPaymentMethodsSelected() {
    return selectedPaymentMethods
        .every((method) => method != null && method.isNotEmpty);
  }

  void addPaymentField() {
    if (_paymentFieldCount < 3) {
      setState(() {
        _paymentFieldCount++;
        splitAmountControllers.add(TextEditingController());
        selectedPaymentMethods.add(null);
      });
    }
  }

  dynamic selectedValue;
  dynamic tableId;

  String? errorMessage;
  bool categoryLoad = false;
  bool orderLoad = false;
  bool completeLoad = false;
  bool cartLoad = false;
  bool isToppingSelected = false;

  int counter = 0;
  String selectedFullPaymentMethod = "";
  double totalAmount = 0.0;
  double paidAmount = 0.0;
  double balanceAmount = 0.0;
  bool isCartLoaded = false;
  List<Map<String, dynamic>> billingItems = [];
  late IPrinterService printerService;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      printerService = MockPrinterService();
      debugPrint("Using MockPrinterService (Web)");
    } else if (Platform.isAndroid) {
      printerService = RealPrinterService();
      debugPrint("Using RealPrinterService (Android)");
    } else {
      printerService = MockPrinterService();
      debugPrint("Using fallback MockPrinterService");
    }
    context.read<FoodCategoryBloc>().add(FoodCategory());
    context
        .read<FoodCategoryBloc>()
        .add(FoodProductItem(selectedCatId.toString(), searchController.text));
    context.read<FoodCategoryBloc>().add(TableDine());
    categoryLoad = true;
    debugPrint("existingViewModel:${widget.existingOrder}");
    debugPrint("orderStatusEdit:${widget.existingOrder?.data!.orderStatus}");
    debugPrint("isCompletedflag:$isCompleteOrder");
    debugPrint("isEdit:${widget.isEditingOrder}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditingOrder == true && widget.existingOrder != null) {
        loadExistingOrder(widget.existingOrder!);
      } else {
        resetCartState();
      }
    });
  }

  void loadExistingOrder(GetViewOrderModel? order) {
    debugPrint("Loading existing order data...");

    if (order == null || order.data == null) return;

    final data = order.data!;

    setState(() {
      selectDineIn = data.orderType == 'DINE-IN';
      tableId = data.tableNo;
      debugPrint("tableNoEdit:$tableId");
      selectedValue = data.tableName;
      debugPrint("tableNameEdit:$selectedValue");
      isCartLoaded = true;

      billingItems = data.items?.map((e) {
            final product = e.product;
            return {
              "_id": product?.id,
              "name": e.name,
              "basePrice": (product?.basePrice ?? 0),
              "qty": e.quantity,
              "image": product?.image,
              "selectedAddons": e.addons?.map((addonItem) {
                    final addon = addonItem.addon;
                    return {
                      "_id": addon?.id,
                      "name": addon?.name,
                      "price": addon?.price,
                      "isFree": addon?.isFree,
                      "quantity": addonItem.quantity ?? 1,
                      "isAvailable": addon?.isAvailable,
                      "maxQuantity": addon?.maxQuantity,
                    };
                  }).toList() ??
                  [],
            };
          }).toList() ??
          [];
      context
          .read<FoodCategoryBloc>()
          .add(AddToBilling(List.from(billingItems)));
    });
  }

  void resetCartState() {
    setState(() {
      billingItems.clear();
      tableId = null;
      selectedValue = null;
      selectDineIn = true;
      isSplitPayment = false;
      amountController.clear();
      selectedFullPaymentMethod = "";
      context.read<FoodCategoryBloc>().add(AddToBilling([]));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget mainContainer() {
      final sortedCategories = (getCategoryModel.data ?? [])
          .map((data) => Category(
                id: data.id,
                name: data.name,
                image: data.image,
              ))
          .toList()
        ..sort(
            (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));

      final List<Category> displayedCategories = [
        Category(name: 'All', image: Images.all, id: ""),
        ...sortedCategories,
      ];

      @override
      Widget price(String label, String value, {bool isBold = false}) {
        return SizedBox(
          height: 20,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: isBold
                      ? MyTextStyle.f12(blackColor, weight: FontWeight.bold)
                      : MyTextStyle.f12(greyColor),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: isBold
                      ? MyTextStyle.f12(blackColor, weight: FontWeight.bold)
                      : MyTextStyle.f12(blackColor),
                ),
              ),
            ],
          ),
        );
      }

      return categoryLoad
          ? Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2),
              alignment: Alignment.center,
              child: const SpinKitChasingDots(color: appPrimaryColor, size: 30))
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(children: [
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
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Choose Category",
                                      style: MyTextStyle.f18(blackColor,
                                          weight: FontWeight.bold)),
                                  SizedBox(width: size.width * 0.2),
                                  SizedBox(
                                    width: size.width * 0.25,
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Search product',
                                        prefixIcon: Icon(Icons.search),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                      ),
                                      onChanged: (value) {
                                        searchController
                                          ..text = (value)
                                          ..selection = TextSelection.collapsed(
                                              offset:
                                                  searchController.text.length);
                                        setState(() {
                                          context.read<FoodCategoryBloc>().add(
                                                FoodProductItem(
                                                    selectedCatId.toString(),
                                                    searchController.text),
                                              );
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            displayedCategories.isEmpty
                                ? Center(
                                    child: Text("No category found",
                                        style: MyTextStyle.f18(blackColor,
                                            weight: FontWeight.bold)))
                                : SizedBox(
                                    height: size.height * 0.13,
                                    width: size.width * 0.6,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: displayedCategories.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(width: 12),
                                      itemBuilder: (context, index) {
                                        final category =
                                            displayedCategories[index];
                                        final isSelected =
                                            category.name == selectedCategory;
                                        return CategoryCard(
                                          label: category.name!,
                                          imagePath: category.image!,
                                          isSelected: isSelected,
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = category.name!;
                                              selectedCatId = category.id;
                                              if (selectedCategory == 'All') {
                                                context
                                                    .read<FoodCategoryBloc>()
                                                    .add(FoodProductItem(
                                                        selectedCatId
                                                            .toString(),
                                                        searchController.text));
                                              } else {
                                                context
                                                    .read<FoodCategoryBloc>()
                                                    .add(
                                                      FoodProductItem(
                                                          selectedCatId
                                                              .toString(),
                                                          searchController
                                                              .text),
                                                    );
                                              }
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                            SizedBox(
                              height: size.height * 0.6,
                              width: size.width * 0.6,
                              child:
                                  getProductByCatIdModel.rows == null ||
                                          getProductByCatIdModel.rows == [] ||
                                          getProductByCatIdModel.rows!.isEmpty
                                      ? Center(
                                          child: Text('No products found',
                                              style: MyTextStyle.f18(blackColor,
                                                  weight: FontWeight.bold)))
                                      : GridView.builder(
                                          padding: EdgeInsets.all(12),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisExtent: size.height * 0.35,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                          ),
                                          itemCount: getProductByCatIdModel
                                              .rows!.length,
                                          itemBuilder: (_, index) {
                                            final p = getProductByCatIdModel
                                                .rows![index];
                                            int counter =
                                                billingItems.firstWhere(
                                                      (item) =>
                                                          item['_id'] == p.id,
                                                      orElse: () => {},
                                                    )['qty'] ??
                                                    0;
                                            return Card(
                                              color: whiteColor,
                                              shadowColor: greyColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          size.height * 0.12,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: p.image!,
                                                            width: size.width *
                                                                0.2,
                                                            height:
                                                                size.height *
                                                                    0.12,
                                                            fit: BoxFit.cover,
                                                            errorWidget:
                                                                (context, url,
                                                                    error) {
                                                              return const Icon(
                                                                Icons.error,
                                                                size: 30,
                                                                color:
                                                                    appHomeTextColor,
                                                              );
                                                            },
                                                            progressIndicatorBuilder: (context,
                                                                    url,
                                                                    downloadProgress) =>
                                                                const SpinKitCircle(
                                                                    color:
                                                                        appPrimaryColor,
                                                                    size: 30),
                                                          )),
                                                    ),
                                                    verticalSpace(height: 5),
                                                    SizedBox(
                                                      width: size.width * 0.25,
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          p.name ?? '',
                                                          style: MyTextStyle.f13(
                                                              blackColor,
                                                              weight: FontWeight
                                                                  .w500),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    verticalSpace(height: 5),
                                                    SizedBox(
                                                      width: size.width * 0.25,
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '₹ ${p.basePrice}',
                                                          style: MyTextStyle.f13(
                                                              blackColor,
                                                              weight: FontWeight
                                                                  .w600),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    verticalSpace(height: 15),
                                                    counter == 0
                                                        ? ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                p.counter = 1;
                                                                if (p.addons!
                                                                    .isNotEmpty) {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context2) {
                                                                      return BlocProvider(
                                                                        create: (context) =>
                                                                            FoodCategoryBloc(),
                                                                        child: BlocProvider
                                                                            .value(
                                                                          value: BlocProvider.of<FoodCategoryBloc>(
                                                                              context,
                                                                              listen: false),
                                                                          child:
                                                                              StatefulBuilder(builder: (context, setState) {
                                                                            return Dialog(
                                                                              insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                              child: Container(
                                                                                constraints: BoxConstraints(
                                                                                  maxWidth: size.width * 0.4,
                                                                                  maxHeight: size.height * 0.6,
                                                                                ),
                                                                                padding: EdgeInsets.all(16),
                                                                                child: SingleChildScrollView(
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                          child: CachedNetworkImage(
                                                                                            imageUrl: p.image!,
                                                                                            width: size.width * 0.5,
                                                                                            height: size.height * 0.2,
                                                                                            fit: BoxFit.cover,
                                                                                            errorWidget: (context, url, error) {
                                                                                              return const Icon(
                                                                                                Icons.error,
                                                                                                size: 30,
                                                                                                color: appHomeTextColor,
                                                                                              );
                                                                                            },
                                                                                            progressIndicatorBuilder: (context, url, downloadProgress) => const SpinKitCircle(color: appPrimaryColor, size: 30),
                                                                                          )),
                                                                                      SizedBox(height: 16),
                                                                                      Text(
                                                                                        'Choose Add‑Ons for ${p.name}',
                                                                                        style: MyTextStyle.f16(
                                                                                          weight: FontWeight.bold,
                                                                                          blackColor,
                                                                                        ),
                                                                                        textAlign: TextAlign.left,
                                                                                      ),
                                                                                      SizedBox(height: 12),
                                                                                      Column(
                                                                                        children: p.addons!.map((e) {
                                                                                          return Padding(
                                                                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                                                            child: Container(
                                                                                              padding: const EdgeInsets.all(8),
                                                                                              decoration: BoxDecoration(
                                                                                                border: Border.all(color: blackColor),
                                                                                                borderRadius: BorderRadius.circular(8),
                                                                                              ),
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  // Addon title & price/free label
                                                                                                  Expanded(
                                                                                                    child: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          e.name ?? '',
                                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                                        ),
                                                                                                        const SizedBox(height: 4),
                                                                                                        Text(
                                                                                                          e.isFree == true ? "Free (Max: ${e.maxQuantity})" : "₹ ${e.price?.toStringAsFixed(2) ?? '0.00'} (Max: ${e.maxQuantity})",
                                                                                                          style: TextStyle(color: Colors.grey.shade600),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),

                                                                                                  // Quantity selector
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      IconButton(
                                                                                                        icon: const Icon(Icons.remove),
                                                                                                        onPressed: (e.quantity) > 0
                                                                                                            ? () {
                                                                                                                setState(() {
                                                                                                                  e.quantity = (e.quantity) - 1;
                                                                                                                });
                                                                                                              }
                                                                                                            : null,
                                                                                                      ),
                                                                                                      Text('${e.quantity}'),
                                                                                                      IconButton(
                                                                                                        icon: const Icon(Icons.add, color: Colors.brown),
                                                                                                        onPressed: (e.quantity) < (e.maxQuantity ?? 1)
                                                                                                            ? () {
                                                                                                                setState(() {
                                                                                                                  e.quantity = (e.quantity) + 1;
                                                                                                                });
                                                                                                              }
                                                                                                            : null,
                                                                                                      ),
                                                                                                    ],
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        }).toList(),
                                                                                      ),
                                                                                      SizedBox(height: 20),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          ElevatedButton(
                                                                                            onPressed: () {
                                                                                              setState(() {
                                                                                                if (counter > 1 || counter == 1) {
                                                                                                  counter--;
                                                                                                }
                                                                                              });

                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                            style: ElevatedButton.styleFrom(
                                                                                              backgroundColor: greyColor.shade400,
                                                                                              minimumSize: Size(80, 40),
                                                                                              padding: EdgeInsets.all(20),
                                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                            ),
                                                                                            child: Text('Cancel', style: MyTextStyle.f14(blackColor)),
                                                                                          ),
                                                                                          SizedBox(width: 8),
                                                                                          ElevatedButton(
                                                                                            onPressed: () {
                                                                                              setState(() {
                                                                                                isSplitPayment = false;
                                                                                                if (widget.isEditingOrder != true) {
                                                                                                  selectDineIn = true;
                                                                                                }
                                                                                                final index = billingItems.indexWhere((item) => item['_id'] == p.id);
                                                                                                if (index != -1) {
                                                                                                  billingItems[index]['qty'] = billingItems[index]['qty'] + 1;
                                                                                                } else {
                                                                                                  billingItems.add({
                                                                                                    "_id": p.id,
                                                                                                    "basePrice": p.basePrice,
                                                                                                    "image": p.image,
                                                                                                    "qty": 1,
                                                                                                    "name": p.name,
                                                                                                    "selectedAddons": p.addons!
                                                                                                        .where((addon) => addon.quantity > 0) // Simple condition - only check quantity
                                                                                                        .map((addon) => {
                                                                                                              "_id": addon.id,
                                                                                                              "price": addon.price,
                                                                                                              "quantity": addon.quantity,
                                                                                                              "name": addon.name,
                                                                                                              "isAvailable": addon.isAvailable,
                                                                                                              "maxQuantity": addon.maxQuantity,
                                                                                                              "isFree": addon.isFree,
                                                                                                            })
                                                                                                        .toList()
                                                                                                  });
                                                                                                }
                                                                                                debugPrint("billingItems: $billingItems");
                                                                                                context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));

                                                                                                setState(() {
                                                                                                  for (var addon in p.addons!) {
                                                                                                    addon.isSelected = false;
                                                                                                    addon.quantity = 0;
                                                                                                  }
                                                                                                });
                                                                                                Navigator.of(context).pop();
                                                                                              });
                                                                                            },
                                                                                            style: ElevatedButton.styleFrom(
                                                                                              backgroundColor: appPrimaryColor,
                                                                                              minimumSize: Size(80, 40),
                                                                                              padding: EdgeInsets.all(20),
                                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                            ),
                                                                                            child: Text('Add to Bill', style: MyTextStyle.f14(whiteColor)),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                } else {
                                                                  setState(() {
                                                                    isSplitPayment =
                                                                        false;
                                                                    if (widget
                                                                            .isEditingOrder !=
                                                                        true) {
                                                                      selectDineIn =
                                                                          true;
                                                                    }
                                                                    final index =
                                                                        billingItems.indexWhere((item) =>
                                                                            item['_id'] ==
                                                                            p.id);
                                                                    if (index !=
                                                                        -1) {
                                                                      billingItems[
                                                                              index]
                                                                          [
                                                                          'qty'] = billingItems[index]
                                                                              [
                                                                              'qty'] +
                                                                          1;
                                                                    } else {
                                                                      billingItems
                                                                          .add({
                                                                        "_id": p
                                                                            .id,
                                                                        "basePrice":
                                                                            p.basePrice,
                                                                        "image":
                                                                            p.image,
                                                                        "qty":
                                                                            1,
                                                                        "name":
                                                                            p.name,
                                                                        "selectedAddons": p
                                                                            .addons!
                                                                            .where((addon) =>
                                                                                addon.quantity >
                                                                                0) // Simple condition - only check quantity
                                                                            .map((addon) =>
                                                                                {
                                                                                  "_id": addon.id,
                                                                                  "price": addon.price,
                                                                                  "quantity": addon.quantity,
                                                                                  "name": addon.name,
                                                                                  "isAvailable": addon.isAvailable,
                                                                                  "maxQuantity": addon.maxQuantity,
                                                                                  "isFree": addon.isFree,
                                                                                })
                                                                            .toList()
                                                                      });
                                                                    }
                                                                    debugPrint(
                                                                        'billingItems: ${jsonEncode(billingItems)}');
                                                                    context
                                                                        .read<
                                                                            FoodCategoryBloc>()
                                                                        .add(AddToBilling(
                                                                            List.from(billingItems)));
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  appPrimaryColor,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          8),
                                                            ),
                                                            child: Text(
                                                                "Add to Billing",
                                                                style: MyTextStyle.f12(
                                                                    whiteColor,
                                                                    weight: FontWeight
                                                                        .bold)),
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 16,
                                                                backgroundColor:
                                                                    greyColor200,
                                                                child:
                                                                    IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .remove,
                                                                      size: 16,
                                                                      color:
                                                                          blackColor),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      isSplitPayment =
                                                                          false;
                                                                      selectDineIn =
                                                                          true;
                                                                      final index = billingItems.indexWhere((item) =>
                                                                          item[
                                                                              '_id'] ==
                                                                          p.id);
                                                                      if (index !=
                                                                              -1 &&
                                                                          billingItems[index]['qty'] >
                                                                              1) {
                                                                        billingItems[index]
                                                                            [
                                                                            'qty'] = billingItems[index]
                                                                                ['qty'] -
                                                                            1;
                                                                      } else {
                                                                        billingItems.removeWhere((item) =>
                                                                            item['_id'] ==
                                                                            p.id);
                                                                      }

                                                                      debugPrint(
                                                                          "billingItems: $billingItems");
                                                                      context
                                                                          .read<
                                                                              FoodCategoryBloc>()
                                                                          .add(AddToBilling(
                                                                              List.from(billingItems)));
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12),
                                                                child: Text(
                                                                  "$counter",
                                                                  style: MyTextStyle
                                                                      .f16(
                                                                          blackColor),
                                                                ),
                                                              ),
                                                              CircleAvatar(
                                                                radius: 16,
                                                                backgroundColor:
                                                                    appPrimaryColor,
                                                                child:
                                                                    IconButton(
                                                                  icon: const Icon(
                                                                      Icons.add,
                                                                      size: 16,
                                                                      color:
                                                                          whiteColor),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      isSplitPayment =
                                                                          false;
                                                                      selectDineIn =
                                                                          true;
                                                                      final index = billingItems.indexWhere((item) =>
                                                                          item[
                                                                              '_id'] ==
                                                                          p.id);
                                                                      if (index !=
                                                                          -1) {
                                                                        billingItems[index]
                                                                            [
                                                                            'qty'] = billingItems[index]
                                                                                ['qty'] +
                                                                            1;
                                                                      } else {
                                                                        billingItems
                                                                            .add({
                                                                          "_id":
                                                                              p.id,
                                                                          "basePrice":
                                                                              p.basePrice,
                                                                          "image":
                                                                              p.image,
                                                                          "qty":
                                                                              1,
                                                                          "name":
                                                                              p.name,
                                                                          "selectedAddons": p
                                                                              .addons!
                                                                              .where((addon) => addon.quantity > 0) // Simple condition - only check quantity
                                                                              .map((addon) => {
                                                                                    "_id": addon.id,
                                                                                    "price": addon.price,
                                                                                    "quantity": addon.quantity,
                                                                                    "name": addon.name,
                                                                                    "isAvailable": addon.isAvailable,
                                                                                    "maxQuantity": addon.maxQuantity,
                                                                                    "isFree": addon.isFree,
                                                                                  })
                                                                              .toList()
                                                                        });
                                                                      }

                                                                      debugPrint(
                                                                          "billingItems: $billingItems");
                                                                      context
                                                                          .read<
                                                                              FoodCategoryBloc>()
                                                                          .add(AddToBilling(
                                                                              List.from(billingItems)));
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            )
                          ],
                        ),
                      ]),
                ),
                SizedBox(width: 16),
                SizedBox(
                    width: size.width * 0.32,
                    child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: double.infinity,
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
                        child: SingleChildScrollView(
                            child:
                                postAddToBillingModel.items == null ||
                                        postAddToBillingModel.items!.isEmpty ||
                                        postAddToBillingModel.items == []
                                    ? SingleChildScrollView(
                                        child: Container(
                                          margin: EdgeInsets.only(top: 30),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        // Add functionality for "Dine In" button
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              appPrimaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Dine In",
                                                            style:
                                                                MyTextStyle.f14(
                                                                    whiteColor),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {},
                                                      child: Center(
                                                        child: Text("Take Away",
                                                            style:
                                                                MyTextStyle.f14(
                                                              blackColor,
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "Bills",
                                                    style: MyTextStyle.f14(
                                                        blackColor,
                                                        weight:
                                                            FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                        Icons.refresh),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 25),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "No.items in bill",
                                                      style: MyTextStyle.f14(
                                                          greyColor,
                                                          weight:
                                                              FontWeight.w400),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text("₹ 0.00")
                                                  ]),
                                              Divider(),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Subtotal",
                                                      style: MyTextStyle.f14(
                                                          greyColor,
                                                          weight:
                                                              FontWeight.w400),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text("₹ 0.00")
                                                  ]),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Total Tax",
                                                      style: MyTextStyle.f14(
                                                          greyColor,
                                                          weight:
                                                              FontWeight.w400),
                                                    ),
                                                    Text("₹ 0.00"),
                                                  ]),
                                              SizedBox(height: 8),
                                              Divider(),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Total",
                                                      style: MyTextStyle.f14(
                                                          blackColor,
                                                          weight:
                                                              FontWeight.w600),
                                                    ),
                                                    Text("₹ 0.00",
                                                        style: MyTextStyle.f18(
                                                            blackColor,
                                                            weight: FontWeight
                                                                .w600)),
                                                  ]),
                                              SizedBox(height: 12),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Current Payment Amount",
                                                      style: MyTextStyle.f14(
                                                          blackColor,
                                                          weight:
                                                              FontWeight.w400),
                                                    ),
                                                    Text("₹ 0.00",
                                                        style: MyTextStyle.f14(
                                                            blackColor,
                                                            weight: FontWeight
                                                                .w400)),
                                                  ]),
                                              SizedBox(height: 12),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: greyColor200,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              appPrimaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Full Payment",
                                                            style:
                                                                MyTextStyle.f12(
                                                              whiteColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: greyColor200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Split Payment",
                                                            style:
                                                                MyTextStyle.f12(
                                                              blackColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Text("Payment Method",
                                                  style: MyTextStyle.f12(
                                                      blackColor,
                                                      weight: FontWeight.bold)),
                                              SizedBox(height: 12),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Wrap(
                                                  spacing: 12,
                                                  runSpacing: 12,
                                                  children: [
                                                    PaymentOption(
                                                        icon: Icons.money,
                                                        label: "Cash",
                                                        selected: false),
                                                    PaymentOption(
                                                        icon: Icons.credit_card,
                                                        label: "Card",
                                                        selected: false),
                                                    PaymentOption(
                                                        icon: Icons.qr_code,
                                                        label: "UPI",
                                                        selected: false),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        debugPrint(
                                                            "billItem:$billingItems");
                                                        setState(() {
                                                          if (billingItems ==
                                                                  [] ||
                                                              billingItems
                                                                  .isEmpty) {
                                                            showToast(
                                                                "No items in the bill to save or complete.",
                                                                context,
                                                                color: false);
                                                          }
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            appGreyColor,
                                                        minimumSize: const Size(
                                                            0,
                                                            50), // Height only
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Save Order",
                                                        style: TextStyle(
                                                            color: blackColor),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          10), // Space between buttons
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          if (billingItems ==
                                                                  [] ||
                                                              billingItems
                                                                  .isEmpty) {
                                                            showToast(
                                                                "No items in the bill to save or complete.",
                                                                context,
                                                                color: false);
                                                          }
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            appGreyColor,
                                                        minimumSize:
                                                            const Size(0, 50),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Complete Order",
                                                        style: TextStyle(
                                                            color: blackColor),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(top: 30),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          selectDineIn = true;
                                                          isSplitPayment =
                                                              false;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8),
                                                        decoration: BoxDecoration(
                                                            color: selectDineIn ==
                                                                    true
                                                                ? appPrimaryColor
                                                                : whiteColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                        child: Center(
                                                          child: Text("Dine In",
                                                              style: MyTextStyle.f14(
                                                                  selectDineIn ==
                                                                          true
                                                                      ? whiteColor
                                                                      : blackColor)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          selectDineIn = false;
                                                          isSplitPayment =
                                                              false;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8),
                                                        decoration: BoxDecoration(
                                                            color: selectDineIn ==
                                                                    false
                                                                ? appPrimaryColor
                                                                : whiteColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                        child: Center(
                                                            child: Text(
                                                                "Take Away",
                                                                style: MyTextStyle.f14(
                                                                    selectDineIn ==
                                                                            false
                                                                        ? whiteColor
                                                                        : blackColor))),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Text(
                                                    "Bills",
                                                    style: MyTextStyle.f14(
                                                        blackColor,
                                                        weight:
                                                            FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        billingItems.clear();
                                                        selectedValue = null;
                                                        tableId = null;
                                                        isCompleteOrder = false;
                                                        isSplitPayment = false;
                                                        amountController
                                                            .clear();
                                                        selectedFullPaymentMethod =
                                                            "";
                                                        widget.isEditingOrder =
                                                            false;
                                                      });
                                                      context
                                                          .read<
                                                              FoodCategoryBloc>()
                                                          .add(AddToBilling(
                                                              List.from(
                                                                  billingItems)));
                                                    },
                                                    icon: const Icon(
                                                        Icons.refresh),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              if (selectDineIn == true)
                                                Text(
                                                  'Choose Table',
                                                  style: MyTextStyle.f14(
                                                    blackColor,
                                                    weight: FontWeight.bold,
                                                  ),
                                                ),
                                              if (selectDineIn == true)
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    value: (getTableModel.data
                                                                ?.any((item) =>
                                                                    item.name ==
                                                                    selectedValue) ??
                                                            false)
                                                        ? selectedValue
                                                        : null,
                                                    icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: appPrimaryColor,
                                                    ),
                                                    isExpanded: true,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                          color:
                                                              appPrimaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                    items: getTableModel.data
                                                        ?.map((item) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: item.name,
                                                        child: Text(
                                                          "Table ${item.name}",
                                                          style:
                                                              MyTextStyle.f14(
                                                            blackColor,
                                                            weight: FontWeight
                                                                .normal,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      if (newValue != null) {
                                                        setState(() {
                                                          selectedValue =
                                                              newValue;
                                                          final selectedItem =
                                                              getTableModel.data
                                                                  ?.firstWhere((item) =>
                                                                      item.name ==
                                                                      newValue);
                                                          tableId = selectedItem
                                                              ?.id
                                                              .toString();
                                                        });
                                                        debugPrint(
                                                            "Selected TableName: $selectedValue");
                                                        debugPrint(
                                                            "Table ID: $tableId");
                                                      }
                                                    },
                                                    hint: Text(
                                                      '-- Select Table --',
                                                      style: MyTextStyle.f14(
                                                        blackColor,
                                                        weight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              Divider(),
                                              Column(
                                                children:
                                                    postAddToBillingModel.items!
                                                        .map(
                                                          (e) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: e
                                                                            .image ??
                                                                        "", // Using dot notation
                                                                    width: size
                                                                            .width *
                                                                        0.04,
                                                                    height: size
                                                                            .height *
                                                                        0.05,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorWidget:
                                                                        (context,
                                                                            url,
                                                                            error) {
                                                                      return const Icon(
                                                                        Icons
                                                                            .error,
                                                                        size:
                                                                            30,
                                                                        color:
                                                                            appHomeTextColor,
                                                                      );
                                                                    },
                                                                    progressIndicatorBuilder: (context,
                                                                            url,
                                                                            downloadProgress) =>
                                                                        const SpinKitCircle(
                                                                            color:
                                                                                appPrimaryColor,
                                                                            size:
                                                                                30),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text("${e.name}", // Using dot notation
                                                                                    style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
                                                                                Text("x ${e.qty}", // Using dot notation
                                                                                    style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          // Quantity controls for cart items - ALWAYS VISIBLE
                                                                          Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              IconButton(
                                                                                icon: Icon(Icons.remove_circle_outline, size: 20),
                                                                                padding: EdgeInsets.all(4),
                                                                                constraints: BoxConstraints(),
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    final index = billingItems.indexWhere((item) => item['_id'] == e.id); // Using dot notation
                                                                                    if (index != -1 && billingItems[index]['qty'] > 1) {
                                                                                      billingItems[index]['qty'] = billingItems[index]['qty'] - 1;
                                                                                    } else {
                                                                                      billingItems.removeWhere((item) => item['_id'] == e.id); // Using dot notation
                                                                                    }
                                                                                    debugPrint("billingItems: $billingItems");
                                                                                    context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));
                                                                                  });
                                                                                },
                                                                              ),
                                                                              Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                child: Text("${e.qty}", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                              ),
                                                                              IconButton(
                                                                                icon: Icon(Icons.add_circle_outline, size: 20),
                                                                                padding: EdgeInsets.all(4),
                                                                                constraints: BoxConstraints(),
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    final index = billingItems.indexWhere((item) => item['_id'] == e.id);
                                                                                    if (index != -1) {
                                                                                      billingItems[index]['qty'] = billingItems[index]['qty'] + 1;
                                                                                    } else {
                                                                                      billingItems.add({
                                                                                        "_id": e.id,
                                                                                        "basePrice": e.basePrice,
                                                                                        "image": e.image,
                                                                                        "qty": 1,
                                                                                        "name": e.name,
                                                                                        "selectedAddons": (e.selectedAddons != null)
                                                                                            ? e.selectedAddons!
                                                                                                .where((addon) => (addon.quantity ?? 0) > 0) // Simple quantity check
                                                                                                .map((addon) => {
                                                                                                      "_id": addon.id,
                                                                                                      "price": addon.price ?? 0,
                                                                                                      "quantity": addon.quantity ?? 0,
                                                                                                      "name": addon.name,
                                                                                                      "isAvailable": addon.isAvailable,
                                                                                                      "maxQuantity": addon.quantity,
                                                                                                      "isFree": addon.isFree,
                                                                                                    })
                                                                                                .toList()
                                                                                            : []
                                                                                      });
                                                                                    }
                                                                                    debugPrint("billingItems: $billingItems");
                                                                                    context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));
                                                                                  });
                                                                                },
                                                                              ),
                                                                              IconButton(
                                                                                icon: Icon(Icons.delete, color: redColor, size: 20),
                                                                                padding: EdgeInsets.all(4),
                                                                                constraints: BoxConstraints(),
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    billingItems.removeWhere((item) => item['_id'] == e.id);
                                                                                    debugPrint("billingItems: $billingItems");
                                                                                    context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          if (e.selectedAddons != null &&
                                                                              e.selectedAddons!.isNotEmpty)
                                                                            ...e.selectedAddons!.where((addon) => addon.quantity != null && addon.quantity! > 0).map((addon) {
                                                                              return Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 3),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    // Addon name with price or (Free) label
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        "${addon.name} ${addon.isFree == true ? ' (Free)' : ' ₹${addon.price}'}",
                                                                                        style: TextStyle(fontSize: 12, color: greyColor),
                                                                                      ),
                                                                                    ),
                                                                                    Row(
                                                                                      children: [
                                                                                        IconButton(
                                                                                          icon: Icon(Icons.remove_circle_outline),
                                                                                          onPressed: () {
                                                                                            final currentItem = billingItems.firstWhere((item) => item['_id'] == e.id);
                                                                                            final addonsList = currentItem['selectedAddons'] as List;
                                                                                            final addonIndex = addonsList.indexWhere((a) => a['_id'] == addon.id);

                                                                                            if (addonsList[addonIndex]['quantity'] > 1) {
                                                                                              setState(() {
                                                                                                addonsList[addonIndex]['quantity'] = addonsList[addonIndex]['quantity'] - 1;
                                                                                                context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));
                                                                                              });
                                                                                            } else {
                                                                                              setState(() {
                                                                                                addonsList.removeAt(addonIndex);
                                                                                                context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));
                                                                                              });
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                        Text('${addon.quantity}', style: TextStyle(fontSize: 14)),
                                                                                        IconButton(
                                                                                          icon: Icon(Icons.add_circle_outline),
                                                                                          onPressed: () {
                                                                                            final currentItem = billingItems.firstWhere((item) => item['_id'] == e.id);
                                                                                            final addonsList = currentItem['selectedAddons'] as List;
                                                                                            final addonIndex = addonsList.indexWhere((a) => a['_id'] == addon.id);

                                                                                            setState(() {
                                                                                              addonsList[addonIndex]['quantity'] = addonsList[addonIndex]['quantity'] + 1;
                                                                                              context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));
                                                                                            });
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }),
                                                                          price(
                                                                              "Base Price",
                                                                              "₹ ${(e.basePrice! * e.qty!).toStringAsFixed(2)}"),
                                                                          if (e.addonTotal !=
                                                                              0)
                                                                            price('Addons Total',
                                                                                "₹ ${e.addonTotal!.toStringAsFixed(2)}"),

                                                                          // Taxes
                                                                          if ((e.appliedTaxes?.length ?? 0) >
                                                                              0)
                                                                            ...e.appliedTaxes!.map((tax) {
                                                                              return price(
                                                                                "${tax.name} (${tax.percentage ?? 0}%):",
                                                                                "₹ ${tax.amount?.toStringAsFixed(2) ?? '0.00'}",
                                                                              );
                                                                            }),
                                                                          price(
                                                                              "Item Total",
                                                                              "₹ ${(e.basePrice! * e.qty! + (e.addonTotal ?? 0)).toStringAsFixed(2)}",
                                                                              isBold: true),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                              ),
                                              Divider(
                                                  color: greyColor200,
                                                  thickness: 2),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("Subtotal",
                                                        style: MyTextStyle.f12(
                                                            greyColor)),
                                                    SizedBox(height: 8),
                                                    Text(
                                                        "₹ ${postAddToBillingModel.subtotal}")
                                                  ]),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("Total Tax",
                                                        style: MyTextStyle.f12(
                                                            greyColor)),
                                                    Text(
                                                        "₹ ${postAddToBillingModel.totalTax}"),
                                                  ]),
                                              SizedBox(height: 8),
                                              Divider(),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("Total",
                                                        style: MyTextStyle.f18(
                                                            blackColor,
                                                            weight: FontWeight
                                                                .bold)),
                                                    Text(
                                                        "₹ ${postAddToBillingModel.total!.toStringAsFixed(2)}",
                                                        style: MyTextStyle.f18(
                                                            blackColor,
                                                            weight: FontWeight
                                                                .bold)),
                                                  ]),
                                              SizedBox(height: 12),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Current Payment Amount",
                                                      style: MyTextStyle.f14(
                                                          blackColor,
                                                          weight:
                                                              FontWeight.w400),
                                                    ),
                                                    Text(
                                                        "₹ ${postAddToBillingModel.total!.toStringAsFixed(2)}",
                                                        style: MyTextStyle.f14(
                                                            blackColor,
                                                            weight: FontWeight
                                                                .w400)),
                                                  ]),
                                              if (isCompleteOrder == false)
                                                SizedBox(height: 12),
                                              if (isCompleteOrder == false &&
                                                  (widget.isEditingOrder ==
                                                          null ||
                                                      widget.isEditingOrder ==
                                                          false))
                                                Text(
                                                  "Save order to waitlist or complete with payment.",
                                                  style: MyTextStyle.f14(
                                                      greyColor,
                                                      weight: FontWeight.w400),
                                                ),
                                              if (widget.isEditingOrder ==
                                                      true &&
                                                  widget.existingOrder?.data!
                                                          .orderStatus ==
                                                      "COMPLETED")
                                                Text(
                                                  "Order already paid. No additional payment required unless items are added",
                                                  style: MyTextStyle.f14(
                                                      greyColor,
                                                      weight: FontWeight.w400),
                                                ),
                                              if (isCompleteOrder == true)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 15),
                                                  decoration: BoxDecoration(
                                                    color: greyColor200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              splitChange =
                                                                  false;
                                                              isSplitPayment =
                                                                  false;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isSplitPayment
                                                                  ? greyColor200
                                                                  : appPrimaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "Full Payment",
                                                                style:
                                                                    MyTextStyle
                                                                        .f12(
                                                                  isSplitPayment
                                                                      ? blackColor
                                                                      : whiteColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              isSplitPayment =
                                                                  true;
                                                              selectedFullPaymentMethod =
                                                                  "";
                                                              _paymentFieldCount =
                                                                  1;
                                                              splitAmountControllers =
                                                                  [
                                                                TextEditingController()
                                                              ];
                                                              selectedPaymentMethods =
                                                                  [null];
                                                              totalSplit = 0.0;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isSplitPayment
                                                                  ? appPrimaryColor
                                                                  : greyColor200,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "Split Payment",
                                                                style:
                                                                    MyTextStyle
                                                                        .f12(
                                                                  isSplitPayment
                                                                      ? whiteColor
                                                                      : blackColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (isCompleteOrder == true)
                                                !isSplitPayment
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                            SizedBox(
                                                                height: 12),
                                                            Text(
                                                                "Payment Method",
                                                                style: MyTextStyle.f14(
                                                                    blackColor,
                                                                    weight: FontWeight
                                                                        .bold)),
                                                            SizedBox(
                                                                height: 12),
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Wrap(
                                                                spacing: 12,
                                                                runSpacing: 12,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        selectedFullPaymentMethod =
                                                                            "Cash";
                                                                      });
                                                                    },
                                                                    child:
                                                                        PaymentOption(
                                                                      icon: Icons
                                                                          .money,
                                                                      label:
                                                                          "Cash",
                                                                      selected:
                                                                          selectedFullPaymentMethod ==
                                                                              "Cash",
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        selectedFullPaymentMethod =
                                                                            "Card";
                                                                      });
                                                                    },
                                                                    child:
                                                                        PaymentOption(
                                                                      icon: Icons
                                                                          .credit_card,
                                                                      label:
                                                                          "Card",
                                                                      selected:
                                                                          selectedFullPaymentMethod ==
                                                                              "Card",
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        selectedFullPaymentMethod =
                                                                            "UPI";
                                                                      });
                                                                    },
                                                                    child:
                                                                        PaymentOption(
                                                                      icon: Icons
                                                                          .qr_code,
                                                                      label:
                                                                          "UPI",
                                                                      selected:
                                                                          selectedFullPaymentMethod ==
                                                                              "UPI",
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ])
                                                    : Container(),
                                              isCompleteOrder == true &&
                                                      !isSplitPayment &&
                                                      selectedFullPaymentMethod ==
                                                          "Cash"
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: 12),
                                                        TextField(
                                                          controller:
                                                              amountController,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "Enter amount paid (₹)",
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          appGreyColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          appPrimaryColor,
                                                                      width: 2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              totalAmount = double.tryParse(
                                                                      postAddToBillingModel
                                                                          .total
                                                                          .toString()) ??
                                                                  0.0;
                                                              paidAmount = double
                                                                      .tryParse(
                                                                          value) ??
                                                                  0.0;
                                                              balanceAmount =
                                                                  paidAmount -
                                                                      totalAmount;
                                                            });
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        if (amountController
                                                            .text.isNotEmpty)
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                "Balance",
                                                                style:
                                                                    MyTextStyle
                                                                        .f14(
                                                                  weight:
                                                                      FontWeight
                                                                          .w400,
                                                                  greyColor,
                                                                ),
                                                              ),
                                                              Text(
                                                                "₹ ${balanceAmount.toStringAsFixed(2)}",
                                                                style:
                                                                    MyTextStyle
                                                                        .f14(
                                                                  weight:
                                                                      FontWeight
                                                                          .w400,
                                                                  balanceAmount <
                                                                          0
                                                                      ? redColor
                                                                      : greenColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    )
                                                  : const SizedBox.shrink(),
                                              if (isCompleteOrder == true)
                                                isSplitPayment
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Text(
                                                            "Split Payment",
                                                            style: MyTextStyle.f20(
                                                                blackColor,
                                                                weight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              for (int i = 0;
                                                                  i < _paymentFieldCount;
                                                                  i++)
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          6),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: DropdownButtonFormField<
                                                                            String>(
                                                                          value:
                                                                              selectedPaymentMethods[i],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            labelText:
                                                                                "Select",
                                                                            labelStyle:
                                                                                MyTextStyle.f14(greyColor),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                whiteColor,
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              borderSide: BorderSide(color: appPrimaryColor, width: 1.5),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              borderSide: BorderSide(color: appPrimaryColor, width: 2),
                                                                            ),
                                                                          ),
                                                                          dropdownColor:
                                                                              whiteColor,
                                                                          icon: Icon(
                                                                              Icons.keyboard_arrow_down_rounded,
                                                                              color: appPrimaryColor),
                                                                          style: MyTextStyle.f14(
                                                                              blackColor,
                                                                              weight: FontWeight.w500),
                                                                          items: const [
                                                                            DropdownMenuItem(
                                                                                value: "Cash",
                                                                                child: Text("Cash")),
                                                                            DropdownMenuItem(
                                                                                value: "Card",
                                                                                child: Text("Card")),
                                                                            DropdownMenuItem(
                                                                                value: "UPI",
                                                                                child: Text("UPI")),
                                                                          ],
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              selectedPaymentMethods[i] = value ?? "";
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      Expanded(
                                                                        child:
                                                                            TextField(
                                                                          controller:
                                                                              splitAmountControllers[i],
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                          ],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            hintText:
                                                                                "₹ Amount",
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                whiteColor,
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              borderSide: BorderSide(color: appPrimaryColor, width: 1.5),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              borderSide: BorderSide(color: appPrimaryColor, width: 2),
                                                                            ),
                                                                          ),
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              splitChange = true;
                                                                              double total = 0.0;
                                                                              for (var controller in splitAmountControllers) {
                                                                                total += double.tryParse(controller.text) ?? 0.0;
                                                                              }
                                                                              totalSplit = total;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                              // "Add Another" link
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: _paymentFieldCount <
                                                                          3
                                                                      ? addPaymentField
                                                                      : null,
                                                                  child: Text(
                                                                    _paymentFieldCount <
                                                                            3
                                                                        ? "+ Add Another Payment"
                                                                        : "",
                                                                    style:
                                                                        TextStyle(
                                                                      decoration: _paymentFieldCount <
                                                                              3
                                                                          ? TextDecoration
                                                                              .underline
                                                                          : null,
                                                                      color: _paymentFieldCount <
                                                                              3
                                                                          ? appPrimaryColor
                                                                          : greyColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 12),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                "Total Split",
                                                                style: MyTextStyle.f14(
                                                                    blackColor,
                                                                    weight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                "₹ ${totalSplit.toStringAsFixed(2)}",
                                                                style: MyTextStyle.f14(
                                                                    blackColor,
                                                                    weight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          if (splitChange ==
                                                                  true &&
                                                              totalSplit !=
                                                                  postAddToBillingModel
                                                                      .total)
                                                            Text(
                                                              "Split payments must sum to ₹ ${postAddToBillingModel.total!.toStringAsFixed(2)}",
                                                              style: MyTextStyle.f12(
                                                                  redColor,
                                                                  weight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                        ],
                                                      )
                                                    : Container(),
                                              SizedBox(height: 12),
                                              !isSplitPayment
                                                  ? Row(
                                                      children: [
                                                        Expanded(
                                                          child: orderLoad
                                                              ? SpinKitCircle(
                                                                  color:
                                                                      appPrimaryColor,
                                                                  size: 30)
                                                              : ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (selectedValue ==
                                                                            null &&
                                                                        selectDineIn ==
                                                                            true) {
                                                                      setState(
                                                                          () {
                                                                        isCompleteOrder =
                                                                            false;
                                                                      });
                                                                      showToast(
                                                                          "Table number is required for DINE-IN orders",
                                                                          context,
                                                                          color:
                                                                              false);
                                                                    } else if ((widget.isEditingOrder ==
                                                                                null ||
                                                                            widget.isEditingOrder ==
                                                                                false) ||
                                                                        (widget.isEditingOrder ==
                                                                                true &&
                                                                            (postAddToBillingModel.total != widget.existingOrder?.data!.total &&
                                                                                widget.existingOrder?.data!.orderStatus == "WAITLIST"))) {
                                                                      setState(
                                                                          () {
                                                                        isCompleteOrder =
                                                                            false;
                                                                      });
                                                                      debugPrint(
                                                                          "isEditinSavenormal:${widget.isEditingOrder}");
                                                                      debugPrint(
                                                                          "isEditinSavenormalIsCompletedOrder:$isCompleteOrder");
                                                                      List<Map<String, dynamic>>
                                                                          payments =
                                                                          [
                                                                        {
                                                                          "amount":
                                                                              (postAddToBillingModel.total ?? 0).toDouble(),
                                                                          "balanceAmount":
                                                                              0,
                                                                          "method":
                                                                              selectedFullPaymentMethod.toUpperCase(),
                                                                        },
                                                                      ];
                                                                      final orderPayload =
                                                                          buildOrderPayload(
                                                                        postAddToBillingModel:
                                                                            postAddToBillingModel,
                                                                        tableId: selectDineIn ==
                                                                                true
                                                                            ? tableId
                                                                            : null,
                                                                        orderStatus:
                                                                            'WAITLIST',
                                                                        orderType: selectDineIn ==
                                                                                true
                                                                            ? 'DINE-IN'
                                                                            : 'TAKE-AWAY',
                                                                        payments: widget.isEditingOrder ==
                                                                                true
                                                                            ? []
                                                                            : payments,
                                                                      );
                                                                      debugPrint(
                                                                          'Sending order: ${jsonEncode(orderPayload)}');
                                                                      debugPrint(
                                                                          'paymentinupdate: $payments');
                                                                      setState(
                                                                          () {
                                                                        orderLoad =
                                                                            true;
                                                                      });
                                                                      if (widget.isEditingOrder ==
                                                                              true &&
                                                                          (postAddToBillingModel.total != widget.existingOrder?.data!.total &&
                                                                              widget.existingOrder?.data!.orderStatus == "WAITLIST")) {
                                                                        if ((selectedValue == null || selectedValue == 'N/A') &&
                                                                            selectDineIn ==
                                                                                true) {
                                                                          showToast(
                                                                              "Table number is required for DINE-IN orders",
                                                                              context,
                                                                              color: false);
                                                                          setState(
                                                                              () {
                                                                            orderLoad =
                                                                                false;
                                                                          });
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            isCompleteOrder =
                                                                                false;
                                                                          });
                                                                          context.read<FoodCategoryBloc>().add(UpdateOrder(
                                                                              jsonEncode(orderPayload),
                                                                              widget.existingOrder?.data!.id));
                                                                        }
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          isCompleteOrder =
                                                                              false;
                                                                        });
                                                                        context
                                                                            .read<FoodCategoryBloc>()
                                                                            .add(GenerateOrder(jsonEncode(orderPayload)));
                                                                      }
                                                                    }
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor: (widget.isEditingOrder == null || widget.isEditingOrder == false) ||
                                                                            (widget.isEditingOrder == true &&
                                                                                (postAddToBillingModel.total != widget.existingOrder?.data!.total && widget.existingOrder?.data!.orderStatus == "WAITLIST"))
                                                                        ? appPrimaryColor
                                                                        : greyColor,
                                                                    minimumSize:
                                                                        const Size(
                                                                            0,
                                                                            50), // Height only
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    "Save Order",
                                                                    style: TextStyle(
                                                                        color: (widget.isEditingOrder == null || widget.isEditingOrder == false) ||
                                                                                (widget.isEditingOrder == true && (postAddToBillingModel.total != widget.existingOrder?.data!.total && widget.existingOrder?.data!.orderStatus == "WAITLIST"))
                                                                            ? whiteColor
                                                                            : blackColor),
                                                                  ),
                                                                ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: completeLoad
                                                              ? SpinKitCircle(
                                                                  color:
                                                                      appPrimaryColor,
                                                                  size: 30)
                                                              : ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    /* Full payment */
                                                                    if (selectedValue ==
                                                                            null &&
                                                                        selectDineIn ==
                                                                            true) {
                                                                      showToast(
                                                                          "Table number is required for DINE-IN orders",
                                                                          context,
                                                                          color:
                                                                              false);
                                                                    } else {
                                                                      if (widget.isEditingOrder ==
                                                                              false ||
                                                                          widget.isEditingOrder ==
                                                                              null) {
                                                                        setState(
                                                                            () {
                                                                          isCompleteOrder =
                                                                              true;
                                                                        });
                                                                        debugPrint(
                                                                            "generateOrderApi");
                                                                        debugPrint(
                                                                            "generateOrderIsComplete:$isCompleteOrder");
                                                                        if ((amountController.text.isNotEmpty && selectedFullPaymentMethod == "Cash") ||
                                                                            selectedFullPaymentMethod ==
                                                                                "Card" ||
                                                                            selectedFullPaymentMethod ==
                                                                                "UPI") {
                                                                          List<Map<String, dynamic>>
                                                                              payments =
                                                                              [];
                                                                          payments =
                                                                              [
                                                                            {
                                                                              "amount": (postAddToBillingModel.total ?? 0).toDouble(),
                                                                              "balanceAmount": 0,
                                                                              "method": selectedFullPaymentMethod.toUpperCase(),
                                                                            }
                                                                          ];

                                                                          final orderPayload =
                                                                              buildOrderPayload(
                                                                            postAddToBillingModel:
                                                                                postAddToBillingModel,
                                                                            tableId: selectDineIn == true
                                                                                ? tableId
                                                                                : null,
                                                                            orderStatus:
                                                                                'COMPLETED',
                                                                            orderType: selectDineIn == true
                                                                                ? 'DINE-IN'
                                                                                : 'TAKE-AWAY',
                                                                            payments:
                                                                                payments,
                                                                          );
                                                                          setState(
                                                                              () {
                                                                            completeLoad =
                                                                                true;
                                                                          });

                                                                          context
                                                                              .read<FoodCategoryBloc>()
                                                                              .add(GenerateOrder(jsonEncode(orderPayload)));
                                                                        }
                                                                      }
                                                                      if ((widget.isEditingOrder == true && (postAddToBillingModel.total != widget.existingOrder?.data!.total && widget.existingOrder?.data!.orderStatus == "COMPLETED")) ||
                                                                          (widget.isEditingOrder == true &&
                                                                              widget.existingOrder?.data!.orderStatus == "WAITLIST")) {
                                                                        setState(
                                                                            () {
                                                                          isCompleteOrder =
                                                                              true;
                                                                        });
                                                                        debugPrint(
                                                                            "updateOrderApi");
                                                                        debugPrint(
                                                                            "updateOrderIsComplete:$isCompleteOrder");
                                                                        debugPrint(
                                                                            "updateOrderexistId:${widget.existingOrder!.data!.id}");
                                                                        if ((amountController.text.isNotEmpty && selectedFullPaymentMethod == "Cash") ||
                                                                            selectedFullPaymentMethod ==
                                                                                "Card" ||
                                                                            selectedFullPaymentMethod ==
                                                                                "UPI") {
                                                                          List<Map<String, dynamic>>
                                                                              payments =
                                                                              [];
                                                                          payments =
                                                                              [
                                                                            {
                                                                              "amount": (postAddToBillingModel.total ?? 0).toDouble(),
                                                                              "balanceAmount": 0,
                                                                              "method": selectedFullPaymentMethod.toUpperCase(),
                                                                            }
                                                                          ];

                                                                          final orderPayload =
                                                                              buildOrderPayload(
                                                                            postAddToBillingModel:
                                                                                postAddToBillingModel,
                                                                            tableId: selectDineIn == true
                                                                                ? tableId
                                                                                : null,
                                                                            orderStatus:
                                                                                'COMPLETED',
                                                                            orderType: selectDineIn == true
                                                                                ? 'DINE-IN'
                                                                                : 'TAKE-AWAY',
                                                                            payments:
                                                                                payments,
                                                                          );

                                                                          debugPrint(
                                                                              'Sending order: ${jsonEncode(orderPayload)}');
                                                                          setState(
                                                                              () {
                                                                            completeLoad =
                                                                                true;
                                                                          });

                                                                          context.read<FoodCategoryBloc>().add(UpdateOrder(
                                                                              jsonEncode(orderPayload),
                                                                              widget.existingOrder!.data!.id));
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        appPrimaryColor,
                                                                    minimumSize:
                                                                        const Size(
                                                                            0,
                                                                            50),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    widget.isEditingOrder ==
                                                                                true &&
                                                                            widget.existingOrder?.data!.orderStatus ==
                                                                                "COMPLETED"
                                                                        ? "Update Order"
                                                                        : "Complete Order",
                                                                    style: TextStyle(
                                                                        color:
                                                                            whiteColor),
                                                                  ),
                                                                ),
                                                        ),
                                                      ],
                                                    )
                                                  : completeLoad
                                                      ? SpinKitCircle(
                                                          color:
                                                              appPrimaryColor,
                                                          size: 30)
                                                      : ElevatedButton(
                                                          onPressed: () {
                                                            if (!allSplitAmountsFilled() ||
                                                                !allPaymentMethodsSelected()) {
                                                              showToast(
                                                                "Please complete payment method and amount fields",
                                                                context,
                                                                color: false,
                                                              );
                                                              return;
                                                            }

                                                            if (totalSplit !=
                                                                postAddToBillingModel
                                                                    .total) {
                                                              showToast(
                                                                "Split payments must sum to ₹ ${postAddToBillingModel.total!.toStringAsFixed(2)}",
                                                                context,
                                                                color: false,
                                                              );
                                                              return;
                                                            }

                                                            if (selectedValue ==
                                                                    null &&
                                                                selectDineIn ==
                                                                    true) {
                                                              showToast(
                                                                "Table number is required for DINE-IN orders",
                                                                context,
                                                                color: false,
                                                              );
                                                              return;
                                                            }

                                                            List<
                                                                    Map<String,
                                                                        dynamic>>
                                                                payments = [];
                                                            if (widget.isEditingOrder ==
                                                                    false ||
                                                                widget.isEditingOrder ==
                                                                    null) {
                                                              if (isSplitPayment) {
                                                                for (int i = 0;
                                                                    i < _paymentFieldCount;
                                                                    i++) {
                                                                  final method =
                                                                      selectedPaymentMethods[
                                                                          i];
                                                                  final amountText =
                                                                      splitAmountControllers[
                                                                              i]
                                                                          .text;
                                                                  final amount =
                                                                      double.tryParse(
                                                                              amountText) ??
                                                                          0;
                                                                  if (method ==
                                                                          null ||
                                                                      method
                                                                          .isEmpty) {
                                                                    showToast(
                                                                        "Please select a payment method for split #${i + 1}",
                                                                        context,
                                                                        color:
                                                                            false);
                                                                    return;
                                                                  }

                                                                  payments.add({
                                                                    "amount":
                                                                        amount,
                                                                    "balanceAmount":
                                                                        0,
                                                                    "method": method
                                                                        .toUpperCase(),
                                                                  });
                                                                }
                                                              } else {
                                                                payments = [
                                                                  {
                                                                    "amount": (postAddToBillingModel.total ??
                                                                            0)
                                                                        .toDouble(),
                                                                    "balanceAmount":
                                                                        0,
                                                                    "method":
                                                                        selectedFullPaymentMethod
                                                                            .toUpperCase(),
                                                                  }
                                                                ];
                                                              }

                                                              final orderPayload =
                                                                  buildOrderPayload(
                                                                postAddToBillingModel:
                                                                    postAddToBillingModel,
                                                                tableId:
                                                                    selectDineIn ==
                                                                            true
                                                                        ? tableId
                                                                        : null,
                                                                orderStatus:
                                                                    'COMPLETED',
                                                                orderType: selectDineIn ==
                                                                        true
                                                                    ? 'DINE-IN'
                                                                    : 'TAKE-AWAY',
                                                                payments:
                                                                    payments,
                                                              );

                                                              debugPrint(
                                                                  'Sending order: ${jsonEncode(orderPayload)}');
                                                              setState(() {
                                                                completeLoad =
                                                                    true;
                                                              });
                                                              context
                                                                  .read<
                                                                      FoodCategoryBloc>()
                                                                  .add(GenerateOrder(
                                                                      jsonEncode(
                                                                          orderPayload)));
                                                            }
                                                            if ((widget.isEditingOrder ==
                                                                        true &&
                                                                    (postAddToBillingModel.total !=
                                                                            widget
                                                                                .existingOrder?.data!.total &&
                                                                        widget.existingOrder?.data!.orderStatus ==
                                                                            "COMPLETED")) ||
                                                                (widget.isEditingOrder ==
                                                                        true &&
                                                                    widget
                                                                            .existingOrder
                                                                            ?.data!
                                                                            .orderStatus ==
                                                                        "WAITLIST")) {
                                                              if (isSplitPayment) {
                                                                for (int i = 0;
                                                                    i < _paymentFieldCount;
                                                                    i++) {
                                                                  final method =
                                                                      selectedPaymentMethods[
                                                                          i];
                                                                  final amountText =
                                                                      splitAmountControllers[
                                                                              i]
                                                                          .text;
                                                                  final amount =
                                                                      double.tryParse(
                                                                              amountText) ??
                                                                          0;
                                                                  if (method ==
                                                                          null ||
                                                                      method
                                                                          .isEmpty) {
                                                                    showToast(
                                                                        "Please select a payment method for split #${i + 1}",
                                                                        context,
                                                                        color:
                                                                            false);
                                                                    return;
                                                                  }

                                                                  payments.add({
                                                                    "amount":
                                                                        amount,
                                                                    "balanceAmount":
                                                                        0,
                                                                    "method": method
                                                                        .toUpperCase(),
                                                                  });
                                                                }
                                                              } else {
                                                                payments = [
                                                                  {
                                                                    "amount": (postAddToBillingModel.total ??
                                                                            0)
                                                                        .toDouble(),
                                                                    "balanceAmount":
                                                                        0,
                                                                    "method":
                                                                        selectedFullPaymentMethod
                                                                            .toUpperCase(),
                                                                  }
                                                                ];
                                                              }

                                                              final orderPayload =
                                                                  buildOrderPayload(
                                                                postAddToBillingModel:
                                                                    postAddToBillingModel,
                                                                tableId:
                                                                    selectDineIn ==
                                                                            true
                                                                        ? tableId
                                                                        : null,
                                                                orderStatus:
                                                                    'COMPLETED',
                                                                orderType: selectDineIn ==
                                                                        true
                                                                    ? 'DINE-IN'
                                                                    : 'TAKE-AWAY',
                                                                payments:
                                                                    payments,
                                                              );

                                                              debugPrint(
                                                                  'Sending order: ${jsonEncode(orderPayload)}');
                                                              setState(() {
                                                                completeLoad =
                                                                    true;
                                                              });
                                                              context
                                                                  .read<
                                                                      FoodCategoryBloc>()
                                                                  .add(UpdateOrder(
                                                                      jsonEncode(
                                                                          orderPayload),
                                                                      widget
                                                                          .existingOrder!
                                                                          .data!
                                                                          .id));
                                                            }
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor: (allSplitAmountsFilled() &&
                                                                    allPaymentMethodsSelected() &&
                                                                    totalSplit ==
                                                                        postAddToBillingModel
                                                                            .total)
                                                                ? appPrimaryColor
                                                                : greyColor,
                                                            minimumSize: Size(
                                                                double.infinity,
                                                                50),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            "Print Bills",
                                                            style: TextStyle(
                                                                color:
                                                                    whiteColor),
                                                          ),
                                                        )
                                            ])))))
              ]));
    }

    return BlocBuilder<FoodCategoryBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetCategoryModel) {
          getCategoryModel = current;
          if (getCategoryModel.success == true) {
            setState(() {
              categoryLoad = false;
            });
          } else {
            setState(() {
              categoryLoad = false;
            });
          }
          return true;
        }
        if (current is GetProductByCatIdModel) {
          getProductByCatIdModel = current;
          if (getProductByCatIdModel.success == true) {
            setState(() {
              categoryLoad = false;
            });
          }
          return true;
        }
        if (current is PostAddToBillingModel) {
          postAddToBillingModel = current;
          return true;
        }
        if (current is PostGenerateOrderModel) {
          postGenerateOrderModel = current;
          showToast("${postGenerateOrderModel.message}", context, color: true);
          bool shouldPrintReceipt = isCompleteOrder;
          setState(() {
            orderLoad = false;
            completeLoad = false;
            billingItems.clear();
            selectedValue = null;
            tableId = null;
            isCompleteOrder = false; // This was setting it to false!
            isSplitPayment = false;
            amountController.clear();
            selectedFullPaymentMethod = "";
            widget.isEditingOrder = false;
          });

          context
              .read<FoodCategoryBloc>()
              .add(AddToBilling(List.from(billingItems)));
          if (shouldPrintReceipt == true) {
            debugPrint("Starting receipt printing...");
            debugPrint(
                "Order Number: ${postGenerateOrderModel.order?.orderNumber}");

            try {
              printerService.init();
              String receipt = formatReceiptForMiniPrinter(
                  postGenerateOrderModel.order, postGenerateOrderModel.invoice);

              debugPrint("Receipt formatted successfully");
              debugPrint("Receipt content: $receipt");
              receipt = receipt.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
              printerService.printText(receipt);
              Future.delayed(Duration(milliseconds: 300));
              printerService.fullCut();

              debugPrint("Receipt sent to printer");
            } catch (e) {
              debugPrint("Error printing receipt: $e");
            }
          } else {
            debugPrint("Receipt not printed - shouldPrintReceipt is false");
          }

          return true;
        }
        if (current is UpdateGenerateOrderModel) {
          updateGenerateOrderModel = current;
          debugPrint("updateOrder:${updateGenerateOrderModel.message}");
          showToast("${updateGenerateOrderModel.message}", context,
              color: true);
          bool shouldPrintReceipt = isCompleteOrder;
          setState(() {
            completeLoad = false;
            billingItems.clear();
            selectedValue = null;
            tableId = null;
            isCompleteOrder = false;
            isSplitPayment = false;
            amountController.clear();
            selectedFullPaymentMethod = "";
            widget.isEditingOrder = false;
          });
          context
              .read<FoodCategoryBloc>()
              .add(AddToBilling(List.from(billingItems)));

          if (shouldPrintReceipt == true) {
            debugPrint("Starting receipt printing...");
            debugPrint(
                "Order Number: ${updateGenerateOrderModel.order?.orderNumber}");

            try {
              printerService.init();
              String receipt = formatReceiptForMiniPrinter(
                  updateGenerateOrderModel.order,
                  updateGenerateOrderModel.invoice);

              debugPrint("Receipt formatted successfully");
              debugPrint("Receipt content: $receipt");
              receipt = receipt.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
              printerService.printText(receipt);
              Future.delayed(Duration(milliseconds: 300));
              printerService.fullCut();

              debugPrint("Receipt sent to printer");
            } catch (e) {
              debugPrint("Error printing receipt: $e");
            }
          } else {
            debugPrint("Receipt not printed - shouldPrintReceipt is false");
          }
          return true;
        }
        if (current is GetTableModel) {
          getTableModel = current;
          if (getTableModel.success == true) {
            setState(() {
              categoryLoad = false;
            });
          } else {
            setState(() {
              categoryLoad = false;
            });
            showToast("No Tables found", context, color: false);
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
