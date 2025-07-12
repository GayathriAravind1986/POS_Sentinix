import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
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
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/imin_abstract.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/mock_imin_printer_chrome.dart';
import 'package:simple/UI/Home_screen/Widget/another_imin_printer/real_device_printer.dart';
import 'package:simple/UI/Home_screen/Widget/category_card.dart';

class FoodOrderingScreen extends StatelessWidget {
  const FoodOrderingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCategoryBloc(),
      child: FoodOrderingScreenView(),
    );
  }
}

class FoodOrderingScreenView extends StatefulWidget {
  const FoodOrderingScreenView({
    super.key,
  });

  @override
  FoodOrderingScreenViewState createState() => FoodOrderingScreenViewState();
}

class FoodOrderingScreenViewState extends State<FoodOrderingScreenView> {
  TextEditingController searchController = TextEditingController();
  String selectedCategory = "All";
  String? selectedCatId = "";
  GetCategoryModel getCategoryModel = GetCategoryModel();
  GetProductByCatIdModel getProductByCatIdModel = GetProductByCatIdModel();
  PostAddToBillingModel postAddToBillingModel = PostAddToBillingModel();
  bool isSplitPayment = false;
  String? errorMessage;
  bool categoryLoad = false;
  bool cartLoad = false;
  bool isToppingSelected = false;
  bool isDineIn = true;
  String selectedFullPaymentMethod = "Cash";
  List<Map<String, dynamic>> billingItems = [];
  // Map<String, int> productCounters = {};
  late IPrinterService printerService;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      printerService = MockPrinterService();
    } else {
      try {
        if (Platform.isAndroid) {
          printerService = RealPrinterService();
        } else {
          printerService = MockPrinterService();
        }
      } catch (e) {
        printerService = MockPrinterService();
      }
    }
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
        Category(name: 'All', image: 'assets/image/all.png', id: ""),
        ...sortedCategories,
      ];

      void updateBilling() {
        final updatedItems = <Map<String, dynamic>>[];

        final seenIds = <String>{};

        for (var item in (getProductByCatIdModel.rows ?? [])) {
          if (item.id != null &&
              item.counter > 0 &&
              !seenIds.contains(item.id)) {
            seenIds.add(item.id!);
            updatedItems.add({
              "_id": item.id,
              "qty": item.counter,
              "basePrice": item.basePrice,
              "name": item.name,
              "image": item.image,
              "selectedAddons": item.hasAddons == true
                  ? item.addons!
                  .where((a) => a.isSelected == true)
                  .map((a) => {
                "_id": a.id,
                "name": a.name,
                "price": a.price,
              })
                  .toList()
                  : []
            });
          }
        }

        context.read<FoodCategoryBloc>().add(AddToBilling(updatedItems));
      }
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
                                      ..selection =
                                      TextSelection.collapsed(
                                          offset: searchController
                                              .text.length);
                                    setState(() {
                                      debugPrint(
                                          "serachKey:${searchController.text}");
                                      context
                                          .read<FoodCategoryBloc>()
                                          .add(
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
                                    selectedCategory =
                                    category.name!;
                                    selectedCatId = category.id;
                                    debugPrint(
                                        "searchInCat:${searchController.text}");
                                    if (selectedCategory == 'All') {
                                      context
                                          .read<FoodCategoryBloc>()
                                          .add(FoodProductItem(
                                          selectedCatId
                                              .toString(),
                                          searchController
                                              .text));
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
                                  style: MyTextStyle.f18(
                                      blackColor,
                                      weight: FontWeight.bold)))
                              : GridView.builder(
                            padding: EdgeInsets.all(12),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisExtent: 220,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: getProductByCatIdModel
                                .rows!.length,
                            itemBuilder: (_, index) {
                              final p = getProductByCatIdModel
                                  .rows![index];
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
                                        size.height * 0.14,
                                        child: ClipRRect(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                15.0),
                                            child:
                                            CachedNetworkImage(
                                              imageUrl:
                                              p.image!,
                                              width:
                                              size.width *
                                                  0.2,
                                              height:
                                              size.height *
                                                  0.15,
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
                                      verticalSpace(height: 7),
                                      Flexible(
                                        child: Text(
                                          "${p.name}",
                                          textAlign:
                                          TextAlign.left,
                                          style: MyTextStyle.f14(
                                              blackColor,
                                              weight: FontWeight
                                                  .w500),
                                          maxLines: 2,
                                        ),
                                      ),
                                      verticalSpace(height: 5),
                                      Flexible(
                                        child: Text(
                                          '₹ ${p.basePrice}',
                                          textAlign:
                                          TextAlign.left,
                                          style: MyTextStyle.f14(
                                              blackColor,
                                              weight: FontWeight
                                                  .bold),
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
                                                    child:
                                                    BlocProvider.value(
                                                      value:
                                                      BlocProvider.of<FoodCategoryBloc>(context, listen: false),
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
                                                                    children: p.addons!
                                                                        .map((e) => toppingOptionTile(
                                                                      title: e.name!,
                                                                      subtitle: "e.Free (1 max)",
                                                                      isSelected: e.isSelected,
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          e.isSelected = value!;
                                                                        });
                                                                      },
                                                                    ))
                                                                        .toList()),
                                                                SizedBox(height: 20),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    ElevatedButton(
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          debugPrint("counterincancelbefore:${p.counter}");
                                                                          if (p.counter > 1 || p.counter == 1) {
                                                                            p.counter--;
                                                                          }
                                                                          debugPrint("counterincancelafter:${p.counter}");
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
                                                                        final existingIndex = billingItems.indexWhere((item) => item['_id'] == p.id);

                                                                        if (existingIndex != -1) {
                                                                          billingItems[existingIndex]['qty'] = p.counter;
                                                                          debugPrint("Updated existing item in dialog");
                                                                        } else {
                                                                          billingItems.add({
                                                                            "_id": p.id,
                                                                            "basePrice": p.basePrice,
                                                                            "image": p.image,
                                                                            "qty": p.counter,
                                                                            "name": p.name,
                                                                            "selectedAddons": p.hasAddons == true
                                                                                ? p.addons!
                                                                                .where((addon) => addon.isSelected == true)
                                                                                .map((addon) => {
                                                                              "_id": addon.id,
                                                                              // Use "id" consistently
                                                                              "price": addon.price,
                                                                              "quantity": 1,
                                                                              "name": addon.name,
                                                                              "isAvailable": addon.isAvailable,
                                                                              "maxQuantity": addon.maxQuantity,
                                                                              "isFree": addon.isFree
                                                                            })
                                                                                .toList()
                                                                                : []
                                                                          });
                                                                          debugPrint("Added new item with addons");
                                                                        }
                                                                        context.read<FoodCategoryBloc>().add(AddToBilling(billingItems));
                                                                        Navigator.of(context).pop();
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
                                                        );
                                                      }),
                                                    ),
                                                  );
                                                },
                                              );
                                            } else {
                                              debugPrint(
                                                  "no addon");
                                              setState(
                                                      () {
                                                    cartLoad =
                                                    true;
                                                  });
                                              final existingIndex =
                                              billingItems.indexWhere((item) =>
                                              item['_id'] ==
                                                  p.id);

                                              if (existingIndex !=
                                                  -1) {
                                                billingItems[existingIndex]
                                                [
                                                'qty'] =
                                                    p.counter;
                                                debugPrint(
                                                    "Updated existing item without addons");
                                              } else {
                                                billingItems
                                                    .add({
                                                  "_id": p
                                                      .id,
                                                  "basePrice":
                                                  p.basePrice,
                                                  "image":
                                                  p.image,
                                                  "qty": p
                                                      .counter,
                                                  "name":
                                                  p.name,
                                                  "selectedAddons": p.hasAddons ==
                                                      true
                                                      ? p.addons!
                                                      .where((addon) => addon.isSelected == true)
                                                      .map((addon) => {
                                                    "_id": addon.id,
                                                    "price": addon.price,
                                                    "quantity": 1,
                                                    "name": addon.name,
                                                    "isAvailable": addon.isAvailable,
                                                    "maxQuantity": addon.maxQuantity,
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
                                          padding: const EdgeInsets
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
                                                    Icons.remove,
                                                    size: 16,
                                                    color: blackColor),
                                                onPressed: () {
                                                  setState(() {
                                                    if (p.counter > 1) {
                                                      p.counter--;
                                                      debugPrint("counterDecre: ${p.counter}");

                                                      final existingIndex = billingItems.indexWhere((item) => item['_id'] == p.id);
                                                      if (existingIndex != -1) {
                                                        billingItems[existingIndex]['qty'] = p.counter;
                                                      }
                                                    } else {
                                                      p.counter = 0;
                                                      debugPrint("counterDecrproduct: ${p.counter}");

                                                      billingItems.removeWhere((item) => item['_id'] == p.id);
                                                    }

                                                    debugPrint("billingItems: $billingItems");
                                                    context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));
                                                  });
                                                }),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets
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
                                            child:
                                            IconButton(
                                                icon: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: whiteColor),
                                                onPressed: () {
                                                  setState(() {
                                                    p.counter++;
                                                    debugPrint("counterIncre:${p.counter}");
                                                    final existingIndex = billingItems.indexWhere((item) => item['_id'] == p.id);
                                                    if (existingIndex != -1) {
                                                      billingItems[existingIndex]['qty'] = p.counter;
                                                    } else {
                                                      billingItems.add({
                                                        "_id": p.id,
                                                        "basePrice": p.basePrice,
                                                        "image": p.image,
                                                        "qty": p.counter,
                                                        "name": p.name,
                                                        "selectedAddons": p.hasAddons == true
                                                            ? p.addons!
                                                            .where((addon) => addon.isSelected == true)
                                                            .map((addon) => {
                                                          "_id": addon.id,
                                                          "price": addon.price,
                                                          "quantity": 1,
                                                          "name": addon.name,
                                                          "isAvailable": addon.isAvailable,
                                                          "maxQuantity": addon.maxQuantity,
                                                          "isFree": addon.isFree,
                                                        })
                                                            .toList()
                                                            : []
                                                      });
                                                    }
                                                    context.read<FoodCategoryBloc>().add(AddToBilling(List.from(billingItems)));
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
                  child: postAddToBillingModel.items == null ||
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
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: appPrimaryColor,
                                      borderRadius:
                                      BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Dine In",
                                        style: MyTextStyle.f14(
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
                                        style: MyTextStyle.f14(
                                            blackColor,
                                            weight:
                                            FontWeight.bold)),
                                  ),
                                ),
                              ),

                              SizedBox(
                                  height: 8), // instead of Spacer
                              Text(
                                "Bills",
                                style: MyTextStyle.f16(blackColor,
                                    weight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "No.items in bill",
                                  style: MyTextStyle.f14(greyColor,
                                      weight: FontWeight.w400),
                                ),
                                SizedBox(height: 8),
                                Text("₹ 00.00")
                              ]),
                          Divider(),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal",
                                  style: MyTextStyle.f14(greyColor,
                                      weight: FontWeight.w400),
                                ),
                                SizedBox(height: 8),
                                Text("₹ 00.00")
                              ]),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Tax",
                                  style: MyTextStyle.f14(greyColor,
                                      weight: FontWeight.w400),
                                ),
                                Text("₹ 00.00"),
                              ]),
                          SizedBox(height: 8),
                          Divider(),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: MyTextStyle.f14(blackColor,
                                      weight: FontWeight.w600),
                                ),
                                Text("₹ 00.00",
                                    style: MyTextStyle.f18(
                                        blackColor,
                                        weight: FontWeight.w600)),
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
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8),
                                    decoration: BoxDecoration(
                                        color: appPrimaryColor,
                                        borderRadius:
                                        BorderRadius.circular(
                                            30)),
                                    child: Center(
                                      child: Text("Full Payment",
                                          style: MyTextStyle.f12(
                                              whiteColor)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                      child: Text(
                                        "Split Payment",
                                        style:
                                        MyTextStyle.f12(whiteColor),
                                      )),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text("Payment Method",
                              style: MyTextStyle.f12(blackColor,
                                  weight: FontWeight.bold)),
                          SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                PaymentOption(
                                    icon: Icons.money,
                                    label: "Cash",
                                    selected: true),
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
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appPrimaryColor,
                              minimumSize:
                              Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(30)),
                            ),
                            child: Text(
                              "Print Bills",
                              style: MyTextStyle.f12(whiteColor,
                                  weight: FontWeight.bold),
                            ),
                          ),
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
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8),
                                  decoration: BoxDecoration(
                                      color: appPrimaryColor,
                                      borderRadius:
                                      BorderRadius.circular(
                                          30)),
                                  child: Center(
                                    child: Text("Dine In",
                                        style: MyTextStyle.f12(
                                            whiteColor)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                    child: Text("Take Away",
                                        style: MyTextStyle.f12(
                                            blackColor))),
                              )
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              const Spacer(),
                              Text(
                                "Bills",
                                style: MyTextStyle.f16(blackColor,
                                    weight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                          Divider(),
                Column(
                  children: postAddToBillingModel.items!
                      .map(
                        (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: e.image!,
                              width: size.width * 0.04,
                              height: size.height * 0.05,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  Icons.error,
                                  size: 30,
                                  color: appHomeTextColor,
                                );
                              },
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                              const SpinKitCircle(color: appPrimaryColor, size: 30),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${e.name}", style: MyTextStyle.f12(blackColor, weight: FontWeight.bold)),

                                Builder(
                                  builder: (_) {
                                    final rows = getProductByCatIdModel.rows;

                                    if (rows == null || rows.isEmpty) {
                                      return SizedBox.shrink(); // return empty space if null or empty
                                    }

                                    final match = rows.where((item) => item.id == e.id).toList();

                                    if (match.isEmpty) return SizedBox.shrink(); // no match

                                    final p = match.first;

                                    return Row(
                                      children: [
                                        Text("x ${e.qty} "),
                                        const Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.remove_circle_outline),
                                          onPressed: () {
                                            setState(() {
                                              if (p.counter > 1) {
                                                p.counter--;
                                              } else {
                                                p.counter = 0;
                                              }
                                              updateBilling();
                                            });
                                          },
                                        ),
                                        Text("${p.counter}"),
                                        IconButton(
                                          icon: Icon(Icons.add_circle_outline),
                                          onPressed: () {
                                            setState(() {
                                              p.counter++;
                                              updateBilling();
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              p.counter = 0;
                                              updateBilling();
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                price("Base Price:", "₹ ${e.basePrice}"),
                                price(
                                  "CGST (${e.appliedTaxes?.first.percentage ?? 0}%):",
                                  "₹ ${e.appliedTaxes?.first.amount?.toStringAsFixed(2) ?? '0.00'}",
                                ),
                                price(
                                  "SGST (${e.appliedTaxes?.last.percentage ?? 0}%):",
                                  "₹ ${e.appliedTaxes?.last.amount?.toStringAsFixed(2) ?? '0.00'}",
                                ),
                                price("Item Total:", "₹ ${e.basePrice}", isBold: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(), // ✅ This fixes the error
                ),


                Divider(thickness: 2),
                        Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Subtotal",
                                    style:
                                    MyTextStyle.f12(greyColor)),
                                SizedBox(height: 8),
                                Text(
                                    "₹ ${postAddToBillingModel.subtotal}")
                              ]),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Tax",
                                    style:
                                    MyTextStyle.f12(greyColor)),
                                Text(
                                    "₹ ${postAddToBillingModel.totalTax}"),
                              ]),
                          SizedBox(height: 8),
                          Divider(),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total",
                                    style: MyTextStyle.f12(
                                        blackColor,
                                        weight: FontWeight.bold)),
                                Text(
                                    "₹ ${postAddToBillingModel.total}",
                                    style: MyTextStyle.f18(
                                        blackColor,
                                        weight: FontWeight.bold)),
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
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isSplitPayment = false;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSplitPayment
                                            ? greyColor200
                                            : appPrimaryColor,
                                        borderRadius:
                                        BorderRadius.circular(
                                            30),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Full Payment",
                                          style: MyTextStyle.f12(
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
                                        isSplitPayment = true;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSplitPayment
                                            ? appPrimaryColor
                                            : greyColor200,
                                        borderRadius:
                                        BorderRadius.circular(
                                            30),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Split Payment",
                                          style: MyTextStyle.f12(
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
                ]
                    ) : Container(),
      !isSplitPayment && selectedFullPaymentMethod == "Cash"
      ? Column(
      children: [
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
      ],
      )
          : SizedBox.shrink(),

      isSplitPayment
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
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    "Total Split:",
                                    style: MyTextStyle.f17(
                                        blackColor,
                                        weight:
                                        FontWeight.bold),
                                  ),
                                  Text(
                                    "₹0.00",
                                    style: MyTextStyle.f17(
                                        blackColor,
                                        weight:
                                        FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )
                              : Container(),
                          SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: () async {
                              await printerService.init();
                              await printerService.printText(
                                  "🍽️ Roja Restaurant\n");
                              await printerService.printText(
                                  "Item: Veg Burger x1\nPrice: ₹59.32\n");
                              await printerService.fullCut();
                              //try{
                              //   await iminPrinter.initPrinter(
                              //       printSizeImin: PrintSizeImin.mm58);
                              //
                              //   await iminPrinter.printText(
                              //     "🍽️ Roja Restaurant\n",
                              //     printStyle: const PrintStyle(
                              //         textAlign: PrintStyleAlign.center),
                              //   );
                              //
                              //   await iminPrinter.printText(
                              //     "Item: Veg Burger x1\nPrice: ₹59.32\n\n",
                              //   );
                              //
                              //   await iminPrinter.print2ColumnsText(
                              //       ["Total", "₹59.32"]);
                              //
                              //   // Use the correct cut method—choose one based on your printer model:
                              //   await iminPrinter.fullCut(); // Full cut
                              //   // or
                              //   // await iminPrinter.partialCut(); // If you prefer a partial cut
                              // } catch (e) {
                              //   debugPrint('Printing failed: $e');
                              // }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appPrimaryColor,
                              minimumSize:
                              Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Print Bills",
                              style: TextStyle(color: whiteColor),
                            ),
                          )
      ])
                  )
                )
              )
            )]
            )
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
              }
              return true;
            }

            if (current is PostAddToBillingModel) {
              postAddToBillingModel = current;
              debugPrint("Billing response: ${postAddToBillingModel.items}");
              // productCounters.clear();
              // for (var item in postAddToBillingModel.items ?? []) {
              //   if (item.id != null) {
              //     productCounters[item.id!] = item.qty ?? 1;
              //   }
              //}
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
  }
}
