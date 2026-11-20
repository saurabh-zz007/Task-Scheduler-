import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_scheduler/features/auth/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  /// Stream of authentication state changes mapped to [UserModel].
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map(
          (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
        );
  }

  /// Get currently signed-in user as [UserModel].
  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  /// Sign in with Email and Password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException in signInWithEmail: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      developer.log('Unexpected error in signInWithEmail: $e');
      throw _handleGenericException(e, 'email sign-in');
    }
  }

  /// Sign up with Email and Password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        if (displayName != null && displayName.trim().isNotEmpty) {
          await user.updateDisplayName(displayName.trim());
          await user.reload();
        }
        final updatedUser = _auth.currentUser ?? user;
        return UserModel.fromFirebaseUser(updatedUser);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException in signUpWithEmail: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      developer.log('Unexpected error in signUpWithEmail: $e');
      throw _handleGenericException(e, 'sign-up');
    }
  }

  /// Sign in with Google
  /// Returns `null` if user cancels the flow without throwing.
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('Google sign-in cancelled by user');
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException in signInWithGoogle: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      developer.log('Unexpected error in signInWithGoogle: $e');
      final str = e.toString().toLowerCase();
      if (str.contains('canceled') || str.contains('cancelled') || str.contains('sign_in_canceled')) {
        return null;
      }
      if (str.contains('network') || str.contains('socket') || str.contains('connection')) {
        throw 'Network connection error. Please check your internet connection.';
      }
      throw 'Unable to complete Google sign-in. Please try again or use email sign-in.';
    }
  }

  /// Sign in with Facebook
  /// Returns `null` if user cancels the flow without throwing.
  Future<UserModel?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success && result.accessToken != null) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;
        return user != null ? UserModel.fromFirebaseUser(user) : null;
      } else if (result.status == LoginStatus.cancelled) {
        developer.log('Facebook sign-in cancelled by user');
        return null;
      } else {
        developer.log('Facebook login failed: ${result.message}');
        throw 'Facebook sign-in could not be completed. Please try again.';
      }
    } on FirebaseAuthException catch (e) {
      developer.log('FirebaseAuthException in signInWithFacebook: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      developer.log('Unexpected error in signInWithFacebook: $e');
      throw 'Facebook sign-in is currently unavailable. Please try again later.';
    }
  }

  /// Sign in with Apple using OAuthProvider
  /// Seamless cross-platform support for iOS, Android, and Web.
  /// Returns `null` if user cancels the flow without throwing.
  Future<UserModel?> signInWithApple() async {
    try {
      final appleProvider = OAuthProvider('apple.com')
        ..addScope('email')
        ..addScope('name');

      final userCredential = await _auth.signInWithProvider(appleProvider);
      final user = userCredential.user;
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' ||
          e.code == 'popup-closed-by-user' ||
          e.code == 'web-context-cancelled') {
        developer.log('Apple sign-in cancelled by user');
        return null;
      }
      developer.log('FirebaseAuthException in signInWithApple: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      developer.log('Unexpected error in signInWithApple: $e');
      final str = e.toString().toLowerCase();
      if (str.contains('canceled') || str.contains('cancelled')) {
        return null;
      }
      throw 'Apple sign-in is currently unavailable. Please try again later.';
    }
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut().catchError((_) => null),
        _facebookAuth.logOut().catchError((_) => null),
      ]);
    } catch (e) {
      developer.log('Error during sign-out: $e');
      await _auth.signOut();
    }
  }

  /// Maps Firebase auth exception codes to user-friendly messages without leaking technical info.
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code.toLowerCase()) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for that email address. Please log in.';
      case 'operation-not-allowed':
        return 'This sign-in method is temporarily unavailable. Please try another method.';
      case 'weak-password':
        return 'The password provided is too weak. Please use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few moments before trying again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email under a different sign-in method.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'For security reasons, please log in again to continue.';
      case 'popup-closed-by-user':
      case 'canceled':
      case 'cancelled':
        return 'Sign-in was cancelled.';
      default:
        return 'Authentication failed. Please verify your details and try again.';
    }
  }

  /// Maps unknown/generic exceptions to safe, user-friendly messages.
  String _handleGenericException(dynamic e, String action) {
    final str = e.toString().toLowerCase();
    if (str.contains('network') ||
        str.contains('socket') ||
        str.contains('connection') ||
        str.contains('timeout') ||
        str.contains('offline')) {
      return 'Network connection issue. Please check your internet connection.';
    }
    return 'Unable to complete $action. Please try again.';
  }
}
