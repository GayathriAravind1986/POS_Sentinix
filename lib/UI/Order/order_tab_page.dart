import 'package:flutter/material.dart';
import 'package:simple/UI/Order/order_list.dart';

class OrdersTabbedScreen extends StatelessWidget {
  const OrdersTabbedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Today's Orders",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF522F1F),
              ),
            ),
          ),

          // Tabs
          const TabBar(
            labelColor: Color(0xFF522F1F),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF522F1F),
            tabs: [
              Tab(text: "All"),
              Tab(text: "Takeaway"),
              Tab(text: "Dine-in"),
            ],
          ),

          // TabBarView with order lists
          const Expanded(
            child: TabBarView(
              children: [
                OrderView(type: 'All'),
                OrderView(type: 'Takeaway'),
                OrderView(type: 'Dine-in'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
