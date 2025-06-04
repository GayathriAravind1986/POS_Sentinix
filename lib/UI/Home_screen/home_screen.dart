import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/ModelClass/product_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/responsive.dart';
import 'package:simple/UI/Payment/Razorpay_QR_Scanner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: const HomeScreenView(),
    );
  }
}

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({
    super.key,
  });

  @override
  HomeScreenViewState createState() => HomeScreenViewState();
}

class HomeScreenViewState extends State<HomeScreenView> {
  // PostLoginModel postLoginModel = PostLoginModel();
  TextEditingController searchController = TextEditingController();
  String? errorMessage;
  bool homeLoad = false;
  String selectedCategory = 'All Items';
  String searchQuery = '';
  List<String> categories = [
    'All Items',
    'Chocolates',
    'Spices',
    'Oils',
  ];

  List<Product> products = [
    Product(
        name: 'Dark Chocolate',
        price: 120,
        category: 'Chocolates',
        image: 'assets/image/rice.png'),
    Product(
        name: 'Black Pepper',
        price: 180,
        category: 'Spices',
        image: 'assets/image/almond.jpg'),
    Product(
        name: 'Olive Oil',
        price: 250,
        category: 'Oils',
        image: 'assets/image/rice.png'),
    Product(
        name: 'Milk Chocolate',
        price: 100,
        category: 'Chocolates',
        image: 'assets/image/almond.jpg'),
  ];

  List<Product> get filteredProducts {
    List<Product> filteredByCategory = selectedCategory == 'All Items'
        ? products
        : products.where((p) => p.category == selectedCategory).toList();

    if (searchQuery.isEmpty) return filteredByCategory;

    return filteredByCategory
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  double get totalPrice {
    return products.fold(0, (sum, p) => sum + (p.quantity * p.price));
  }

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
    // Widget _cartItem(String name, double price, int qty,
    //     {double discount = 0}) {
    //   final total = price * qty * (1 - discount);
    //   return Padding(
    //     padding: const EdgeInsets.symmetric(vertical: 8),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Expanded(child: Text("$name x$qty")),
    //         Text("₹${total.toStringAsFixed(2)}"),
    //       ],
    //     ),
    //   );
    // }

    Widget paymentButton(String label, Color color) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
                softWrap: false,
              ),
            ),
          ),
        ),
      );
    }

    Widget mainContainer() {
      return ResponsiveBuilder(desktopBuilder: (context, constraints) {
        debugPrint("welcome desktop view");
        return Row(
          children: [
            // Sidebar (Categories)
            Container(
              width: size.width * 0.18,
              color: greyColor200,
              child: ListView(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ListTile(
                    title: Container(
                      padding: const EdgeInsets.all(10),
                      width: size.width * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? appPrimaryColor : whiteColor,
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? whiteColor : blackColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor:
                        whiteColor, // Optional background highlight
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // search bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      cursorColor: appPrimaryColor,
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for items...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),

                  // Product Grid
                  Expanded(
                    flex: 2,
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              'No item found',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: appPrimaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: Image.asset(
                                            product.image,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(product.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        "₹${product.price.toStringAsFixed(2)}"),
                                    SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 10.0),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: greyColor),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              iconSize: 18,
                                              icon: Icon(Icons.remove),
                                              onPressed: product.quantity > 0
                                                  ? () {
                                                      setState(() {
                                                        product.quantity--;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(product.quantity.toString()),
                                            IconButton(
                                              iconSize: 18,
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  product.quantity++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Cart Panel
            Container(
              width: size.width * 0.3,
              color: whiteColor,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🛒 Cart",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  ...products.where((p) => p.quantity > 0).map((p) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("₹${p.price.toStringAsFixed(2)} each"),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            child: Container(
                              height: 32,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: greyColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Prevents Row from expanding full width
                                children: [
                                  IconButton(
                                    iconSize: 16,
                                    padding: EdgeInsets
                                        .zero, // Removes default padding around icon
                                    constraints:
                                        BoxConstraints(), // Shrinks button hitbox
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (p.quantity > 0) p.quantity--;
                                      });
                                    },
                                  ),
                                  Text(
                                    p.quantity.toString(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  IconButton(
                                    iconSize: 16,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        p.quantity++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing:
                          Text("₹${(p.price * p.quantity).toStringAsFixed(2)}"),
                    );
                  }),
                  Spacer(),
                  Divider(),
                  Text("Total: ₹${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: totalPrice > 0 ? () {} : null,
                    child: Text("Checkout"),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      paymentButton("Cash", blueColor),
                      paymentButton("Card", greenColor),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const RazorpayQRScreen(
                                    paymentUrl: "paymentUrl")));
                          },
                          child: paymentButton("UPI", orangeColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }, tabletBuilder: (context, constraints) {
        debugPrint("welcome tablet view");
        return Row(
          children: [
            // Sidebar (Categories)
            Container(
              width: size.width * 0.18,
              color: greyColor200,
              child: ListView(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ListTile(
                    title: Container(
                      padding: const EdgeInsets.all(10),
                      width: size.width * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? appPrimaryColor : whiteColor,
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? whiteColor : blackColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor:
                        whiteColor, // Optional background highlight
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // search bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      cursorColor: appPrimaryColor,
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for items...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),

                  // Product Grid
                  Expanded(
                    flex: 2,
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              'No item found',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: appPrimaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: Image.asset(
                                            product.image,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(product.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        "₹${product.price.toStringAsFixed(2)}"),
                                    SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 10.0),
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: greyColor),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              iconSize: 18,
                                              icon: Icon(Icons.remove),
                                              onPressed: product.quantity > 0
                                                  ? () {
                                                      setState(() {
                                                        product.quantity--;
                                                      });
                                                    }
                                                  : null,
                                            ),
                                            Text(product.quantity.toString()),
                                            IconButton(
                                              iconSize: 18,
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  product.quantity++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Cart Panel
            Container(
              width: size.width * 0.3,
              color: whiteColor,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🛒 Cart",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  ...products.where((p) => p.quantity > 0).map((p) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("₹${p.price.toStringAsFixed(2)} each"),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            child: Container(
                              height: 32,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: greyColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Prevents Row from expanding full width
                                children: [
                                  IconButton(
                                    iconSize: 16,
                                    padding: EdgeInsets
                                        .zero, // Removes default padding around icon
                                    constraints:
                                        BoxConstraints(), // Shrinks button hitbox
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (p.quantity > 0) p.quantity--;
                                      });
                                    },
                                  ),
                                  Text(
                                    p.quantity.toString(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  IconButton(
                                    iconSize: 16,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        p.quantity++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing:
                          Text("₹${(p.price * p.quantity).toStringAsFixed(2)}"),
                    );
                  }),
                  Spacer(),
                  Divider(),
                  Text("Total: ₹${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: totalPrice > 0 ? () {} : null,
                    child: Text("Checkout"),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      paymentButton("Cash", blueColor),
                      paymentButton("Card", greenColor),
                      InkWell(
                          onTap: () {
                            debugPrint("UPI Razorpay");
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => const RazorpayQRScreen(
                            //         paymentUrl:
                            //             " https://api.razorpay.com/v1/payment_links/21")));
                            debugPrint("Navigating to Razorpay QR screen");
                          },
                          child: paymentButton("UPI", orangeColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      });
    }

    return Scaffold(
        backgroundColor: whiteColor,
        body: BlocBuilder<DemoBloc, dynamic>(
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
        ));
  }
}
