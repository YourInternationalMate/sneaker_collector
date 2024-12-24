# components/product_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';

class ProductCard extends StatelessWidget {
  final Sneaker sneaker;
  final Function onTapFunction;
  final Function? onCollectionToggle;
  final Function? onFavoriteToggle;

  const ProductCard(
    this.sneaker, {
    super.key,
    required this.onTapFunction,
    this.onCollectionToggle,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapFunction();
      },
      child: SizedBox(
      height: 160,
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Container(
                width: 140,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    sneaker.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                ),
              ),

                // Name of the Sneaker
                title: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${sneaker.brand} ${sneaker.model}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),

                // reaker Details
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      sneaker.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      '\$${sneaker.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Future",
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons to add sneaker to Collection or Favs
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      print('DEBUG: Collection toggle pressed for sneaker: ${sneaker.toString()}');
                      print('DEBUG: Sneaker details - ID: ${sneaker.id}, Model: ${sneaker.model}, Brand: ${sneaker.brand}');
                      onCollectionToggle!();},
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                    child: Icon(Icons.star,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  ElevatedButton(
                    onPressed: () => onFavoriteToggle!(),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                    child: Icon(Icons.favorite,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

# components/shoe_size_dropdown.dart

```dart
import 'package:flutter/material.dart';

class ShoeSizeDropdown extends StatefulWidget {
  final Function(String) onSizeSelected;
  final String? initialSize;

  const ShoeSizeDropdown({
    Key? key, 
    required this.onSizeSelected,
    this.initialSize,
  }) : super(key: key);

  @override
  _ShoeSizeDropdownState createState() => _ShoeSizeDropdownState();
}

class _ShoeSizeDropdownState extends State<ShoeSizeDropdown> {
  String? _selectedSize;
  
  @override
  void initState() {
    super.initState();
    _initializeSize();
  }

  void _initializeSize() {
    if (widget.initialSize != null) {
      try {
        double? sizeValue = double.tryParse(widget.initialSize!);
        if (sizeValue != null) {
          _selectedSize = sizeValue.toStringAsFixed(sizeValue.truncateToDouble() == sizeValue ? 0 : 1);
        }
      } catch (e) {
        debugPrint('Error parsing initial size: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, 
      child: DropdownButtonFormField<String>(
        value: _selectedSize,
        hint: const Text('Select Size'),
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        menuMaxHeight: 150,
        items: <String>[
          '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', 
          '10.5', '11', '11.5', '12', '12.5', '13', '13.5', '14',
          '14.5', '15', '16', '17', '18'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'future',
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedSize = newValue;
          });
          if (newValue != null) {
            widget.onSizeSelected(newValue);
          }
        },
      ),
    );
  }
}
```

# components/size_selection_dialog.dart

```dart
import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/shoe_size_dropdown.dart';

Future<double?> showSizeSelectionDialog(BuildContext context) async {
  String? selectedSize;
  
  final result = await showDialog<double>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          '"Select Size"',
          style: TextStyle(
            fontFamily: 'future',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              width: double.minPositive,
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShoeSizeDropdown(
                    onSizeSelected: (size) {
                      selectedSize = size;
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text('CANCEL',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
          ),
          TextButton(
            onPressed: () {
              if (selectedSize != null) {
                Navigator.of(context).pop(double.parse(selectedSize!));
              }
            },
            child: Text('CONFIRM',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
          ),
        ],
      );
    },
  );

  return result;
}
```

# home_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:sneaker_collector/services/api_service.dart';
import 'package:sneaker_collector/pages/favorites_screen.dart';
import 'package:sneaker_collector/pages/search_screen.dart';
import 'package:sneaker_collector/pages/collection_screen.dart';
import 'package:sneaker_collector/pages/profile_screen.dart';
import 'package:sneaker_collector/pages/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);

    try {
      // Prüfe auf vorhandene Token
      final token = await ApiService.token;
      if (token == null) {
        _redirectToLogin();
        return;
      }

      // Versuche das Nutzerprofil zu laden
      try {
        await ApiService.getUserProfile();
      } catch (e) {
        // Wenn das Laden des Profils fehlschlägt, Token löschen und neu einloggen
        await ApiService.clearTokens();
        _redirectToLogin();
        return;
      }

      if (mounted) {
        setState(() {
          _pages = [
            Search(),
            const Collection(),
            const Favorites(),
            const Profile(),
          ];
          _isLoading = false;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Failed to initialize app',
          'Please check your internet connection and try again.'
        );
      }
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _showErrorDialog(String title, String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('RETRY'),
              onPressed: () {
                Navigator.of(context).pop();
                _initializeApp();
              },
            ),
            TextButton(
              child: const Text('LOGOUT'),
              onPressed: () async {
                await ApiService.logout();
                _redirectToLogin();
              },
            ),
          ],
        );
      },
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo/SneakerCollectorLogo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
          child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.secondary,
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.search, 0),
                _buildNavItem(Icons.star, 1),
                _buildNavItem(Icons.favorite, 2),
                _buildNavItem(Icons.person, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(
          icon,
          size: 30,
          color: isSelected ? Colors.white : Colors.white70,
        ),
      ),
    );
  }
}

