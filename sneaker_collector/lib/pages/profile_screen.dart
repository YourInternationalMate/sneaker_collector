import 'package:flutter/material.dart';
import 'package:sneaker_collector/components/retry_button.dart';
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
          Text(error ?? 'Failed to load profile'),
          const SizedBox(height: 20),
          RetryButton(
            onRetry: _loadUserProfile,
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
