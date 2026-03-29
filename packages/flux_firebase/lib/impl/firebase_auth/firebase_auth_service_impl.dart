import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flux_interface/flux_interface.dart';
import 'package:fstore/models/entities/user.dart' as entities;
import 'package:google_sign_in/google_sign_in.dart';

import 'entities/firebase_exception.dart';
import 'extensions/firebase_user_extention.dart';

class FirebaseAuthServiceImpl extends FirebaseAuthService {
  final _auth = FirebaseAuth.instance;

  @override
  dynamic get currentUser => _auth.currentUser;

  @override
  void deleteAccount() {
    _auth.currentUser?.delete();
  }

  @override
  void loginFirebaseApple({authorizationCode, identityToken}) async {
    final AuthCredential credential = OAuthProvider('apple.com').credential(
      accessToken: String.fromCharCodes(authorizationCode),
      idToken: String.fromCharCodes(identityToken),
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  void loginFirebaseFacebook({token}) async {
    AuthCredential credential = FacebookAuthProvider.credential(token);
    await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> loginFirebaseGoogle({String? idToken, String? accessToken}) async {
    // CRITICAL: idToken is required for Firebase to verify the audience/project correctly.
    // accessToken alone can lead to audience mismatch errors.
    AuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  void loginFirebaseEmail({email, password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (err) {
      /// In case this user was registered on web
      /// so Firebase user was not created.
      /// TODO: Update solution if user enable this option
      /// https://stackoverflow.com/a/77744190/19622959
      if (err is FirebaseAuthException && err.code == 'user-not-found') {
        /// Create Firebase user automatically.
        /// createUserWithEmailAndPassword will auto sign in after success.
        /// No need to call signInWithEmailAndPassword again.
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      /// Ignore other cases.
    }
  }

  @override
  Future<entities.User?>? loginFirebaseCredential({credential}) async {
    try {
      return (await _auth.signInWithCredential(credential)).user?.toEntityApp();
    } on FirebaseAuthException catch (err) {
      throw err.toEntityApp();
    }
  }

  @override
  PhoneAuthCredential getFirebaseCredential({verificationId, smsCode}) {
    try {
      return PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
    } on FirebaseAuthException catch (err) {
      throw err.toEntityApp();
    }
  }

  @override
  StreamController<String?> getFirebaseStream() {
    return StreamController<String?>.broadcast();
  }

  @override
  Future<void> verifyPhoneNumber({
    phoneNumber,
    codeAutoRetrievalTimeout,
    codeSent,
    required void Function(String?) verificationCompleted,
    void Function(FirebaseErrorException error)? verificationFailed,
    forceResendingToken,
    Duration? timeout,
  }) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber!,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        codeSent: codeSent,
        timeout: timeout ?? const Duration(seconds: 120),
        verificationCompleted: (phoneAuthCredential) {
          verificationCompleted(phoneAuthCredential.smsCode);
        },
        verificationFailed: (error) =>
            verificationFailed?.call(error.toEntityApp()),
        forceResendingToken: forceResendingToken);
  }

  @override
  Future<bool> createUserWithEmailAndPassword({email, password}) async {
    try {
      // Try to create a new user
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('[Firebase Auth] User created successfully: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      // If email already exists, sign in instead
      if (e.code == 'email-already-in-use') {
        print('[Firebase Auth] Email already exists, signing in instead: $email');
        try {
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('[Firebase Auth] Sign in successful: $email');
          return true;
        } on FirebaseAuthException catch (signInError) {
          print('[Firebase Auth] Sign in failed: ${signInError.code} - ${signInError.message}');
          // Re-throw sign-in errors (e.g., wrong password)
          rethrow;
        }
      } else {
        // Re-throw other Firebase errors
        print('[Firebase Auth] Create user failed: ${e.code} - ${e.message}');
        rethrow;
      }
    } catch (e) {
      print('[Firebase Auth] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      print('[FirebaseAuthServiceImpl] Error signing out: $e');
    }
  }

  @override
  Future<String?>? getIdToken() {
    return _auth.currentUser?.getIdToken();
  }
}
