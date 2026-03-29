import 'package:flutter/cupertino.dart';
import 'package:fstore/models/entities/product.dart';
import 'package:fstore/models/entities/user.dart';

import '../entities/firebase_error_exception.dart';
import 'firebase_analytics_service.dart';

class BaseFirebaseServices {
  /// check if the Firebase is enable or not
  bool get isEnabled => false;

  FirebaseAnalyticsService? get firebaseAnalytics => null;

  Future<void> init() async {}

  dynamic getCloudMessaging() {}

  dynamic getCurrentUser() => null;

  /// Login Firebase with social account
  void loginFirebaseApple({authorizationCode, identityToken}) {}

  void loginFirebaseFacebook({token}) {}

  Future<void> loginFirebaseGoogle({String? idToken, String? accessToken}) async {}

  void loginFirebaseEmail({email, password}) {}

  dynamic loginFirebaseCredential({credential}) {}

  dynamic getFirebaseCredential({verificationId, smsCode}) {}

  /// save user to firebase
  void saveUserToFirestore({User? user}) {}

  /// verify SMS login
  dynamic getFirebaseStream() {}

  Future<void> verifyPhoneNumber({
    phoneNumber,
    codeAutoRetrievalTimeout,
    codeSent,
    required void Function(String?) verificationCompleted,
    void Function(FirebaseErrorException error)? verificationFailed,
    forceResendingToken,
    Duration? timeout,
  }) async {}

  /// render Chat Screen
  Widget renderChatAuthScreen() => const SizedBox();

  Widget renderListChatScreen({String? email}) => const SizedBox();

  Widget renderChatScreen({
    User? senderUser,
    String? receiverEmail,
    String? receiverName,
    Product? product,
  }) =>
      const SizedBox();

  /// load firebase remote config
  Future<bool> loadRemoteConfig() async => false;

  String getRemoteConfigString(String key) => '';

  Future<List<String>> getRemoteKeys() async => [];

  /// Register new user with email and password.
  /// Returns true if successful (either created new user or signed in existing user).
  /// Throws FirebaseAuthException if authentication fails.
  Future<bool> createUserWithEmailAndPassword({email, password}) async => false;

  Future<void> signOut() async {}

  Future<String?> getMessagingToken() async => '';

  List<NavigatorObserver> getMNavigatorObservers() =>
      const <NavigatorObserver>[];

  void deleteAccount() {}

  Future<String?>? getIdToken() => null;
}
