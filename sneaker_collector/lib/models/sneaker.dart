import 'package:flutter/foundation.dart';

@immutable
class Sneaker {
  final int? id;
  final String brand;
  final String model;
  final String name;
  final String imageUrl;
  final double price;
  final String? stockXUrl;
  final String? goatUrl;
  
  int _count;
  double _size;
  double _purchasePrice;
  bool _inCollection;
  bool _inFavorites;

  // Getters für die privaten Felder
  int get count => _count;
  double get size => _size;
  double get purchasePrice => _purchasePrice;
  bool get inCollection => _inCollection;
  bool get inFavorites => _inFavorites;

  Sneaker({
    this.id,
    required this.brand,
    required this.model,
    required this.name,
    required this.imageUrl,
    required this.price,
    required int count,
    required double size,
    required double purchasePrice,
    required bool inCollection,
    required bool inFavorites,
    this.stockXUrl,
    this.goatUrl,
  })  : _count = count,
        _size = size,
        _purchasePrice = purchasePrice,
        _inCollection = inCollection,
        _inFavorites = inFavorites {
    _validateData();
  }

  void _validateData() {
    if (brand.isEmpty) {
      throw ArgumentError('Brand cannot be empty');
    }
    if (model.isEmpty) {
      throw ArgumentError('Model cannot be empty');
    }
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (imageUrl.isEmpty) {
      throw ArgumentError('Image URL cannot be empty');
    }
    if (price < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    if (_count < 0) {
      throw ArgumentError('Count cannot be negative');
    }
    if (_size <= 0) {
      throw ArgumentError('Size must be positive');
    }
    if (_purchasePrice < 0) {
      throw ArgumentError('Purchase price cannot be negative');
    }
  }

  factory Sneaker.fromJson(Map<String, dynamic> json) {
    const defaultSize = 0.1;
    const defaultCount = 1;
    const defaultPurchasePrice = 0.0;
    
    final id = json['product_id'] ?? json['id'];
    
    return Sneaker(
      id: id,
      brand: json['brand'] as String,
      model: json['model'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      count: json['count'] ?? defaultCount,
      size: json['size']?.toDouble() ?? defaultSize,
      purchasePrice: json['purchase_price']?.toDouble() ?? defaultPurchasePrice,
      inCollection: json['in_collection'] ?? false,
      inFavorites: json['in_favorites'] ?? false,
      stockXUrl: json['stock_x_url'] as String?,
      goatUrl: json['goat_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'count': _count,
      'size': _size,
      'purchase_price': _purchasePrice,
      'in_collection': _inCollection,
      'in_favorites': _inFavorites,
      'stock_x_url': stockXUrl,
      'goat_url': goatUrl,
    };
  }

  void setInFavorites(bool value) {
    _inFavorites = value;
  }

  void setInCollection(bool value) {
    _inCollection = value;
  }

  void setSize(double value) {
    if (value <= 0) {
      throw ArgumentError('Size must be positive');
    }
    _size = value;
  }

  void setPurchasePrice(double value) {
    if (value < 0) {
      throw ArgumentError('Purchase price cannot be negative');
    }
    _purchasePrice = value;
  }

  void setCount(int value) {
    if (value < 0) {
      throw ArgumentError('Count cannot be negative');
    }
    _count = value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sneaker &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          brand == other.brand &&
          model == other.model &&
          name == other.name;

  @override
  int get hashCode =>
      id.hashCode ^ brand.hashCode ^ model.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'Sneaker{id: $id, brand: $brand, model: $model, name: $name, '
           'price: $price, count: $_count, size: $_size}';
  }

  Sneaker copyWith({
    int? id,
    String? brand,
    String? model,
    String? name,
    String? imageUrl,
    double? price,
    int? count,
    double? size,
    double? purchasePrice,
    bool? inCollection,
    bool? inFavorites,
    String? stockXUrl,
    String? goatUrl,
  }) {
    return Sneaker(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      count: count ?? _count,
      size: size ?? _size,
      purchasePrice: purchasePrice ?? _purchasePrice,
      inCollection: inCollection ?? _inCollection,
      inFavorites: inFavorites ?? _inFavorites,
      stockXUrl: stockXUrl ?? this.stockXUrl,
      goatUrl: goatUrl ?? this.goatUrl,
    );
  }
}