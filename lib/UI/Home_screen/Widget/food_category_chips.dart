import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/Cart/category_card.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
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
  String selectedCategory = "All";

  // PostLoginModel postLoginModel = PostLoginModel();
  final categories = [
    {'label': 'All', 'image': 'assets/icons/all.png'},
    {'label': 'Fast Food', 'image': 'assets/icons/fast_food.png'},
    {'label': 'Chinese', 'image': 'assets/icons/chinese.png'},
    {'label': 'Salads', 'image': 'assets/icons/salads.png'},
    {'label': 'Desserts', 'image': 'assets/icons/desserts.png'},
  ];

  final allProducts = [
    {'title': 'Veg Burger', 'price': 70, 'category': 'Fast Food'},
    {'title': 'Hot Dogs', 'price': 110, 'category': 'Fast Food'},
    {'title': 'Fried Rice', 'price': 125, 'category': 'Chinese'},
    {'title': 'Salad Bowl', 'price': 90, 'category': 'Salads'},
    {'title': 'Gulab Jamun', 'price': 50, 'category': 'Desserts'},
  ];
  Map<String, int> cart = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    List<Map<String, dynamic>> filteredProducts = selectedCategory == 'All'
        ? allProducts
        : allProducts
            .where((item) => item['category'] == selectedCategory)
            .toList();
    Widget mainContainer() {
      return Column(
        children: [
          SizedBox(
            height: size.height * 0.15,
            width: size.width * 0.6,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category['label'] == selectedCategory;
                debugPrint("isSeleted:$isSelected");
                return CategoryCard(
                  label: category['label']!,
                  imagePath: category['image']!,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedCategory = category['label']!;
                      debugPrint("onClick");
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: size.height * 0.5,
            width: size.width * 0.6,
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 180,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (_, index) {
                final p = filteredProducts[index];
                final title = p['title'];
                final price = p['price'];
                final quantity = cart[title] ?? 0;
                return Card(
                  color: whiteColor,
                  shadowColor: greyColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Expanded(child: Placeholder()), // Replace with image
                        Text("${p['title']}"),
                        Text('₹ ${p['price']}'),
                        quantity == 0
                            ? ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    cart[title] = 1;
                                  });
                                },
                                child: const Text('Add to Cart'),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (cart[title]! > 1) {
                                          cart[title] = cart[title]! - 1;
                                        } else {
                                          cart.remove(title);
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text('${cart[title]}'),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        cart[title] = cart[title]! + 1;
                                      });
                                    },
                                    icon: const Icon(Icons.add),
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

    return BlocBuilder<DemoBloc, dynamic>(
      buildWhen: ((previous, current) {
        // if (current is PostLoginModel) {
        //   postLoginModel = current;
        //
        //   if (postLoginModel.success == true) {
        //     debugPrint("LoginIn success: ${postLoginModel.data?.errorMsg}");
        //     if (postLoginModel.data?.status == true) {
        //       debugPrint("Login: ${postLoginModel.success}");
        //
        //       setState(() {
        //         loginLoad = false;
        //       });
        //       Navigator.of(context).pushAndRemoveUntil(
        //         MaterialPageRoute(
        //             builder: (context) => const DashboardScreen()),
        //             (Route<dynamic> route) => false,
        //       );
        //     } else if (postLoginModel.data?.status == false) {
        //       debugPrint("LoginError: ${postLoginModel.data?.errorMsg}");
        //       setState(() {
        //         loginLoad = false;
        //         showToast('${postLoginModel.data?.errorMsg}', context,
        //             color: false);
        //       });
        //     }
        //   }
        //   return true;
        // }
        return false;
      }),
      builder: (context, dynamic) {
        return mainContainer();
      },
    );
  }
}