```

# main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sneaker_collector/home_screen.dart';
import 'package:sneaker_collector/theme/theme.dart';
import 'pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    )
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sneaker Collector',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen()
      },
    );
  }
}

```

# models/sneaker.dart

```dart
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
```

# models/user.dart

```dart
class User {
  String name;
  String email;
  String password;
  String since;

  User({
    required this.name, 
    required this.email, 
    required this.password,
    required this.since});
}
```

# pages/buying_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/size_selection_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/services/api_service.dart';
import 'package:sneaker_collector/components/shoe_size_dropdown.dart';

class BuyingScreen extends StatefulWidget {
  final Sneaker sneaker;

  const BuyingScreen({super.key, required this.sneaker});

  @override
  _BuyingScreenState createState() => _BuyingScreenState();
}

class _BuyingScreenState extends State<BuyingScreen> {
  bool isAddingToCollection = false;
  bool isAddingToFavorites = false;
  bool isSizeSelected = false;
  double? selectedSize;
  bool showSizeError = false;

  Future<void> _launchURL(String? url, String platform) async {
    if (url == null) {
      _showErrorSnackbar('No $platform link available for this sneaker');
      return;
    }

    final Uri uri = Uri.parse(url);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        throw Exception('Could not launch URL');
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Could not open $platform');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _toggleCollection() async {
    if (!widget.sneaker.inCollection) {
      final selectedSize = await showSizeSelectionDialog(context);
      if (selectedSize == null) {
        return;
      }
      widget.sneaker.setSize(selectedSize);
    }

    setState(() => isAddingToCollection = true);

    try {
      final success = await ApiService.updateCollection(widget.sneaker);

      if (mounted) {
        if (success) {
          setState(() {
            widget.sneaker.setInCollection(!widget.sneaker.inCollection);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
            e is ApiException ? e.message : 'Failed to update collection');
      }
    } finally {
      if (mounted) {
        setState(() => isAddingToCollection = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => isAddingToFavorites = true);

    try {
      final success = await ApiService.toggleFavorite(widget.sneaker);

      if (mounted) {
        if (success) {
          setState(() {
            widget.sneaker.setInFavorites(!widget.sneaker.inFavorites);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
            e is ApiException ? e.message : 'Failed to update favorites');
      }
    } finally {
      if (mounted) {
        setState(() => isAddingToFavorites = false);
      }
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
        ),
      ],
    );
  }

  Widget _buildBuyButton(String platform, VoidCallback onPressed) {
    return SizedBox(
      width: 300,
      height: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          platform,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontFamily: "Future",
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${widget.sneaker.brand} ${widget.sneaker.model}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold,
            fontFamily: "Future",
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Column(
            children: <Widget>[
              // Sneaker Image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.sneaker.imageUrl,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),

              // Sneaker Details
              const SizedBox(height: 20),
              Text(
                widget.sneaker.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Future",
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '\$${widget.sneaker.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Future",
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: widget.sneaker.inCollection
                        ? Icons.star
                        : Icons.star_border,
                    onPressed: _toggleCollection,
                    isLoading: isAddingToCollection,
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: widget.sneaker.inFavorites
                        ? Icons.favorite
                        : Icons.favorite_border,
                    onPressed: _toggleFavorite,
                    isLoading: isAddingToFavorites,
                  ),
                ],
              ),

              const SizedBox(height: 80),

              // Buy Buttons
              _buildBuyButton(
                'StockX',
                () => _launchURL(widget.sneaker.stockXUrl, 'StockX'),
              ),
              const SizedBox(height: 20),
              _buildBuyButton(
                'GOAT',
                () => _launchURL(widget.sneaker.goatUrl, 'GOAT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

# pages/collection_screen.dart

```dart
// lib/pages/collection_screen.dart

import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/size_selection_dialog.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/detail_screen.dart';
import 'package:sneaker_collector/services/api_service.dart';

class Collection extends StatefulWidget {
  const Collection({super.key});

  @override
  _CollectionState createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  List<Sneaker> sneakers = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;
  double totalValue = 0.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCollection();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (isLoadingMore || currentPage >= totalPages) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await ApiService.getCollection(page: currentPage + 1);
      if (mounted) {
        setState(() {
          sneakers.addAll(response.items);
          currentPage = response.page;
          totalPages = response.pages;
          isLoadingMore = false;
          _updateTotalValue();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _loadCollection() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getCollection(page: 1);
      if (mounted) {
        print('DEBUG: Loaded collection items:');
        for (var sneaker in response.items) {
          print('DEBUG: Sneaker - ID: ${sneaker.id}, Model: ${sneaker.model}, Brand: ${sneaker.brand}');
        }
        setState(() {
          sneakers = response.items;
          currentPage = response.page;
          totalPages = response.pages;
          isLoading = false;
          _updateTotalValue();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _updateTotalValue() {
    totalValue = sneakers.fold(0.0, (total, sneaker) {
      double itemTotal = (sneaker.price * sneaker.count);
      return total + itemTotal;
    });
  }

  void _showErrorSnackbar(dynamic error) {
    String message = 'An error occurred';
    if (error is ApiException) {
      message = error.message;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _removeFromCollection(Sneaker sneaker, int index) async {
    final sneakersCopy = List<Sneaker>.from(sneakers);
    setState(() {
      sneakers.removeAt(index);
      _updateTotalValue();
    });

    try {
      await ApiService.removeFromCollection(sneaker);
    } catch (e) {
      if (mounted) {
        setState(() {
          sneakers = sneakersCopy;
          _updateTotalValue();
        });
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _removeFromCollectionWithConfirmation(Sneaker sneaker) async {
    print('DEBUG: Attempting to remove sneaker: ${sneaker.toString()}'); // Add this line
    print('DEBUG: Sneaker ID: ${sneaker.id}'); // Add this line

    if (sneaker.id == null) {
      _showErrorSnackbar('Invalid sneaker ID');
      return;
    }

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Collection'),
          content: const Text(
              'Are you sure you want to remove this sneaker from your collection?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('CANCEL',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'REMOVE',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      try {
        print('DEBUG: Making API call to remove sneaker ID: ${sneaker.id}');
        await ApiService.removeFromCollection(sneaker);
        if (mounted) {
          setState(() {
            print('DEBUG: Removing sneaker from state, ID: ${sneaker.id}');
            sneakers.removeWhere((s) => s.id == sneaker.id);
            _updateTotalValue();
          });
        }
      } catch (e) {
        if (mounted) {
          print('DEBUG: Error removing sneaker: $e');
          _showErrorSnackbar(e);
        }
      }
    }
  }

  void navigateToDetailScreen(BuildContext context, Sneaker sneaker) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(sneaker: sneaker),
      ),
    );

    if (result == true && mounted) {
      _loadCollection();
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error ?? 'An error occurred',
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadCollection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your collection is empty.\nAdd sneakers from the search page!',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'future',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCollection(Sneaker sneaker) async {
    if (!sneaker.inCollection) {
      final selectedSize = await showSizeSelectionDialog(context);
      if (selectedSize == null) {
        return;
      }
      sneaker.setSize(selectedSize);
    }

    try {
      final success = await ApiService.updateCollection(sneaker);
      if (mounted && success) {
        setState(() {
          sneaker.setInCollection(!sneaker.inCollection);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _toggleFavorite(Sneaker sneaker) async {
    try {
      final success = await ApiService.toggleFavorite(sneaker);
      if (mounted && success) {
        setState(() {
          sneaker.setInFavorites(!sneaker.inFavorites);
        });
      }
    } catch (e) {
      _showErrorSnackbar(e);
    }
  }

  Widget _buildCollectionList() {
    return RefreshIndicator(
      onRefresh: _loadCollection,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sneakers.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == sneakers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return ProductCard(
            sneakers[index],
            onTapFunction: () => navigateToDetailScreen(
              context,
              sneakers[index],
            ),
            onCollectionToggle: () =>
                _removeFromCollectionWithConfirmation(sneakers[index]),
            onFavoriteToggle: () => _toggleFavorite(sneakers[index]),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Total Pairs', sneakers.length.toString()),
          _buildStat(
            'Total Value',
            '\$${totalValue.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 14,
            fontFamily: 'future',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'future',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '"Collection"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? _buildErrorView()
                      : sneakers.isEmpty
                          ? _buildEmptyView()
                          : _buildCollectionList(),
            ),
            if (!isLoading && error == null && sneakers.isNotEmpty)
              _buildStats(),
          ],
        ),
      ),
    );
  }
}

```

# pages/detail_screen.dart

```dart
// lib/pages/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/components/shoe_size_dropdown.dart';
import 'package:sneaker_collector/services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Sneaker sneaker;

  const DetailScreen({Key? key, required this.sneaker}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _purchasePriceController;
  late TextEditingController _amountController;
  bool isSaving = false;
  String? error;
  String _selectedSize = '';
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _purchasePriceController = TextEditingController(
      text: widget.sneaker.purchasePrice.toString()
    );
    _amountController = TextEditingController(
      text: widget.sneaker.count.toString()
    );
    _selectedSize = widget.sneaker.size.toString();

    // Überwache Änderungen
    _purchasePriceController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _purchasePriceController.removeListener(_onFieldChanged);
    _amountController.removeListener(_onFieldChanged);
    _purchasePriceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final newPurchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final newAmount = int.tryParse(_amountController.text) ?? 0;
    
    setState(() {
      hasUnsavedChanges = newPurchasePrice != widget.sneaker.purchasePrice ||
                         newAmount != widget.sneaker.count ||
                         (_selectedSize != widget.sneaker.size.toString() &&
                          _selectedSize.isNotEmpty);
    });
  }

  Future<bool> _onWillPop() async {
    if (!hasUnsavedChanges) return true;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'DISCARD',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _toggleFavorite() async {
    setState(() => isSaving = true);

    try {
      final success = await ApiService.toggleFavorite(widget.sneaker);
      if (mounted) {
        setState(() {
          widget.sneaker.setInFavorites(!widget.sneaker.inFavorites);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _showErrorSnackbar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is ApiException ? error.message : 'An error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _validateInputs() {
    if (_amountController.text.isEmpty ||
        int.tryParse(_amountController.text) == null ||
        int.parse(_amountController.text) <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return false;
    }

    if (_purchasePriceController.text.isNotEmpty) {
      final price = double.tryParse(_purchasePriceController.text);
      if (price == null || price < 0) {
        _showErrorSnackbar('Please enter a valid purchase price');
        return false;
      }
    }

    if (_selectedSize.isEmpty) {
      _showErrorSnackbar('Please select a size');
      return false;
    }

    return true;
  }

  Future<void> saveChanges() async {
    if (!_validateInputs()) return;

    setState(() {
      isSaving = true;
      error = null;
    });

    try {
      widget.sneaker
        ..setPurchasePrice(double.parse(_purchasePriceController.text))
        ..setCount(int.parse(_amountController.text))
        ..setSize(double.parse(_selectedSize));

      await ApiService.updateCollection(widget.sneaker);
      
      if (mounted) {
        setState(() {
          hasUnsavedChanges = false;
        });
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Future",
            fontSize: 24,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontFamily: "Future",
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            "${widget.sneaker.brand} ${widget.sneaker.model}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
              fontFamily: "Future",
              fontSize: 24,
            ),
          ),
          actions: [
            if (hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: isSaving ? null : saveChanges,
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: Column(
                children: <Widget>[
                  // Sneaker Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.sneaker.imageUrl,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),

                  // Sneaker Name and Price
                  const SizedBox(height: 20),
                  Text(
                    widget.sneaker.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '\$${widget.sneaker.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Future",
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Current Details
                  _buildDetailRow(
                    'Purchase Price:',
                    '\$${_purchasePriceController.text}',
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Amount:',
                    _amountController.text,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Size:',
                    _selectedSize,
                  ),
                  const SizedBox(height: 80),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isSaving ? null : _toggleFavorite,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Icon(
                          widget.sneaker.inFavorites
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 40),
                      ElevatedButton(
                        onPressed: isSaving ? null : () => _showEditDialog(context),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Align(
            alignment: Alignment.center,
            child: Text(
              '"Edit Sneaker"',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Future",
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                
                // Purchase Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Price: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _purchasePriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: const Icon(Icons.attach_money),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Amount: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Size
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Size: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      ShoeSizeDropdown(
                        initialSize: widget.sneaker.size.toString(),
                        onSizeSelected: (String size) {
                          setState(() {
                            _selectedSize = size;
                            hasUnsavedChanges = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Save Button
                ElevatedButton(
                  onPressed: isSaving ? null : () {
                    saveChanges();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 10,
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "SAVE",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Future",
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

# pages/favorites_screen.dart

```dart
// lib/pages/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/services/api_service.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<Sneaker> sneakers = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _toggleCollection(Sneaker sneaker) async {
    try {
      final success = await ApiService.updateCollection(sneaker);
      if (mounted && success) {
        setState(() {
          sneaker.setInCollection(!sneaker.inCollection);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _toggleFavorite(Sneaker sneaker) async {
    try {
      final success = await ApiService.toggleFavorite(sneaker);
      if (mounted && success) {
        setState(() {
          sneaker.setInFavorites(!sneaker.inFavorites);
          _loadFavorites();
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _loadMoreItems() async {
    if (isLoadingMore || currentPage >= totalPages) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await ApiService.getFavorites(page: currentPage + 1);
      if (mounted) {
        setState(() {
          sneakers.addAll(response.items);
          currentPage = response.page;
          totalPages = response.pages;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getFavorites(page: 1);
      if (mounted) {
        setState(() {
          sneakers = response.items;
          currentPage = response.page;
          totalPages = response.pages;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e is ApiException ? e.message : 'Failed to load favorites';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(Sneaker sneaker, int index) async {
    final sneakersCopy = List<Sneaker>.from(sneakers);
    setState(() {
      sneakers.removeAt(index);
    });

    try {
      await ApiService.removeFromFavorites(sneaker);
    } catch (e) {
      if (mounted) {
        setState(() {
          sneakers = sneakersCopy;
        });
        _showErrorSnackbar(e);
      }
    }
  }

  void _showErrorSnackbar(dynamic error) {
    String message = 'An error occurred';
    if (error is ApiException) {
      message = error.message;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void navigateToBuyingScreen(BuildContext context, Sneaker sneaker) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyingScreen(sneaker: sneaker),
      ),
    );

    if (result == true && mounted) {
      _loadFavorites();
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error ?? 'An error occurred',
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadFavorites,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your favorites list is empty.\nAdd sneakers from the search page!',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'future',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sneakers.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == sneakers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Dismissible(
            key: Key(sneakers[index].id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Remove from Favorites'),
                    content: const Text(
                      'Are you sure you want to remove this sneaker from your favorites?'
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'REMOVE',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) => _removeFavorite(sneakers[index], index),
            child: ProductCard(
              sneakers[index],
              onTapFunction: () => navigateToBuyingScreen(
                context,
                sneakers[index],
              ),
              onCollectionToggle: () => _toggleCollection(sneakers[index]),
              onFavoriteToggle: () => _toggleFavorite(sneakers[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    if (sneakers.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Favorites', sneakers.length.toString()),
          _buildStat(
            'Average Price',
            '\$${_calculateAveragePrice().toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 14,
            fontFamily: 'future',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'future',
          ),
        ),
      ],
    );
  }

  double _calculateAveragePrice() {
    if (sneakers.isEmpty) return 0;
    final total = sneakers.fold(
      0.0,
      (sum, sneaker) => sum + sneaker.price,
    );
    return total / sneakers.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '"Favorites"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? _buildErrorView()
                      : sneakers.isEmpty
                          ? _buildEmptyView()
                          : _buildFavoritesList(),
            ),

            _buildStats(),
          ],
        ),
      ),
    );
  }
}
```

# pages/login_screen.dart

```dart
// lib/pages/login_screen.dart

import 'package:flutter/material.dart';
import 'package:sneaker_collector/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _registerUsernameController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    _registerEmailController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    
    try {
      await ApiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    
    try {
      await ApiService.register(
        _registerUsernameController.text,
        _registerEmailController.text,
        _registerPasswordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildLoginPanel() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        children: [
          const Text(
            '"LOGIN"',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'future'
            ),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'USERNAME',
              labelStyle: TextStyle(
                fontFamily: 'future',
                color: Theme.of(context).colorScheme.tertiary
              ),
              prefixIcon: const Icon(Icons.person),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            validator: _validateUsername,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'PASSWORD',
              labelStyle: TextStyle(
                fontFamily: 'future',
                color: Theme.of(context).colorScheme.tertiary
              ),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontFamily: 'future',
                      fontWeight: FontWeight.bold
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterPanel() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        children: [
          const Text(
            '"REGISTER"',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'future'
            ),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _registerUsernameController,
            decoration: InputDecoration(
              labelText: 'USERNAME',
              labelStyle: TextStyle(
                fontFamily: 'future',
                color: Theme.of(context).colorScheme.tertiary
              ),
              prefixIcon: const Icon(Icons.person),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            validator: _validateUsername,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _registerEmailController,
            decoration: InputDecoration(
              labelText: 'EMAIL',
              labelStyle: TextStyle(
                fontFamily: 'future',
                color: Theme.of(context).colorScheme.tertiary
              ),
              prefixIcon: const Icon(Icons.email),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _registerPasswordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'PASSWORD',
              labelStyle: TextStyle(
                fontFamily: 'future',
                color: Theme.of(context).colorScheme.tertiary
              ),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'REGISTER',
                    style: TextStyle(
                      fontFamily: 'future',
                      fontWeight: FontWeight.bold
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo
                Image.asset(
                  'assets/images/logo/SneakerCollectorLogo.png',
                  width: 200,
                  height: 200
                ),
                const SizedBox(height: 50),

                // Login/Register Panel
                isLogin ? _buildLoginPanel() : _buildRegisterPanel(),
                const SizedBox(height: 20),

                // Switch between login and register
                TextButton(
                  onPressed: isLoading ? null : () {
                    setState(() {
                      isLogin = !isLogin;
                      // Clear form fields when switching
                      _formKey.currentState?.reset();
                      _usernameController.clear();
                      _passwordController.clear();
                      _registerUsernameController.clear();
                      _registerEmailController.clear();
                      _registerPasswordController.clear();
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'No account yet? Register here!'
                        : 'Already have an account? Login here!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontFamily: 'future'
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

# pages/profile_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:sneaker_collector/models/user.dart';
import 'package:sneaker_collector/services/api_service.dart';
import 'package:sneaker_collector/pages/login_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  User? user;
  bool isLoading = true;
  bool isSaving = false;
  bool isPasswordVisible = false;
  String? error;
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _setupControllerListeners();
  }

  void _setupControllerListeners() {
    _usernameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _passwordController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    if (!mounted) return;

    setState(() {
      hasUnsavedChanges = _usernameController.text != user?.name ||
          _emailController.text != user?.email ||
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _usernameController.removeListener(_checkForChanges);
    _emailController.removeListener(_checkForChanges);
    _passwordController.removeListener(_checkForChanges);
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userProfile = await ApiService.getUserProfile();
      if (mounted) {
        setState(() {
          user = userProfile;
          _usernameController.text = userProfile.name;
          _emailController.text = userProfile.email;
          isLoading = false;
        });
      }
    } on AuthException {
      _redirectToLogin();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e is ApiException ? e.message : 'Failed to load profile';
          isLoading = false;
        });
      }
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Password is optional for updates
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    if (!hasUnsavedChanges) {
      return;
    }

    setState(() {
      isSaving = true;
      error = null;
    });

    try {
      final updatedUser = await ApiService.updateProfile(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
      );

      if (mounted) {
        setState(() {
          user = updatedUser;
          _passwordController.clear();
          hasUnsavedChanges = false;
          isSaving = false;
        });
        _showSuccessSnackbar('Profile updated successfully');
      }
    } on AuthException {
      _redirectToLogin();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e is ApiException ? e.message : 'Failed to update profile';
          isSaving = false;
        });
        _showErrorSnackbar(error!);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!hasUnsavedChanges) return true;

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Discard changes?',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary),
            ),
            content: Text(
                'You have unsaved changes. Do you want to discard them?',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.tertiary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'CANCEL',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'DISCARD',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _logout() async {
    if (hasUnsavedChanges) {
      final shouldProceed = await _onWillPop();
      if (!shouldProceed) return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'CANCEL',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'LOGOUT',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ApiService.logout();
        _redirectToLogin();
      } catch (e) {
        // Even if logout fails, redirect to login
        _redirectToLogin();
      }
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error ?? 'An error occurred',
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadUserProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
        fontFamily: 'future',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
      ),
      suffixIcon: suffixIcon,
      floatingLabelStyle: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontFamily: 'future',
      ),
      fillColor: Theme.of(context).colorScheme.surface,
      filled: true,
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '"Profile"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
            ),

            // Profile Picture and Basic Info
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user?.name ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Text(
              'Member since ${user?.since ?? ''}',
              style: const TextStyle(fontSize: 15),
            ),

            // Edit Profile Form
            Padding(
              padding: const EdgeInsets.all(25),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: _getInputDecoration(
                          label: "USERNAME", icon: Icons.person),
                      validator: _validateUsername,
                      enabled: !isSaving,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: _getInputDecoration(
                          label: "EMAIL", icon: Icons.email),
                      validator: _validateEmail,
                      enabled: !isSaving,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: _getInputDecoration(
                        label: 'NEW PASSWORD',
                        icon: Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !isPasswordVisible,
                      validator: _validatePassword,
                      enabled: !isSaving,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 30),

                    // In profile_screen.dart, ersetzen Sie die Buttons durch:

                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: isSaving ? null : _saveData,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(20),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        Icons.save,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 24,
                                      ),
                              ),
                              const SizedBox(width: 40),
                              ElevatedButton(
                                onPressed: isSaving ? null : _logout,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(20),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                ),
                                child: Icon(
                                  Icons.logout,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorView()
                : _buildProfileContent(),
      ),
    );
  }
}

```

# pages/search_screen.dart

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/size_selection_dialog.dart';
import 'package:sneaker_collector/models/sneaker.dart';
import 'package:sneaker_collector/services/api_service.dart';
import 'package:sneaker_collector/components/product_card.dart';
import 'package:sneaker_collector/pages/buying_screen.dart';

class Search extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<Search> {
  List<Sneaker> sneakers = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String lastQuery = '';
  int currentPage = 1;
  int totalPages = 1;
  String? error;
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialSneakers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSneakers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Lade nur die ersten 20 Sneaker, sortiert nach Neuheit
      final response = await ApiService.searchSneakers(
        '',
        page: 1,
        limit: 20,
        sort: 'newest'  // Diese Option müsste im Backend unterstützt werden
      );
      
      if (mounted) {
        setState(() {
          sneakers = response.items;
          currentPage = response.page;
          totalPages = response.pages;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          error = e is ApiException ? e.message : 'Failed to load sneakers';
        });
        _showErrorSnackbar(error ?? 'Unknown error');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (isLoadingMore || currentPage >= totalPages || lastQuery.isEmpty) return;

    setState(() {
      isLoadingMore = true;
      error = null;
    });

    try {
      final response = await ApiService.searchSneakers(
        lastQuery,
        page: currentPage + 1,
      );
      
      if (mounted) {
        setState(() {
          sneakers.addAll(response.items);
          currentPage = response.page;
          totalPages = response.pages;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
          error = e is ApiException ? e.message : 'Failed to load more results';
        });
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _performSearch(String query) async {
    // Cancel any previous search
    _debounce?.cancel();

    if (query.isEmpty) {
      _loadInitialSneakers();
      return;
    }

    // Debounce the search
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      setState(() {
        isLoading = true;
        error = null;
        lastQuery = query;
      });

      try {
        final response = await ApiService.searchSneakers(query, page: 1);
        if (mounted) {
          setState(() {
            sneakers = response.items;
            currentPage = response.page;
            totalPages = response.pages;
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
            error = e is ApiException ? e.message : 'An error occurred. Please try again.';
            sneakers.clear();
          });
          _showErrorSnackbar(error ?? 'Unknown error');
        }
      }
    });
  }

  Future<void> _toggleCollection(Sneaker sneaker) async {
    if (!sneaker.inCollection) {
      final selectedSize = await showSizeSelectionDialog(context);
      if (selectedSize == null) {
        return;
      }
      sneaker.setSize(selectedSize);
    }

    try {
      final success = await ApiService.updateCollection(sneaker);
      if (mounted && success) {
        setState(() {
          sneaker.setInCollection(!sneaker.inCollection);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    }
  }

  Future<void> _toggleFavorite(Sneaker sneaker) async {
    try {
      final success = await ApiService.toggleFavorite(sneaker);
      if (mounted && success) {
        setState(() {
          sneaker.setInFavorites(!sneaker.inFavorites);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e);
      }
    }
  }

  void _showErrorSnackbar(dynamic error) {
    String message = 'An error occurred';
    if (error is ApiException) {
      message = error.message;
    } else if (error is String) {
      message = error;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void navigateToBuyingScreen(BuildContext context, Sneaker sneaker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyingScreen(sneaker: sneaker),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: searchController,
        onChanged: _performSearch,
        decoration: InputDecoration(
          labelText: "Search",
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.secondary,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          floatingLabelStyle: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
        ),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => searchController.text.isEmpty 
                  ? _loadInitialSneakers()
                  : _performSearch(searchController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (sneakers.isEmpty && searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No sneakers found.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: sneakers.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == sneakers.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return ProductCard(
          sneakers[index],
          onTapFunction: () => navigateToBuyingScreen(
            context,
            sneakers[index],
          ),
          onCollectionToggle: () => _toggleCollection(sneakers[index]),
          onFavoriteToggle: () => _toggleFavorite(sneakers[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '"Search"',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
              ),
            ),
            
            _buildSearchBar(),
            const SizedBox(height: 20),
            
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
}
```

# services/api_service.dart

```dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sneaker.dart';
import '../models/user.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pages;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponse(
      items: (json['items'] as List).map((item) => fromJson(item)).toList(),
      total: json['total'],
      page: json['page'],
      pages: json['pages'],
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorId;

  ApiException(this.message, {this.statusCode, this.errorId});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException() : super('No internet connection available');
}

class AuthException extends ApiException {
  AuthException() : super('Authentication failed', statusCode: 401);
}

class RateLimitException extends ApiException {
  RateLimitException() : super('Rate limit exceeded. Please try again later.', statusCode: 429);
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5001/api/v1';
  static String? _accessToken;
  static String? _refreshToken;
  static DateTime? _tokenExpiry;

  // Token Getter mit automatischer Erneuerung
  static Future<String?> get token async {
    if (_accessToken != null && _tokenExpiry != null) {
      // Wenn der Token bald abläuft (weniger als 1 Minute), erneuere ihn
      if (_tokenExpiry!.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
        await _refreshAccessToken();
      }
      return _accessToken;
    }
    
    // Versuche Token aus SharedPreferences zu laden
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    final expiryString = prefs.getString('token_expiry');
    
    if (expiryString != null) {
      _tokenExpiry = DateTime.parse(expiryString);
    }
    
    if (_accessToken != null && _tokenExpiry != null) {
      if (_tokenExpiry!.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
        await _refreshAccessToken();
      }
      return _accessToken;
    }
    
    return null;
  }

  static Future<void> setTokens(String accessToken, String refreshToken) async {
    try {
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      // Setze Ablaufzeit auf 14 Minuten (da Token 15 Minuten gültig ist)
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 14));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());
    } catch (e) {
      throw ApiException('Failed to save tokens: $e');
    }
  }

  static Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw AuthException();
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_refreshToken'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(const Duration(minutes: 14));
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());
      } else {
        // Bei Fehler alle Token löschen
        await clearTokens();
        throw AuthException();
      }
    } catch (e) {
      await clearTokens();
      throw AuthException();
    }
  }

  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expiry');
  }

  static Future<Map<String, String>> get headers async {
      final token = await ApiService.token;
      if (token == null) throw AuthException();
      
      return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // Make sure there's a space after 'Bearer'
      };
  }

  static Future<T> _handleResponse<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>) parser,
  ) async {
    try {
      final response = await request();
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 401) {
        throw AuthException();
      }

      if (response.statusCode == 429) {
        throw RateLimitException();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return parser(data);
      }

      final error = json.decode(response.body);
      print('Error response: $error');
      throw ApiException(
        error['message'] ?? error['error'] ?? 'An error occurred',
        statusCode: response.statusCode,
        errorId: error['error_id'],
      );
    } catch (e) {
      print('Exception in _handleResponse: $e');
      rethrow;
    }
  }

  // Auth Methods
  static Future<Map<String, dynamic>> login(String username, String password) async {
    return _handleResponse(
      () => http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ),
      (data) {
        if (data['access_token'] != null && data['refresh_token'] != null) {
          setTokens(data['access_token'], data['refresh_token']);
        }
        return data;
      },
    );
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    return _handleResponse(
      () => http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ),
      (data) {
        if (data['access_token'] != null && data['refresh_token'] != null) {
          setTokens(data['access_token'], data['refresh_token']);
        }
        return data;
      },
    );
  }

  static Future<void> logout() async {
    try {
      final token = await ApiService.token;
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );
      }
    } finally {
      await clearTokens();
    }
  }

  // Profile Methods
  static Future<User> getUserProfile() async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: await headers,
      ),
      (data) => User(
        name: data['user']['username'],
        email: data['user']['email'],
        password: '',
        since: data['user']['since'],
      ),
    );
  }

  static Future<User> updateProfile({
    String? username,
    String? email,
    String? password,
  }) async {
    final Map<String, dynamic> updateData = {};
    if (username != null) updateData['username'] = username;
    if (email != null) updateData['email'] = email;
    if (password != null) updateData['password'] = password;

    return _handleResponse(
      () async => http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: await headers,
        body: json.encode(updateData),
      ),
      (data) => User(
        name: data['user']['username'],
        email: data['user']['email'],
        password: '',
        since: data['user']['since'],
      ),
    );
  }

  // Collection Methods
  static Future<PaginatedResponse<Sneaker>> getCollection({int page = 1}) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/collection?page=$page'),
        headers: await headers,
      ),
      (data) {
        print('DEBUG: Raw collection response data: $data');
        final response = PaginatedResponse.fromJson(
          data,
          (json) {
            print('DEBUG: Converting JSON to Sneaker: $json');
            return Sneaker.fromJson(json);
          },
        );
        return response;
      },
    );
  }

  static Future<bool> updateCollection(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/collection'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
          'count': sneaker.count,
          'size': sneaker.size,
          'purchase_price': sneaker.purchasePrice,
        }),
      ),
      (data) => true,
    );
  }

  static Future<bool> removeFromCollection(Sneaker sneaker) async {
    print('DEBUG: API Service - Removing sneaker from collection');
    print('DEBUG: API Service - Sneaker ID: ${sneaker.id}');
    print('DEBUG: API Service - Full sneaker object: ${sneaker.toString()}');

  return _handleResponse(
    () async => http.delete(
      Uri.parse('$baseUrl/collection'),
      headers: await headers,
      body: json.encode({
        'product_id': sneaker.id,
      }),
    ),
    (data) => true,
  );
}

  // Favorites Methods
  static Future<PaginatedResponse<Sneaker>> getFavorites({int page = 1}) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/favorites?page=$page'),
        headers: await headers,
      ),
      (data) => PaginatedResponse.fromJson(
        data,
        (json) => Sneaker.fromJson(json),
      ),
    );
  }

  static Future<bool> toggleFavorite(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
        }),
      ),
      (data) => true,
    );
  }

  static Future<bool> removeFromFavorites(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.delete(
        Uri.parse('$baseUrl/favorites'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
        }),
      ),
      (data) => true,
    );
  }

  // Search Methods
  static Future<PaginatedResponse<Sneaker>> searchSneakers(
    String query, {
    int page = 1,
    int limit = 20,
    String? sort,
  }) async {
    final queryParams = {
      if (query.isNotEmpty) 'query': query,
      'page': page.toString(),
      'per_page': limit.toString(),
      if (sort != null) 'sort': sort,
    };

    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);
    
    return _handleResponse(
      () async => http.get(
        uri,
        headers: await headers,
      ),
      (data) => PaginatedResponse.fromJson(
        data,
        (json) => Sneaker.fromJson(json),
      ),
    );
  }

  static Future<Sneaker> getSneakerDetails(int productId) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: await headers,
      ),
      (data) => Sneaker.fromJson(data),
    );
  }
}
```

# theme/theme.dart

```dart
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Color(0xffF1F1F1),
    primary: Colors.white,
    secondary: Color(0xFF6F2DFF),
    tertiary: Colors.black
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Colors.black,
    primary: Color(0xff232323),
    secondary: Color(0xFF6F2DFF),
    tertiary: Colors.white
  ),
);
```

