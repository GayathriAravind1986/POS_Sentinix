import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart';
import 'package:simple/ModelClass/payment_split/split.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Cart/Widget/payment_option.dart';
import 'package:simple/UI/Home_screen/Widget/addons_screen_widget.dart';
import 'package:simple/UI/Home_screen/Widget/category_card.dart';
import 'package:simple/services/mock_printer_service.dart';
import 'package:simple/services/printer_service.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCategoryBloc(),
      child: FoodScreenView(),
    );
  }
}

class FoodScreenView extends StatefulWidget {
  const FoodScreenView({
    super.key,
  });

  @override
  FoodScreenViewState createState() => FoodScreenViewState();
}

class FoodScreenViewState extends State<FoodScreenView> {
  TextEditingController searchController = TextEditingController();
  String selectedCategory = "All";
  String? selectedCatId = "";
  GetCategoryModel getCategoryModel = GetCategoryModel();
  GetProductByCatIdModel getProductByCatIdModel = GetProductByCatIdModel();
  PostAddToBillingModel postAddToBillingModel = PostAddToBillingModel();
  late final PrinterService printer;
  bool isSplitPayment = false;
  String? errorMessage;
  bool categoryLoad = false;
  bool cartLoad = false;
  bool isToppingSelected = false;
  bool isDineIn = true;
  String selectedFullPaymentMethod = "Cash";
  List<Map<String, dynamic>> billingItems = [];
  Map<String, int> productCounters = {};
  @override
  void initState() {
    super.initState();
    printer = MockPrinterService();
    context.read<FoodCategoryBloc>().add(FoodCategory());
    context
        .read<FoodCategoryBloc>()
        .add(FoodProductItem(selectedCatId.toString(), searchController.text));
    categoryLoad = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    Widget mainContainer() {
      final sortedCategories = (getCategoryModel.data ?? [])
          .map((data) =>
          Category(
            id: data.id,
            name: data.name,
            image: data.image,
          ))
          .toList()
        ..sort(
                (a, b) =>
                a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));

      final List<Category> displayedCategories = [
        Category(name: 'All', image: 'assets/image/all.png', id: ""),
        ...sortedCategories,
      ];

      final rows = getProductByCatIdModel.rows;
      if (rows == null || rows.isEmpty) {
        return const SizedBox();
      }
      final uniqueProducts = {
        for (var p in rows)
          if (p.id != null) p.id!: p
      }.values.where((p) => (p.counter ?? 0) > 0).toList();

      void updateBillingList(String productId) {
        final count = productCounters[productId] ?? 0;
        final index = billingItems.indexWhere((item) =>
        item['_id'] == productId);

        if (count <= 0) {
          billingItems.removeWhere((item) => item['_id'] == productId);
        } else if (index != -1) {
          billingItems[index]['qty'] = count;
        }

        context.read<FoodCategoryBloc>().add(
            AddToBilling(List.from(billingItems)));
      }
      @override
      Widget priceRowStack(String label, String value, {bool isBold = false}) {
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

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
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
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: size.width * 0.2),
                              SizedBox(
                                width: size.width * 0.25,
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search product',
                                    prefixIcon: Icon(Icons.search),
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(30)),
                                  ),
                                  onChanged: (value) {
                                    context.read<FoodCategoryBloc>().add(
                                      FoodProductItem(
                                          selectedCatId.toString(), value),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        categoryLoad
                            ? Container(
                            padding: EdgeInsets.only(
                                top: MediaQuery
                                    .of(context)
                                    .size
                                    .height *
                                    0.2),
                            alignment: Alignment.center,
                            child: const SpinKitChasingDots(
                                color: appPrimaryColor, size: 30))
                            : displayedCategories.isEmpty
                            ? Center(child: Text("No category found"))
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
                              getProductByCatIdModel.rows!.isEmpty
                              ? const Center(
                              child: Text('No products found'))
                              : GridView.builder(
                            padding: EdgeInsets.all(12),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisExtent: 220,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount:
                            getProductByCatIdModel.rows!.length,
                            itemBuilder: (_, index) {
                              final p =
                              getProductByCatIdModel.rows![index];
                              return Card(
                                color: whiteColor,
                                shadowColor: greyColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: size.height * 0.14,
                                        child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(
                                                15.0),
                                            child: CachedNetworkImage(
                                              imageUrl: p.image!,
                                              width: size.width * 0.2,
                                              height:
                                              size.height * 0.15,
                                              fit: BoxFit.cover,
                                              errorWidget: (context,
                                                  url, error) {
                                                return const Icon(
                                                  Icons.error,
                                                  size: 30,
                                                  color:
                                                  appHomeTextColor,
                                                );
                                              },
                                              progressIndicatorBuilder: (
                                                  context,
                                                  url,
                                                  downloadProgress) =>
                                              const SpinKitCircle(
                                                  color:
                                                  appPrimaryColor,
                                                  size: 30),
                                            )),
                                      ),
                                      verticalSpace(height: 7),
                                      Flexible(
                                        child: Text(
                                          "${p.name}",
                                          textAlign: TextAlign.left,
                                          style: MyTextStyle.f14(
                                              blackColor,
                                              weight:
                                              FontWeight.w500),
                                          maxLines: 2,
                                        ),
                                      ),
                                      verticalSpace(height: 5),
                                      Flexible(
                                        child: Text(
                                          '₹ ${p.basePrice}',
                                          textAlign: TextAlign.left,
                                          style: MyTextStyle.f14(
                                              blackColor,
                                              weight:
                                              FontWeight.bold),
                                          maxLines: 2,
                                        ),
                                      ),
                                      verticalSpace(height: 5),
                                      p.counter == 0
                                          ? ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            p.counter = 1;
                                            debugPrint(
                                                "counter:${p.counter}");
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
                                                      value: BlocProvider.of<
                                                          FoodCategoryBloc>(
                                                          context,
                                                          listen:
                                                          false),
                                                      child: StatefulBuilder(
                                                          builder:
                                                              (context,
                                                              setState) {
                                                            return Dialog(
                                                              insetPadding: EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 40,
                                                                  vertical: 24),
                                                              shape:
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    8),
                                                              ),
                                                              child:
                                                              Container(
                                                                constraints:
                                                                BoxConstraints(
                                                                  maxWidth: size
                                                                      .width *
                                                                      0.4,
                                                                  maxHeight: size
                                                                      .height *
                                                                      0.6,
                                                                ),
                                                                padding:
                                                                EdgeInsets.all(
                                                                    16),
                                                                child:
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                      .start,
                                                                  mainAxisSize: MainAxisSize
                                                                      .min,
                                                                  children: [
                                                                    ClipRRect(
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            15.0),
                                                                        child: CachedNetworkImage(
                                                                          imageUrl: p
                                                                              .image!,
                                                                          width: size
                                                                              .width *
                                                                              0.5,
                                                                          height: size
                                                                              .height *
                                                                              0.2,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          errorWidget: (
                                                                              context,
                                                                              url,
                                                                              error) {
                                                                            return const Icon(
                                                                              Icons
                                                                                  .error,
                                                                              size: 30,
                                                                              color: appHomeTextColor,
                                                                            );
                                                                          },
                                                                          progressIndicatorBuilder: (
                                                                              context,
                                                                              url,
                                                                              downloadProgress) =>
                                                                          const SpinKitCircle(
                                                                              color: appPrimaryColor,
                                                                              size: 30),
                                                                        )),
                                                                    SizedBox(
                                                                        height: 16),
                                                                    Text(
                                                                      'Choose Add‑Ons for ${p
                                                                          .name}',
                                                                      style: MyTextStyle
                                                                          .f16(
                                                                        weight: FontWeight
                                                                            .bold,
                                                                        blackColor,
                                                                      ),
                                                                      textAlign: TextAlign
                                                                          .left,
                                                                    ),
                                                                    SizedBox(
                                                                        height: 12),
                                                                    Column(
                                                                        children: p
                                                                            .addons!
                                                                            .map((
                                                                            e) =>
                                                                            toppingOptionTile(
                                                                              title: e
                                                                                  .name!,
                                                                              subtitle: "e.Free (1 max)",
                                                                              isSelected: e
                                                                                  .isSelected,
                                                                              onChanged: (
                                                                                  value) {
                                                                                setState(() {
                                                                                  e
                                                                                      .isSelected =
                                                                                  value!;
                                                                                });
                                                                              },
                                                                            ))
                                                                            .toList()),
                                                                    SizedBox(
                                                                        height: 20),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment
                                                                          .end,
                                                                      children: [
                                                                        ElevatedButton(
                                                                          onPressed: () {
                                                                            setState(() {
                                                                              debugPrint(
                                                                                  "counterincancelbefore:${p
                                                                                      .counter}");
                                                                              if (p
                                                                                  .counter >
                                                                                  1 ||
                                                                                  p
                                                                                      .counter ==
                                                                                      1) {
                                                                                p
                                                                                    .counter--;
                                                                              }
                                                                              debugPrint(
                                                                                  "counterincancelafter:${p
                                                                                      .counter}");
                                                                            });

                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                          style: ElevatedButton
                                                                              .styleFrom(
                                                                            backgroundColor: greyColor
                                                                                .shade400,
                                                                            minimumSize: Size(
                                                                                80,
                                                                                40),
                                                                            padding: EdgeInsets
                                                                                .all(
                                                                                20),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius
                                                                                    .circular(
                                                                                    10)),
                                                                          ),
                                                                          child: Text(
                                                                              'Cancel',
                                                                              style: MyTextStyle
                                                                                  .f14(
                                                                                  blackColor)),
                                                                        ),
                                                                        SizedBox(
                                                                            width: 8),
                                                                        ElevatedButton(
                                                                          onPressed: () {
                                                                            final existingIndex = billingItems
                                                                                .indexWhere((
                                                                                item) =>
                                                                            item['_id'] ==
                                                                                p
                                                                                    .id);

                                                                            if (existingIndex !=
                                                                                -1) {
                                                                              billingItems[existingIndex]['qty'] =
                                                                                  p
                                                                                      .counter;
                                                                              debugPrint(
                                                                                  "Updated existing item in dialog");
                                                                            } else {
                                                                              billingItems
                                                                                  .add(
                                                                                  {
                                                                                    "_id": p
                                                                                        .id,
                                                                                    "basePrice": p
                                                                                        .basePrice,
                                                                                    "qty": p
                                                                                        .counter,
                                                                                    "name": p
                                                                                        .name,
                                                                                    "selectedAddons": p
                                                                                        .hasAddons ==
                                                                                        true
                                                                                        ? p
                                                                                        .addons!
                                                                                        .where((
                                                                                        addon) =>
                                                                                    addon
                                                                                        .isSelected ==
                                                                                        true)
                                                                                        .map((
                                                                                        addon) =>
                                                                                    {
                                                                                      "_id": addon
                                                                                          .id,
                                                                                      // Use "id" consistently
                                                                                      "price": addon
                                                                                          .price,
                                                                                      "quantity": 1,
                                                                                      "name": addon
                                                                                          .name,
                                                                                      "isAvailable": addon
                                                                                          .isAvailable,
                                                                                      "maxQuantity": addon
                                                                                          .maxQuantity,
                                                                                      "isFree": addon
                                                                                          .isFree
                                                                                    })
                                                                                        .toList()
                                                                                        : [
                                                                                    ]
                                                                                  });
                                                                              debugPrint(
                                                                                  "Added new item with addons");
                                                                            }
                                                                            context
                                                                                .read<
                                                                                FoodCategoryBloc>()
                                                                                .add(
                                                                                AddToBilling(
                                                                                    billingItems));
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                          style: ElevatedButton
                                                                              .styleFrom(
                                                                            backgroundColor: appPrimaryColor,
                                                                            minimumSize: Size(
                                                                                80,
                                                                                40),
                                                                            padding: EdgeInsets
                                                                                .all(
                                                                                20),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius
                                                                                    .circular(
                                                                                    10)),
                                                                          ),
                                                                          child: Text(
                                                                              'Add to Bill',
                                                                              style: MyTextStyle
                                                                                  .f14(
                                                                                  whiteColor)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                                  );
                                                },
                                              );
                                            } else {
                                              debugPrint(
                                                  "no addon");
                                              setState(() {
                                                cartLoad = true;
                                              });
                                              final existingIndex =
                                              billingItems.indexWhere(
                                                      (item) =>
                                                  item[
                                                  '_id'] ==
                                                      p.id);

                                              if (existingIndex !=
                                                  -1) {
                                                billingItems[
                                                existingIndex]
                                                [
                                                'qty'] =
                                                    p.counter;
                                                debugPrint(
                                                    "Updated existing item without addons");
                                              } else {
                                                billingItems
                                                    .add({
                                                  "_id": p.id,
                                                  "basePrice": p
                                                      .basePrice,
                                                  "qty":
                                                  p.counter,
                                                  "name":
                                                  p.name,
                                                  "selectedAddons": p
                                                      .hasAddons ==
                                                      true
                                                      ? p
                                                      .addons!
                                                      .where((addon) =>
                                                  addon.isSelected ==
                                                      true)
                                                      .map((addon) =>
                                                  {
                                                    "_id": addon.id,
                                                    "price": addon.price,
                                                    "quantity": 1,
                                                    "name": addon.name,
                                                    "isAvailable": addon
                                                        .isAvailable,
                                                    "maxQuantity": addon
                                                        .maxQuantity,
                                                    "isFree": addon.isFree
                                                  })
                                                      .toList()
                                                      : []
                                                });
                                                debugPrint(
                                                    "Added new item without addons");
                                              }
                                              context
                                                  .read<
                                                  FoodCategoryBloc>()
                                                  .add(AddToBilling(
                                                  billingItems));
                                            }
                                          });
                                        },
                                        style: ElevatedButton
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
                                              vertical: 8),
                                        ),
                                        child: Text(
                                            "Add to Billing",
                                            style: MyTextStyle.f12(
                                                whiteColor,
                                                weight:
                                                FontWeight
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
                                            child: IconButton(
                                                icon: const Icon(
                                                    Icons
                                                        .remove,
                                                    size: 16,
                                                    color:
                                                    blackColor),
                                                onPressed: () {
                                                  setState(() {
                                                    if (p.counter >
                                                        1) {
                                                      p.counter--;
                                                      debugPrint(
                                                          "counterDecre: ${p
                                                              .counter}");

                                                      final existingIndex = billingItems
                                                          .indexWhere((item) =>
                                                      item[
                                                      '_id'] ==
                                                          p.id);
                                                      if (existingIndex !=
                                                          -1) {
                                                        billingItems[existingIndex]['qty'] =
                                                            p.counter;
                                                      }
                                                    } else {
                                                      p.counter =
                                                      0;
                                                      debugPrint(
                                                          "counterDecrproduct: ${p
                                                              .counter}");

                                                      billingItems.removeWhere((
                                                          item) =>
                                                      item[
                                                      '_id'] ==
                                                          p.id);
                                                    }

                                                    debugPrint(
                                                        "billingItems: $billingItems");
                                                    context
                                                        .read<
                                                        FoodCategoryBloc>()
                                                        .add(AddToBilling(
                                                        List.from(
                                                            billingItems)));
                                                  });
                                                }),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                12),
                                            child: Text(
                                              "${p.counter}",
                                              style: MyTextStyle
                                                  .f16(
                                                  blackColor),
                                            ),
                                          ),
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                            appPrimaryColor,
                                            child: IconButton(icon: const Icon(Icons.add, size: 16, color: whiteColor),
                                                onPressed: () {
                                                  setState(() {p.counter++;
                                                  debugPrint("counterIncre:${p.counter}");
                                                  final existingIndex = billingItems.indexWhere((item) => item['_id'] == p.id);
                                                  if (existingIndex != -1) {billingItems[existingIndex]
                                                  ['qty'] = p.counter;
                                                  } else {
                                                    billingItems
                                                        .add({"_id": p.id,
                                                      "basePrice": p.basePrice,
                                                      "qty": p.counter,
                                                      "name": p.name,
                                                      "selectedAddons": p.hasAddons ==
                                                          true ? p.addons!.where((addon) => addon.isSelected == true)
                                                          .map((addon) =>
                                                      {
                                                        "_id": addon.id,
                                                        "price": addon.price,
                                                        "quantity": 1,
                                                        "name": addon.name,
                                                        "isAvailable": addon
                                                            .isAvailable,
                                                        "maxQuantity": addon
                                                            .maxQuantity,
                                                        "isFree": addon
                                                            .isFree,
                                                      })
                                                          .toList()
                                                          : []
                                                    });
                                                  }
                                                  context
                                                      .read<
                                                      FoodCategoryBloc>()
                                                      .add(AddToBilling(
                                                      List.from(
                                                          billingItems)));
                                                  });
                                                }),
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
            SizedBox(
              width: size.width * 0.32,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: double.infinity,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    // ✅ Dine In / Take Away Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isDineIn = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isDineIn ? appPrimaryColor : greyColor200,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Dine In",
                                  style: MyTextStyle.f12(
                                    isDineIn ? whiteColor : blackColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isDineIn = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isDineIn ? appPrimaryColor : greyColor200,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Take Away",
                                  style: MyTextStyle.f12(
                                    !isDineIn ? whiteColor : blackColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ✅ Title & Refresh
                    Row(
                      children: [
                        Text(
                          "Bills",
                          style: MyTextStyle.f16(
                            blackColor,
                            weight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),

                    const Divider(),

                    // ✅ Items List or Empty Message
                    Expanded(
                      child: postAddToBillingModel.items == null ||
                          postAddToBillingModel.items!.isEmpty
                          ? Center(
                        child: Text(
                          "No items in bill",
                          style: MyTextStyle.f14(greyColor),
                        ),
                      )
                          : SingleChildScrollView(
                        child: Column(
                          children: postAddToBillingModel.items!.map(
                                (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/image/sentinix_logo.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${e.name}",
                                          style: MyTextStyle.f12(
                                            blackColor,
                                            weight: FontWeight.bold,
                                          ).copyWith(height: 0.9),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "x ${productCounters[e.id] ?? e.qty ?? 1}",
                                              style: MyTextStyle.f12(greyColor),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline),
                                              onPressed: () {
                                                setState(() {
                                                  if (e.id != null) {
                                                    final id = e.id!;
                                                    final currentQty =
                                                    ((productCounters[id]) ?? (e.qty ?? 1)).toInt();
                                                    if (currentQty > 1) {
                                                      productCounters[id] = currentQty - 1;
                                                    } else {
                                                      productCounters[id] = 0;
                                                      billingItems.removeWhere((item) => item['_id'] == id);
                                                    }
                                                    updateBillingList(id);
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              '${productCounters[e.id] ?? e.qty ?? 1}',
                                              style: MyTextStyle.f12(blackColor),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline),
                                              onPressed: () {
                                                setState(() {
                                                  if (e.id != null) {
                                                    final id = e.id!;
                                                    final currentQty =
                                                    ((productCounters[id]) ?? (e.qty ?? 1)).toInt();
                                                    productCounters[id] = currentQty + 1;
                                                    updateBillingList(id);
                                                  }
                                                });
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  if (e.id != null) {
                                                    final id = e.id!;
                                                    productCounters[id] = 0;
                                                    billingItems.removeWhere((item) => item['_id'] == id);
                                                    updateBillingList(id);
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        priceRowStack("Base Price:", "₹ ${e.basePrice}"),
                                        priceRowStack(
                                          "CGST (${e.appliedTaxes?.first.percentage ?? 0}%):",
                                          "₹ ${e.appliedTaxes?.first.amount?.toStringAsFixed(2) ?? '0.00'}",
                                        ),
                                        priceRowStack(
                                          "SGST (${e.appliedTaxes?.last.percentage ?? 0}%):",
                                          "₹ ${e.appliedTaxes?.last.amount?.toStringAsFixed(2) ?? '0.00'}",
                                        ),
                                        priceRowStack(
                                          "Item Total:",
                                          "₹ ${e.basePrice}",
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ),

                    // ✅ Summary
                    const Divider(thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subtotal", style: MyTextStyle.f12(greyColor)),
                        Text("₹ ${postAddToBillingModel.subtotal ?? '0.00'}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Tax", style: MyTextStyle.f12(greyColor)),
                        Text("₹ ${postAddToBillingModel.totalTax ?? '0.00'}"),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total", style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),
                        Text("₹ ${postAddToBillingModel.total ?? '0.00'}",
                            style: MyTextStyle.f18(blackColor, weight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ✅ Payment Mode Selection
                  Container(
                    decoration: BoxDecoration(
                      color: greyColor200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isSplitPayment = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                isSplitPayment ? greyColor200 : appPrimaryColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Full Payment",
                                  style: MyTextStyle.f12(
                                    isSplitPayment ? blackColor : whiteColor,
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
                                isSplitPayment = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                isSplitPayment ? appPrimaryColor : greyColor200,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Split Payment",
                                  style: TextStyle(
                                    color: isSplitPayment ? whiteColor : blackColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  !isSplitPayment ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Text("Payment Method", style: MyTextStyle.f14(blackColor, weight: FontWeight.bold)),
                      SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFullPaymentMethod = "Cash";
                                });
                              },
                              child: PaymentOption(
                                icon: Icons.money,
                                label: "Cash",
                                selected: selectedFullPaymentMethod == "Cash",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFullPaymentMethod = "Card";
                                });
                              },
                              child: PaymentOption(
                                icon: Icons.credit_card,
                                label: "Card",
                                selected: selectedFullPaymentMethod == "Card",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFullPaymentMethod = "UPI";
                                });
                              },
                              child: PaymentOption(
                                icon: Icons.qr_code,
                                label: "UPI",
                                selected: selectedFullPaymentMethod == "UPI",
                              ),
                            ),
                          ],
                        ),

                      ),
                    ],
                  ) : Container(),
                  if (!isSplitPayment && selectedFullPaymentMethod == "Cash") ...[
                SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter amount paid (₹)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ], isSplitPayment
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Split Payment",
                  style: MyTextStyle.f20(blackColor,
                      weight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Select",
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF522F1F), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF522F1F), width: 2),
                            ),
                          ),
                          dropdownColor: Colors.white,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF522F1F)),
                          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                          items: const [
                            DropdownMenuItem(value: "Cash", child: Text("Cash")),
                            DropdownMenuItem(value: "Card", child: Text("Card")),
                            DropdownMenuItem(value: "UPI", child: Text("UPI")),
                          ],
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            hintText: "₹ Amount",
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF522F1F), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF522F1F), width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                PaymentFields(),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Split:",
                      style: MyTextStyle.f17(blackColor,
                          weight: FontWeight.bold),
                    ),
                    Text(
                      "₹0.00",
                      style: MyTextStyle.f17(blackColor,
                          weight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            )
                : Container(),
            SizedBox(height: 12),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        debugPrint(' Button tapped');
                        try {
                          await printer.init();
                          await printer
                              .setAlignment("center"); // For mock, just a string
                          await printer.printText("🍽️ Roja Restaurant\n");
                          await printer.setAlignment("left");
                          await printer.printText("Item: Veg Burger x1\n");
                          await printer.printText("Price: ₹59.32\n");
                          await printer.printAndLineFeed();
                          await printer.cut();
                        } catch (e) {
                          debugPrint("[MOCK] Print failed: $e");
                        }},style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                      child: Text(
                        "Print Bills",
                        style: TextStyle(color: whiteColor),),
                    )
                  ]),
              ),
            )],
        ),
      );
    }


    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        body: BlocBuilder<FoodCategoryBloc, dynamic>(
          buildWhen: ((previous, current) {
            if (current is GetCategoryModel) {
              getCategoryModel = current;

              if (getCategoryModel.success == true) {
                debugPrint("category: ${getCategoryModel.data}");
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
                debugPrint("category: ${getProductByCatIdModel.rows}");
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

            if (current is PostAddToBillingModel) {
              postAddToBillingModel = current;
              debugPrint("Billing response: ${postAddToBillingModel.items}");
              setState(() {
                cartLoad = false;
              });

              // ✅ Counter sync goes HERE
              productCounters.clear();
              for (var item in postAddToBillingModel.items ?? []) {
                if (item.id != null) {
                  productCounters[item.id!] = item.qty ?? 1;
                }
              }

              return true;
            }

            return false;
          }),
          builder: (context, dynamic) {
            return mainContainer();
          },
        ),
      ),
    );
  }}
