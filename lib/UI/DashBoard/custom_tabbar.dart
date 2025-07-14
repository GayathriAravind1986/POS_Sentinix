import 'package:flutter/material.dart';
import 'package:simple/UI/CustomAppBar/custom_appbar.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/UI/Order/order_tab_page.dart';

class DashBoardScreen extends StatefulWidget {
  final int? selectTab;
  const DashBoardScreen({super.key, this.selectTab});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    debugPrint("selectTab:${widget.selectTab}");
    if (widget.selectTab != null) {
      selectedIndex = widget.selectTab!;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Add your logout logic here
          },
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: const [FoodOrderingScreen(), OrdersTabbedScreen()],
        ),
      ),
    );
  }
}
