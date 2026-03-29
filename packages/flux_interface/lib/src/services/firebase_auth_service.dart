import 'dart:async';

import 'package:fstore/models/index.dart';

import '../entities/firebase_error_exception.dart';

class FirebaseAuthService {
  dynamic get currentUser => null;
  void deleteAccount() {}

  void loginFirebaseApple({authorizationCode, identityToken}) {}

  void loginFirebaseFacebook({token}) {}

  Future<void> loginFirebaseGoogle({String? idToken, String? accessToken}) async {}

  void loginFirebaseEmail({email, password}) {}

  Future<User?>? loginFirebaseCredential({credential}) => null;

  dynamic getFirebaseCredential({verificationId, smsCode}) => null;

  StreamController<String?>? getFirebaseStream() => null;

  Future<void> verifyPhoneNumber({
    phoneNumber,
    codeAutoRetrievalTimeout,
    codeSent,
    required void Function(String?) verificationCompleted,
    void Function(FirebaseErrorException error)? verificationFailed,
    forceResendingToken,
    Duration? timeout,
  }) async {}

  Future<bool> createUserWithEmailAndPassword({email, password}) async => false;

  Future<void> signOut() async {}

  Future<String?>? getIdToken() => null;
}
