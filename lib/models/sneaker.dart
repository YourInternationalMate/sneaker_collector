class Sneaker {
  final String name;
  final String imageUrl;
  final double price;
  final int size;
  final double purchasePrice;
  final bool inCollection;
  final bool inFavorites;

  Sneaker({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.purchasePrice,
    required this.inCollection,
    required this.inFavorites,
  });
}