import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/retry_button.dart';
import 'package:sneaker_collector/pages/email_verification.dart';
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
    _checkEmailVerification();
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 20),
              RetryButton(
                onRetry: () {
                  Navigator.of(context).pop();
                  _initializeApp();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkEmailVerification() async {
    try {
      final userProfile = await ApiService.getUserProfile();
      if (!userProfile.isEmailVerified) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EmailVerificationScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Failed to check E-Mail',
          'Please check your internet connection and try again.'
        );
      }
    }
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
