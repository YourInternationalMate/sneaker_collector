class Sneaker {
  final String brand;
  final String model;
  final String name;
  final String imageUrl;
  final double price;
  final int size;
  final double purchasePrice;
  final bool inCollection;
  final bool inFavorites;

  Sneaker({
    required this.brand,
    required this.model,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.purchasePrice,
    required this.inCollection,
    required this.inFavorites,
  });
}