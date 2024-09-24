import "package:flutter/material.dart";
import "package:DairyDunk/model/Product.dart";

class MytabBar extends StatelessWidget {
  final TabController tabController;


  const MytabBar({
    super.key,
    required this.tabController,
    });

  List<Tab> _buidCatagoryTabs(){
    return ProductCatagory.values.map((catagory) {
      return Tab(
        text: catagory.toString().split('.').last,
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: TabBar(
      controller: tabController,
      tabs: _buidCatagoryTabs(),
      ),

    );
  }
}