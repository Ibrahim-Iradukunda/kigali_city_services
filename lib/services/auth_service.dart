import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store verification ID for phone authentication
  String? _verificationId;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with phone number
  Future<void> signUpWithPhone({
    required String phoneNumber,
    required String displayName,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android
          await _auth.signInWithCredential(credential);
          await _createUserProfile(displayName);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw _handleAuthError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verificationId for later use
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with phone number
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw _handleAuthError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Verify SMS code
  Future<User?> verifySmsCode(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Helper method to create user profile
  Future<void> _createUserProfile(String displayName, {String? email}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      UserProfile profile = UserProfile(
        uid: user.uid,
        email: email ?? user.email ?? user.phoneNumber ?? '',
        displayName: displayName,
        createdAt: DateTime.now(),
        locationNotifications: true,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profile.toFirestore());
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(displayName);

      // Create user profile in Firestore
      await _createUserProfile(displayName, email: email);

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Reload user to check verification status
  Future<bool> checkEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      user = _auth.currentUser;
      return user?.emailVerified ?? false;
    }
    return false;
  }

  // Get user profile from Firestore
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .update(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update notification preference
  Future<void> updateNotificationPreference(String uid, bool enabled) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'locationNotifications': enabled,
      });
    } catch (e) {
      throw Exception('Failed to update notification preference: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Handle Firebase Auth errors (including 400 from identitytoolkit)
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak (use at least 6 characters).';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled. Enable it in Firebase Console: Authentication → Sign-in method → Email/Password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }
}
