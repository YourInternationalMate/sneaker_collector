class Sneaker {
  final String brand;
  final String model;
  final String name;
  final String imageUrl;
  final double price;
  int count;
  double size;
  double purchasePrice;
  bool inCollection;
  bool inFavorites;

  Sneaker({
    required this.brand,
    required this.model,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.count,
    required this.size,
    required this.purchasePrice,
    required this.inCollection,
    required this.inFavorites,
  });

  void setInFavorites(bool value) {
    inFavorites = value;
  }

  void setInCollection(bool value) {
    inCollection = value;
  }

  void setSize(double value) {
    size = value;
  }

  void setPurchasePrice(double value) {
    purchasePrice = value;
  }

  void setCount(int value) {
    count = value;
  }
}