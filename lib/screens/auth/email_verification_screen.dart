import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _canResend = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final authProvider = context.read<AuthProvider>();
      bool verified = await authProvider.checkEmailVerified();
      if (verified && mounted) {
        timer.cancel();
        // AuthWrapper will handle navigation
      }
    });
  }

  void _resendEmail() async {
    if (!_canResend) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.sendEmailVerification();

    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification email sent!'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 50,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Text(
                  'We\'ve sent a verification email to\n${auth.user?.email ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your inbox and verify your email to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Resend button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _canResend ? _resendEmail : null,
                  child: Text(
                    _canResend
                        ? 'Resend Verification Email'
                        : 'Resend in ${_resendCooldown}s',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _canResend
                          ? AppTheme.accentGold
                          : AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sign out
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().signOut();
                },
                child: const Text(
                  'Sign out and use a different account',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              // Loading indicator
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Waiting for verification...',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
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
