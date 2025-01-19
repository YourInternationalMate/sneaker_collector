import 'package:flutter/material.dart';
import 'package:sneaker_collector/services/api_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isLoading = false;
  bool emailSent = false;

  Future<void> _sendVerificationEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.sendVerificationEmail();
      if (mounted) {
        setState(() {
          emailSent = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '"Email Verification"',
          style: TextStyle(
            fontFamily: 'future',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emailSent ? Icons.mark_email_read : Icons.email,
                size: 80,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 20),
              Text(
                emailSent
                    ? 'Verification email sent!'
                    : 'Please verify your email address',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'future',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!emailSent)
                ElevatedButton(
                  onPressed: isLoading ? null : _sendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
                          'Send Verification Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'future',
                          ),
                        ),
                ),
              if (emailSent)
                TextButton(
                  onPressed: _sendVerificationEmail,
                  child: const Text(
                    'Resend verification email',
                    style: TextStyle(
                      fontFamily: 'future',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}