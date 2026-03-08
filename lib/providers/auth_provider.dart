import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;
  bool _isEmailVerified = false;
  bool _isWaitingForPhoneVerification = false;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmailVerified => _isEmailVerified;
  bool get isWaitingForPhoneVerification => _isWaitingForPhoneVerification;
  bool get isAuthenticated => _user != null;

  StreamSubscription<User?>? _authSubscription;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authSubscription = _authService.authStateChanges.listen((
      User? user,
    ) async {
      _user = user;
      if (user != null) {
        // For phone auth, consider it verified immediately
        _isEmailVerified = user.emailVerified || user.phoneNumber != null;
        _isWaitingForPhoneVerification = false;
        await _loadUserProfile();
      } else {
        _userProfile = null;
        _isEmailVerified = false;
        _isWaitingForPhoneVerification = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      try {
        _userProfile = await _authService.getUserProfile(_user!.uid);
      } catch (e) {
        _error = e.toString();
      }
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? e.code;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? e.code;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Resend email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerified() async {
    try {
      bool verified = await _authService.checkEmailVerified();
      _isEmailVerified = verified;
      notifyListeners();
      return verified;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update notification preference
  Future<void> updateNotificationPreference(bool enabled) async {
    if (_user != null) {
      try {
        await _authService.updateNotificationPreference(_user!.uid, enabled);
        _userProfile = _userProfile?.copyWith(locationNotifications: enabled);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Sign up with phone number
  Future<bool> signUpWithPhone({
    required String phoneNumber,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    _isWaitingForPhoneVerification = true;
    notifyListeners();

    try {
      await _authService.signUpWithPhone(
        phoneNumber: phoneNumber,
        displayName: displayName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isWaitingForPhoneVerification = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with phone number
  Future<bool> signInWithPhone(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    _isWaitingForPhoneVerification = true;
    notifyListeners();

    try {
      await _authService.signInWithPhone(phoneNumber);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isWaitingForPhoneVerification = false;
      notifyListeners();
      return false;
    }
  }

  // Verify SMS code
  Future<bool> verifySmsCode(String smsCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      User? user = await _authService.verifySmsCode(smsCode);
      if (user != null) {
        _user = user;
        _isEmailVerified = true; // Phone auth is automatically verified
        await _loadUserProfile();
      }
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
