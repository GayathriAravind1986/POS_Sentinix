import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/ModelClass/Cart/Post_Add_to_billing_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_category_model.dart';
import 'package:simple/ModelClass/HomeScreen/Category&Product/Get_product_by_catId_model.dart';

import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Home_screen/Widget/addons_screen_widget.dart';
import 'package:simple/UI/Home_screen/Widget/category_card.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodCategoryBloc(),
      child: const CategoryChipsView(),
    );
  }
}

class CategoryChipsView extends StatefulWidget {
  const CategoryChipsView({
    super.key,
  });

  @override
  CategoryChipsViewState createState() => CategoryChipsViewState();
}

class CategoryChipsViewState extends State<CategoryChipsView> {
  TextEditingController searchController = TextEditingController();
  String selectedCategory = "All";
  String? selectedCatId = "";
  GetCategoryModel getCategoryModel = GetCategoryModel();
  GetProductByCatIdModel getProductByCatIdModel = GetProductByCatIdModel();
  PostAddToBillingModel postAddToBillingModel = PostAddToBillingModel();
  String? errorMessage;
  bool categoryLoad = false;
  bool cartLoad = false;
  bool isToppingSelected = false;
  List<Map<String, dynamic>> billingItems = [];
  @override
  void initState() {
    super.initState();
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
      final List<Category> displayedCategories = [
        Category(name: 'All', image: 'assets/image/all.png', id: ""),
        ...(getCategoryModel.data ?? []).map((data) => Category(
              id: data.id,
              name: data.name,
              image: data.image,
            )),
      ];
      return categoryLoad
          ? Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2),
              alignment: Alignment.center,
              child: const SpinKitChasingDots(color: appPrimaryColor, size: 30))
          : displayedCategories.isEmpty
              ? Center(child: Text("No category found"))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Choose Category",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
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
                                    borderRadius: BorderRadius.circular(30)),
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
                    SizedBox(
                      height: size.height * 0.15,
                      width: size.width * 0.6,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayedCategories.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final category = displayedCategories[index];
                          final isSelected = category.name == selectedCategory;
                          return CategoryCard(
                            label: category.name!,
                            imagePath: category.image!,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                selectedCategory = category.name!;
                                selectedCatId = category.id;
                                if (selectedCategory == 'All') {
                                  context.read<FoodCategoryBloc>().add(
                                      FoodProductItem(selectedCatId.toString(),
                                          searchController.text));
                                } else {
                                  context.read<FoodCategoryBloc>().add(
                                        FoodProductItem(
                                            selectedCatId.toString(),
                                            searchController.text),
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
                      child: getProductByCatIdModel.rows == null ||
                              getProductByCatIdModel.rows!.isEmpty
                          ? const Center(child: Text('No products found'))
                          : GridView.builder(
                              padding: EdgeInsets.all(12),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisExtent: 220,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: getProductByCatIdModel.rows!.length,
                              itemBuilder: (_, index) {
                                final p = getProductByCatIdModel.rows![index];
                                return Card(
                                  color: whiteColor,
                                  shadowColor: greyColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: size.height * 0.14,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: CachedNetworkImage(
                                                imageUrl: p.image!,
                                                width: size.width * 0.2,
                                                height: size.height * 0.15,
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) {
                                                  return const Icon(
                                                    Icons.error,
                                                    size: 30,
                                                    color: appHomeTextColor,
                                                  );
                                                },
                                                progressIndicatorBuilder:
                                                    (context, url,
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
                                            style: MyTextStyle.f14(blackColor,
                                                weight: FontWeight.w500),
                                            maxLines: 2,
                                          ),
                                        ),
                                        verticalSpace(height: 5),
                                        Flexible(
                                          child: Text(
                                            '₹ ${p.basePrice}',
                                            textAlign: TextAlign.left,
                                            style: MyTextStyle.f14(blackColor,
                                                weight: FontWeight.bold),
                                            maxLines: 2,
                                          ),
                                        ),
                                        verticalSpace(height: 5),
                                        p.counter == 0
                                            ? cartLoad
                                                ? const SpinKitCircle(
                                                    color: appPrimaryColor,
                                                    size: 30)
                                                : ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        p.counter = 1;
                                                        debugPrint(
                                                            "counter:${p.counter}");
                                                        if (p.hasAddons ==
                                                            true) {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context2) {
                                                              return BlocProvider(
                                                                create:
                                                                    (context) =>
                                                                        DemoBloc(),
                                                                child:
                                                                    BlocProvider
                                                                        .value(
                                                                  value: BlocProvider.of<
                                                                          DemoBloc>(
                                                                      context,
                                                                      listen:
                                                                          false),
                                                                  child: StatefulBuilder(
                                                                      builder:
                                                                          (context,
                                                                              setState) {
                                                                    return Dialog(
                                                                      insetPadding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              40,
                                                                          vertical:
                                                                              24),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        constraints:
                                                                            BoxConstraints(
                                                                          maxWidth:
                                                                              size.width * 0.4,
                                                                          maxHeight:
                                                                              size.height * 0.6,
                                                                        ),
                                                                        padding:
                                                                            EdgeInsets.all(16),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
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
                                                                                          subtitle: "Free (1 max)",
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
                                                          setState(() {
                                                            cartLoad = true;
                                                          });
                                                          billingItems.add({
                                                            "id": p.id,
                                                            "basePrice":
                                                                p.basePrice,
                                                            "qty": p.counter,
                                                            "name": p.name,
                                                            "selectedAddons": p
                                                                        .hasAddons ==
                                                                    true
                                                                ? p.addons!
                                                                    .where((addon) =>
                                                                        addon
                                                                            .isSelected ==
                                                                        true) // Your own flag
                                                                    .map(
                                                                        (addon) =>
                                                                            {
                                                                              "id": addon.id,
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
                                                                .circular(20),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 8),
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
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        greyColor200,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                          Icons.remove,
                                                          size: 16,
                                                          color: blackColor),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (p.counter > 1) {
                                                            p.counter--;
                                                            debugPrint(
                                                                "counteDecre:${p.counter}");
                                                          } else {
                                                            p.counter = 0;
                                                            debugPrint(
                                                                "counteDecre:${p.counter}");
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12),
                                                    child: Text(
                                                      "${p.counter}",
                                                      style: MyTextStyle.f16(
                                                          blackColor),
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        appPrimaryColor, // Customize brown color
                                                    child: IconButton(
                                                      icon: const Icon(
                                                          Icons.add,
                                                          size: 16,
                                                          color: whiteColor),
                                                      onPressed: () {
                                                        setState(() {
                                                          p.counter++;
                                                          debugPrint(
                                                              "counterIncre:${p.counter}");
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
                );
    }

    return BlocBuilder<FoodCategoryBloc, dynamic>(
      buildWhen: ((previous, current) {
        if (current is GetCategoryModel) {
          getCategoryModel = current;

          if (getCategoryModel.success == true) {
            debugPrint("category: ${getCategoryModel.data}");
            setState(() {
              categoryLoad = false;
            });
          } else if (getCategoryModel.success == false) {
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
          } else if (getProductByCatIdModel.success == false) {
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
