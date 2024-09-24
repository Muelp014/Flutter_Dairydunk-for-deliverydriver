import 'package:flutter/material.dart';
import 'package:DairyDunk/components/components.dart';
import 'package:DairyDunk/model/List.dart';
import 'package:DairyDunk/model/cartitem.dart';
import 'package:provider/provider.dart';

import '../model/Product.dart';

class Foodpages extends StatefulWidget {
  final Product product;
  const Foodpages({super.key, required this.product});

  @override
  State<Foodpages> createState() => _ProductpageState();
}

class _ProductpageState extends State<Foodpages> {

  void AddToCart(Product product,){
    Navigator.pop(context);
    context.read<Resturant>().addToCart(product);
  }


  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
      body: SingleChildScrollView(
      child:Column(
      children: [
        Image.asset(widget.product.imagepath),

        Text(widget.product.name, 
        style: TextStyle(
          fontWeight: FontWeight.bold , 
          fontSize: 25),),

        Text(widget.product.description,
        style: TextStyle(
          fontWeight: FontWeight.bold ,
          color: Theme.of(context).colorScheme.primary, 
          fontSize: 18),
        ),
        
        SizedBox( height: 40,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            MyButton(onTap: ()=> AddToCart(widget.product) ,text: ('add to cart'),),
          ],
        )
      ],
      
    ),
    ),
    ),

    SafeArea(
      child: Opacity(opacity: 0.1, 
      child:Container(
        margin: const EdgeInsets.only(left: 25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle
          ),
          child: IconButton(icon: Icon(Icons.arrow_back_ios_rounded,color: Theme.of(context).colorScheme.inverseSurface),
          onPressed: () => Navigator.pop(context),
          ),
      ),
      )
    )


    ],);
  }
}
