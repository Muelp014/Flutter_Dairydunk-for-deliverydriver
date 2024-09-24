class Product{

  final String name;
  final String description;
  final double price;
  final String imagepath;
  final ProductCatagory catagory;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imagepath,
    required this.catagory
  });
}

enum ProductCatagory{
    Milk,
    Yogurt,
    B2B,

}
