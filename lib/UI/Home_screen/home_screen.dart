import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Cart/Widget/payment_option.dart';
import 'package:simple/UI/Home_screen/Widget/addons_screen_widget.dart';
import 'package:simple/UI/Home_screen/Widget/category_card.dart';
import 'package:simple/services/mock_printer_service.dart';
import 'package:simple/services/printer_service.dart';

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
  late final PrinterService printer;
  bool isSplitPayment = false;
  String? errorMessage;
  bool categoryLoad = false;
  bool cartLoad = false;
  bool isToppingSelected = false;
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
                                            child: IconButton(
                                                icon: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color:
                                                    whiteColor),
                                                onPressed: () {
                                                  setState(() {
                                                    p.counter++;
                                                    debugPrint(
                                                        "counterIncre:${p
                                                            .counter}");
                                                    final existingIndex =
                                                    billingItems.indexWhere((
                                                        item) =>
                                                    item['_id'] ==
                                                        p.id);
                                                    if (existingIndex !=
                                                        -1) {
                                                      billingItems[existingIndex]
                                                      [
                                                      'qty'] =
                                                          p.counter;
                                                    } else {
                                                      billingItems
                                                          .add({
                                                        "_id": p
                                                            .id,
                                                        "basePrice":
                                                        p.basePrice,
                                                        "qty": p
                                                            .counter,
                                                        "name":
                                                        p.name,
                                                        "selectedAddons": p
                                                            .hasAddons ==
                                                            true
                                                            ? p.addons!
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                        style:
                                        MyTextStyle.f14(whiteColor),
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
                                        style: MyTextStyle.f14(blackColor,
                                            weight: FontWeight.bold)),
                                  ),
                                ),
                              ),

                              SizedBox(height: 8), // instead of Spacer
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
                                    style: MyTextStyle.f18(blackColor,
                                        weight: FontWeight.w600)),
                              ]),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: greyColor200,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                        color: appPrimaryColor,
                                        borderRadius:
                                        BorderRadius.circular(30)),
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
                                        style: MyTextStyle.f12(whiteColor),
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
                              minimumSize: Size(double.infinity, 50),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding:
                                  EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                      color: appPrimaryColor,
                                      borderRadius:
                                      BorderRadius.circular(30)),
                                  child: Center(
                                    child: Text("Dine In",
                                        style:
                                        MyTextStyle.f12(whiteColor)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                    child: Text("Take Away",
                                        style:
                                        MyTextStyle.f12(blackColor))),
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
                                  (e) =>
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            child: Image.asset(
                                              'assets/image/sentinix_logo.png',
                                              width: 50,
                                              height: 50,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text("${e.name}",
                                                  style: MyTextStyle.f12(
                                                      blackColor,
                                                      weight: FontWeight
                                                          .bold)),
                                              Text("x ${e.qty} "),
                                            ],
                                          ),
                                          Spacer(),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (e.id != null) {
                                                      final id = e.id!;
                                                      final currentQty = (productCounters[id] ??
                                                          e.qty ?? 1).toInt();

                                                      if (currentQty > 1) {
                                                        productCounters[id] =
                                                            currentQty - 1;
                                                      } else {
                                                        productCounters[id] = 0;
                                                        billingItems
                                                            .removeWhere((
                                                            item) =>
                                                        item['_id'] == id);
                                                      }

                                                      updateBillingList(id);
                                                    }
                                                  });
                                                },

                                                icon: Icon(Icons
                                                    .remove_circle_outline),
                                              ),
                                              Text('${productCounters[e.id] ??
                                                  e.qty ?? 1}'),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (e.id != null) {
                                                      final id = e.id!;
                                                      final currentQty = (productCounters[id] ??
                                                          e.qty ?? 1).toInt();
                                                      productCounters[id] =
                                                          currentQty + 1;
                                                      updateBillingList(id);
                                                    }
                                                  });
                                                },

                                                icon: Icon(
                                                    Icons.add_circle_outline),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (e.id != null) {
                                                      final id = e.id!;
                                                      productCounters[id] = 0;
                                                      billingItems.removeWhere((
                                                          item) =>
                                                      item['_id'] == id);
                                                      updateBillingList(id);
                                                    }
                                                  });
                                                },

                                                icon: Icon(Icons.delete,
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text("Base Price",
                                                        style: MyTextStyle
                                                            .f12(
                                                            greyColor)),
                                                    Text(
                                                        "₹ ${e.basePrice}",
                                                        style: MyTextStyle
                                                            .f12(
                                                            blackColor)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                        "SGST (${e.appliedTaxes!
                                                            .last
                                                            .percentage}%)",
                                                        style: MyTextStyle
                                                            .f12(
                                                            greyColor)),
                                                    Text(
                                                        "₹ ${e.appliedTaxes!
                                                            .last.amount}",
                                                        style: MyTextStyle
                                                            .f12(
                                                            blackColor)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                        "CGST (${e.appliedTaxes!
                                                            .first
                                                            .percentage}%)",
                                                        style: MyTextStyle
                                                            .f12(
                                                            greyColor)),
                                                    Text(
                                                        "₹ ${e.appliedTaxes!
                                                            .first.amount}",
                                                        style: MyTextStyle
                                                            .f12(
                                                            blackColor)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text("Item Total",
                                                        style: MyTextStyle.f12(
                                                            blackColor,
                                                            weight:
                                                            FontWeight
                                                                .bold)),
                                                    Text(
                                                        "₹ ${e.basePrice}",
                                                        style: MyTextStyle.f12(
                                                            blackColor,
                                                            weight:
                                                            FontWeight
                                                                .bold)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  ),
                            )
                                .toList(),
                          ),
                          // Column(
                          //   children: postAddToBillingModel.items!
                          //       .map(
                          //         (e) => Column(
                          //           children: [
                          //             Row(
                          //               children: [
                          //                 ClipRRect(
                          //                   borderRadius:
                          //                       BorderRadius.circular(8),
                          //                   child: Image.asset(
                          //                     'assets/image/sentinix_logo.png',
                          //                     width: 50,
                          //                     height: 50,
                          //                   ),
                          //                 ),
                          //                 SizedBox(width: 12),
                          //                 Expanded(
                          //                   child: Column(
                          //                     crossAxisAlignment:
                          //                         CrossAxisAlignment
                          //                             .start,
                          //                     children: [
                          //                       Text("${e.name}",
                          //                           style: MyTextStyle.f12(
                          //                               blackColor,
                          //                               weight: FontWeight
                          //                                   .bold)),
                          //                       Text("x ${e.qty}"),
                          //                     ],
                          //                   ),
                          //                 ),
                          //                 Row(
                          //                   mainAxisSize:
                          //                       MainAxisSize.min,
                          //                   children: [
                          //                     IconButton(
                          //                       onPressed: () {
                          //                         setState(() {
                          //                           var itemId = e.id;
                          //                           if (itemId != null) {
                          //                             final productIndex =
                          //                                 getProductByCatIdModel
                          //                                     .rows!
                          //                                     .indexWhere(
                          //                               (p) =>
                          //                                   p.id ==
                          //                                   itemId,
                          //                             );
                          //                             if (productIndex !=
                          //                                 -1) {
                          //                               final product =
                          //                                   getProductByCatIdModel
                          //                                           .rows![
                          //                                       productIndex];
                          //                               if (product
                          //                                       .counter >
                          //                                   1) {
                          //                                 product
                          //                                     .counter--;
                          //                                 debugPrint(
                          //                                     "counterDecre>1: ${product.counter}");
                          //                                 final existingIndex =
                          //                                     billingItems.indexWhere((item) =>
                          //                                         item[
                          //                                             'id'] ==
                          //                                         product
                          //                                             .id);
                          //                                 if (existingIndex !=
                          //                                     -1) {
                          //                                   billingItems[
                          //                                               existingIndex]
                          //                                           [
                          //                                           'qty'] =
                          //                                       product
                          //                                           .counter;
                          //                                 }
                          //                                 context
                          //                                     .read<
                          //                                         FoodCategoryBloc>()
                          //                                     .add(AddToBilling(
                          //                                         List.from(
                          //                                             billingItems)));
                          //                               } else {
                          //                                 product.counter =
                          //                                     0;
                          //                                 debugPrint(
                          //                                     "counterDecre: ${product.counter}");
                          //                                 billingItems.removeWhere(
                          //                                     (item) =>
                          //                                         item[
                          //                                             'id'] ==
                          //                                         product
                          //                                             .id);
                          //                                 debugPrint(
                          //                                     "billingItemcounterDecre: $billingItems");
                          //                                 context
                          //                                     .read<
                          //                                         FoodCategoryBloc>()
                          //                                     .add(AddToBilling(
                          //                                         List.from(
                          //                                             billingItems)));
                          //                               }
                          //                             }
                          //                           }
                          //                         });
                          //                       },
                          //                       icon: Icon(Icons
                          //                           .remove_circle_outline),
                          //                     ),
                          //                     Text("${e.qty ?? 0}"),
                          //                     IconButton(
                          //                       onPressed: () {
                          //                         setState(() {
                          //                           final itemId = e.id;
                          //
                          //                           if (itemId != null) {
                          //                             final productIndex =
                          //                                 getProductByCatIdModel
                          //                                     .rows!
                          //                                     .indexWhere(
                          //                               (p) =>
                          //                                   p.id ==
                          //                                   itemId,
                          //                             );
                          //
                          //                             if (productIndex !=
                          //                                 -1) {
                          //                               final product =
                          //                                   getProductByCatIdModel
                          //                                           .rows![
                          //                                       productIndex];
                          //                               product.counter++;
                          //                               debugPrint(
                          //                                   "counterIncre: ${product.counter}");
                          //
                          //                               final existingIndex =
                          //                                   billingItems.indexWhere(
                          //                                       (item) =>
                          //                                           item[
                          //                                               'id'] ==
                          //                                           product
                          //                                               .id);
                          //
                          //                               if (existingIndex !=
                          //                                   -1) {
                          //                                 billingItems[
                          //                                             existingIndex]
                          //                                         [
                          //                                         'qty'] =
                          //                                     product
                          //                                         .counter;
                          //                               } else {
                          //                                 billingItems
                          //                                     .add({
                          //                                   "_id": product
                          //                                       .id,
                          //                                   "basePrice":
                          //                                       product
                          //                                           .basePrice,
                          //                                   "qty": product
                          //                                       .counter,
                          //                                   "name":
                          //                                       product
                          //                                           .name,
                          //                                   "selectedAddons": product
                          //                                               .hasAddons ==
                          //                                           true
                          //                                       ? product
                          //                                           .addons!
                          //                                           .where((addon) =>
                          //                                               addon.isSelected ==
                          //                                               true)
                          //                                           .map((addon) =>
                          //                                               {
                          //                                                 "_id": addon.id,
                          //                                                 "price": addon.price,
                          //                                                 "quantity": 1,
                          //                                                 "name": addon.name,
                          //                                                 "isAvailable": addon.isAvailable,
                          //                                                 "maxQuantity": addon.maxQuantity,
                          //                                                 "isFree": addon.isFree
                          //                                               })
                          //                                           .toList()
                          //                                       : []
                          //                                 });
                          //                               }
                          //                               context
                          //                                   .read<
                          //                                       FoodCategoryBloc>()
                          //                                   .add(AddToBilling(
                          //                                       List.from(
                          //                                           billingItems)));
                          //                             }
                          //                           }
                          //                         });
                          //                       },
                          //                       icon: Icon(Icons
                          //                           .add_circle_outline),
                          //                     ),
                          //                     IconButton(
                          //                       onPressed: () {
                          //                         setState(() {
                          //                           final itemId = e.id;
                          //
                          //                           if (itemId != null) {
                          //                             final productIndex =
                          //                                 getProductByCatIdModel
                          //                                     .rows!
                          //                                     .indexWhere(
                          //                               (p) =>
                          //                                   p.id ==
                          //                                   itemId,
                          //                             );
                          //
                          //                             if (productIndex !=
                          //                                 -1) {
                          //                               final product =
                          //                                   getProductByCatIdModel
                          //                                           .rows![
                          //                                       productIndex];
                          //                               product.counter =
                          //                                   0;
                          //                               billingItems.removeWhere(
                          //                                   (item) =>
                          //                                       item[
                          //                                           'id'] ==
                          //                                       product
                          //                                           .id);
                          //                               context
                          //                                   .read<
                          //                                       FoodCategoryBloc>()
                          //                                   .add(AddToBilling(
                          //                                       List.from(
                          //                                           billingItems)));
                          //                             }
                          //                           }
                          //                         });
                          //                       },
                          //                       icon: Icon(Icons.delete,
                          //                           color: Colors.red),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ],
                          //             ),
                          //             SizedBox(height: 8),
                          //             Row(
                          //               mainAxisAlignment:
                          //                   MainAxisAlignment
                          //                       .spaceBetween,
                          //               children: [
                          //                 Expanded(
                          //                   flex: 1,
                          //                   child: Column(
                          //                     crossAxisAlignment:
                          //                         CrossAxisAlignment
                          //                             .start,
                          //                     children: [
                          //                       Row(
                          //                         mainAxisAlignment:
                          //                             MainAxisAlignment
                          //                                 .spaceBetween,
                          //                         children: [
                          //                           Text("Base Price",
                          //                               style: MyTextStyle
                          //                                   .f12(
                          //                                       greyColor)),
                          //                           Text(
                          //                               "₹ ${e.basePrice}",
                          //                               style: MyTextStyle
                          //                                   .f12(
                          //                                       blackColor)),
                          //                         ],
                          //                       ),
                          //                       Row(
                          //                         mainAxisAlignment:
                          //                             MainAxisAlignment
                          //                                 .spaceBetween,
                          //                         children: [
                          //                           Text(
                          //                               "SGST (${e.appliedTaxes!.last.percentage}%)",
                          //                               style: MyTextStyle
                          //                                   .f12(
                          //                                       greyColor)),
                          //                           Text(
                          //                               "₹ ${e.appliedTaxes!.last.amount}",
                          //                               style: MyTextStyle
                          //                                   .f12(
                          //                                       blackColor)),
                          //                         ],
                          //                       ),
                          //                       Row(
                          //                         mainAxisAlignment:
                          //                             MainAxisAlignment
                          //                                 .spaceBetween,
                          //                         children: [
                          //                           Text(
                          //                               "CGST (${e.appliedTaxes!.first.percentage}%)",
                          //                               style: MyTextStyle
                          //                                   .f12(
                          //                                       greyColor)),
                          //                           Text(
                          //                               "₹ ${e.appliedTaxes!.first.amount}",
                          //                               style: MyTextStyle
                          //                                   .f12(
                          //                                       blackColor)),
                          //                         ],
                          //                       ),
                          //                       Row(
                          //                         mainAxisAlignment:
                          //                             MainAxisAlignment
                          //                                 .spaceBetween,
                          //                         children: [
                          //                           Text("Item Total",
                          //                               style: MyTextStyle.f12(
                          //                                   blackColor,
                          //                                   weight:
                          //                                       FontWeight
                          //                                           .bold)),
                          //                           Text(
                          //                               "₹ ${e.basePrice}",
                          //                               style: MyTextStyle.f12(
                          //                                   blackColor,
                          //                                   weight:
                          //                                       FontWeight
                          //                                           .bold)),
                          //                         ],
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //             Divider(),
                          //           ],
                          //         ),
                          //       )
                          //       .toList(),
                          // ),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Subtotal",
                                    style: MyTextStyle.f12(greyColor)),
                                SizedBox(height: 8),
                                Text(
                                    "₹ ${postAddToBillingModel.subtotal}")
                              ]),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Tax",
                                    style: MyTextStyle.f12(greyColor)),
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
                                    style: MyTextStyle.f12(blackColor,
                                        weight: FontWeight.bold)),
                                Text("₹ ${postAddToBillingModel.total}",
                                    style: MyTextStyle.f18(blackColor,
                                        weight: FontWeight.bold)),
                              ]),
                          SizedBox(height: 12),
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
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSplitPayment
                                            ? greyColor200
                                            : appPrimaryColor,
                                        borderRadius:
                                        BorderRadius.circular(30),
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
                                        BorderRadius.circular(30),
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
                          isSplitPayment
                              ? Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                              Row(
                                children: [
                                  SizedBox(width: 12),
                                  Expanded(
                                      child:
                                      DropdownButtonFormField<
                                          String>(
                                        decoration: InputDecoration(
                                          labelText: "Select ",
                                          labelStyle: MyTextStyle.f12(
                                            weight: FontWeight.w500,
                                            greyColor.shade700,
                                          ),
                                          filled: true,
                                          fillColor: whiteColor,
                                          contentPadding:
                                          EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10),
                                          enabledBorder:
                                          OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                12),
                                            borderSide: BorderSide(
                                                color: appPrimaryColor,
                                                width: 1.5),
                                          ),
                                          focusedBorder:
                                          OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                12),
                                            borderSide: BorderSide(
                                                color: appPrimaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        dropdownColor: whiteColor,
                                        icon: Icon(
                                            Icons
                                                .keyboard_arrow_down_rounded,
                                            color: appPrimaryColor),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: blackColor,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                        onChanged: (value) {
                                          // handle change
                                        },
                                      )),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: " ₹ Amount",
                                        filled: true,
                                        fillColor: whiteColor,
                                        enabledBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              8),
                                          borderSide: BorderSide(
                                              color:
                                              appPrimaryColor,
                                              width: 1.5),
                                        ),
                                        focusedBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              8),
                                          borderSide: BorderSide(
                                              color:
                                              appPrimaryColor,
                                              width: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "+ Add Another Payment",
                                  style: MyTextStyle.f14(
                                    textDecoration:
                                    TextDecoration.underline,
                                    decorationColor: blueColor,
                                    blueColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Split:",
                                    style: MyTextStyle.f17(
                                        blackColor,
                                        weight: FontWeight.bold),
                                  ),
                                  Text(
                                    "₹0.00",
                                    style: MyTextStyle.f17(
                                        blackColor,
                                        weight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )
                              : Container(),
                          SizedBox(height: 12),
                          Text("Payment Method",
                              style: MyTextStyle.f14(blackColor,
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
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Enter amount paid (₹)",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              debugPrint(' Button tapped');
                              try {
                                await printer.init();
                                await printer.setAlignment(
                                    "center"); // For mock, just a string
                                await printer
                                    .printText("🍽️ Roja Restaurant\n");
                                await printer.setAlignment("left");
                                await printer
                                    .printText("Item: Veg Burger x1\n");
                                await printer
                                    .printText("Price: ₹59.32\n");
                                await printer.printAndLineFeed();
                                await printer.cut();
                              } catch (e) {
                                debugPrint("[MOCK] Print failed: $e");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appPrimaryColor,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Print Bills",
                              style: TextStyle(color: whiteColor),
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          ],
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
