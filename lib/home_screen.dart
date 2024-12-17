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
      // Check for valid auth token
      final token = await ApiService.token;
      if (token == null) {
        _redirectToLogin();
        return;
      }

      // Verify token is still valid by making a test API call
      await ApiService.getUserProfile();

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
    } on AuthException {
      _redirectToLogin();
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                height: 65,
                child: BottomNavigationBar(
                  onTap: _onTabTapped,
                  currentIndex: _currentIndex,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white70,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search, size: 30),
                      activeIcon: Icon(Icons.search, size: 35),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.star, size: 30),
                      activeIcon: Icon(Icons.star, size: 35),
                      label: 'Collection',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite, size: 30),
                      activeIcon: Icon(Icons.favorite, size: 35),
                      label: 'Favorites',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person, size: 30),
                      activeIcon: Icon(Icons.person, size: 35),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}