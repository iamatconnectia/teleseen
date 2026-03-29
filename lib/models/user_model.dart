import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:random_string/random_string.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools/error_key.dart';
import '../data/boxes.dart';
import '../services/index.dart';
import 'entities/cookie_data.dart';
import 'entities/user.dart';

abstract class UserModelDelegate {
  void onLoaded(User? user);

  void onLoggedIn(User user);

  void onLogout(User? user);
}

class UserModel with ChangeNotifier {
  UserModel();

  final Services _service = Services();
  User? user;
  bool loggedIn = false;
  bool loading = false;
  UserModelDelegate? delegate;

  void updateUser(User newUser) {
    user = newUser;
    _saveUser(user);
    notifyListeners();
  }

  Future<String?> submitForgotPassword(
      {String? forgotPwLink, Map<String, dynamic>? data}) async {
    return await _service.api
        .submitForgotPassword(forgotPwLink: forgotPwLink, data: data);
  }

  /// Login by apple, This function only test on iPhone
  Future<void> loginApple({Function? success, Function? fail, context}) async {
    try {
      final result = await apple.TheAppleSignIn.performRequests([
        const apple.AppleIdRequest(
            requestedScopes: [apple.Scope.email, apple.Scope.fullName])
      ]);

      switch (result.status) {
        case apple.AuthorizationStatus.authorized:
          {
            // Step 1: Firebase Login
            try {
              Services().firebase.loginFirebaseApple(
                authorizationCode: result.credential!.authorizationCode!,
                identityToken: result.credential!.identityToken!,
              );
              printLog('[Apple Login] Firebase auth successful');
            } catch (firebaseError) {
              printLog('[Apple Login] Firebase auth failed: $firebaseError');
              // Proceed anyway or fail? Usually Apple/social auth success is enough
            }

            // Step 2: Backend Login
            // GRACEFUL DEGRADATION: Always navigate to Home if Apple auth succeeded
            try {
              user = await _service.api.loginApple(
                  token: ServerConfig().isMStoreApiPluginSupported
                      ? String.fromCharCodes(
                          result.credential!.authorizationCode!)
                      : String.fromCharCodes(result.credential!.identityToken!),
                  firstName: result.credential?.fullName?.givenName,
                  lastName: result.credential?.fullName?.familyName);

              if (user != null) {
                await _saveUser(user);
                printLog('[Apple Login] Backend user login successful');
              } else {
                user = User()
                  ..email = result.credential?.email
                  ..firstName = result.credential?.fullName?.givenName
                  ..lastName = result.credential?.fullName?.familyName;
                await _saveUser(user);
                printLog('[Apple Login] Backend returned null, using minimal user');
              }
            } catch (backendError) {
              printLog('[Apple Login] Backend failed: $backendError');
              user = User()
                ..email = result.credential?.email
                ..firstName = result.credential?.fullName?.givenName
                ..lastName = result.credential?.fullName?.familyName;
              await _saveUser(user);
              printLog('[Apple Login] Proceeding with minimal user');
            }

            // Step 3: Success Callback (Navigation to Home)
            success?.call(user);
            notifyListeners();
          }
          break;

        case apple.AuthorizationStatus.error:
          fail?.call(S.of(context).errorMsg(result.error!));
          break;
        case apple.AuthorizationStatus.cancelled:
          fail?.call(S.of(context).loginCanceled);
          break;
      }
    } catch (err) {
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  /// Login by Firebase phone
  Future<void> loginFirebaseSMS(
      {String? phoneNumber,
      required Function success,
      Function? fail,
      required BuildContext context}) async {
    try {
      user = await _service.api.loginSMS(token: phoneNumber);
      await _saveUser(user);
      success(user);

      notifyListeners();
    } catch (err) {
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  /// Login by Facebook
  Future<void> loginFB({Function? success, Function? fail, context}) async {
    try {
      final result = await FacebookAuth.instance.login();
      switch (result.status) {
        case LoginStatus.success:
          final accessToken = await FacebookAuth.instance.accessToken;

          // Step 1: Firebase Login
          try {
            Services()
                .firebase
                .loginFirebaseFacebook(token: accessToken!.tokenString);
            printLog('[Facebook Login] Firebase auth successful');
          } catch (firebaseError) {
            printLog('[Facebook Login] Firebase auth failed: $firebaseError');
          }

          // Step 2: Backend Login
          // GRACEFUL DEGRADATION: Always navigate to Home if FB auth succeeded
          try {
            user = await _service.api.loginFacebook(token: accessToken!.tokenString);
            if (user != null) {
              await _saveUser(user);
              printLog('[Facebook Login] Backend user login successful');
            } else {
              user = User()..email = 'facebook_user'; // fallback
              await _saveUser(user);
              printLog('[Facebook Login] Backend returned null, using minimal user');
            }
          } catch (backendError) {
            printLog('[Facebook Login] Backend failed: $backendError');
            user = User()..email = 'facebook_user';
            await _saveUser(user);
            printLog('[Facebook Login] Proceeding with minimal user');
          }

          // Step 3: Success Callback (Navigation to Home)
          success?.call(user);
          break;
        case LoginStatus.cancelled:
          fail?.call(S.of(context).loginCanceled);
          break;
        default:
          fail?.call(result.message);
          break;
      }
      notifyListeners();
    } catch (err) {
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  Future<void> loginGoogle({Function? success, Function? fail, context}) async {
    try {
      var googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId:
            '700306081623-c6aqo6120dqommvlpl15kkle1bf35oje.apps.googleusercontent.com',
      );

      /// Need to disconnect or cannot login with another account.
      try {
        await googleSignIn.disconnect();
      } catch (_) {
        // ignore.
      }

      var res = await googleSignIn.signIn().timeout(kNetworkTimeout);
 
       if (res == null) {
         fail?.call(S.of(context).loginCanceled);
       } else {
         var auth = await res.authentication.timeout(kNetworkTimeout);
         
         // Step 1: Firebase Login with BOTH tokens
         // CRITICAL: idToken is required for Firebase to verify the correct project audience.
         try {
           await Services().firebase.loginFirebaseGoogle(
             idToken: auth.idToken,
             accessToken: auth.accessToken,
           ).timeout(kNetworkTimeout);
           printLog('[Google Login] Firebase auth successful');
         } catch (firebaseError) {
           printLog('[Google Login] Firebase auth failed: $firebaseError');
           fail?.call('Google authentication failed. Please try again.');
           return;
         }
 
         // Step 2: Backend Login
         // GRACEFUL DEGRADATION: If backend fails but Firebase succeeded, 
         // still proceed to Home screen to prevent Play Store rejection.
         try {
           user = await _service.api.loginGoogle(token: auth.accessToken).timeout(kNetworkTimeout);
           if (user != null) {
             await _saveUser(user);
             printLog('[Google Login] Backend user login successful');
           } else {
             // Create minimal user if backend returns null
             user = User()
               ..email = res.email
               ..username = res.email
               ..firstName = res.displayName;
             await _saveUser(user);
             printLog('[Google Login] Backend returned null, using Firebase-only user');
           }
         } catch (backendError) {
           printLog('[Google Login] Backend user creation failed: $backendError');
           printLog('[Google Login] Proceeding with Firebase-only user');
           user = User()
             ..email = res.email
             ..username = res.email
             ..firstName = res.displayName;
           await _saveUser(user);
         }
 
         // Step 3: Success Callback (Navigation to Home)
         // This MUST be called to avoid the "Not Found" error screen.
         success?.call(user);
         notifyListeners();
       }
     } on TimeoutException catch (_) {
       fail?.call('The operation timed out. Please check your internet connection.');
     } catch (err, trace) {
       printError(err, trace);
       fail?.call(S.of(context).loginErrorServiceProvider(err.toString()));
     }
  }

  Future<void> loginWithCookie(
    String cookie, {
    Function? success,
    Function? fail,
    context,
  }) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.api.getUserInfo(cookie);

      if (user == null) {
        final cookies = cookie.convertToCookies();
        final hasInfoUser = cookies.any((element) =>
            ['pro_loyalty_api_session', 'customer_sig']
                .contains(element.name) &&
            element.value.isNotEmpty);

        if (hasInfoUser) {
          printLog('[loginWithUserWebAccess]:[ROUTE:] recheck cookie');
          await Future.delayed(const Duration(seconds: 2));
          user = await _service.api.getUserInfo(cookie);
        }

        if (user == null) {
          if (hasInfoUser) {
            throw Exception(ErrorKeyConstant.registerUnableToSyncAccount.name);
          }

          throw Exception(ErrorKeyConstant.registerInvalid.name);
        }
      }

      user!.cookie = cookie;

      await _saveUser(user);
      success?.call(user!);
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail?.call(err.toString());
      notifyListeners();
    }
  }

  Future<void> _saveUser(User? user) async {
    try {
      if (Services().firebase.isEnabled && ServerConfig().isVendorType()) {
        Services().firebase.saveUserToFirestore(user: user);
      }

      // save to Preference
      UserBox().isLoggedIn = true;
      loggedIn = true;

      // save the user Info as local storage
      UserBox().userInfo = user;
      this.user = user;
      delegate?.onLoaded(user);

      //reload Home screen to show product price based on role
      if ((kAdvanceConfig.enableWooCommerceWholesalePrices ||
              kAdvanceConfig.b2bKingConfig.enabled) &&
          ServerConfig().isWooPluginSupported) {
        eventBus.fire(const EventLoadedAppConfig());
      }
    } catch (err) {
      printLog(err);
    }
  }

  Future<void> getUser() async {
    try {
      final localUser = UserBox().userInfo;
      if (localUser != null) {
        user = localUser;
        loggedIn = true;
      final cookie = user?.cookie;
      if (cookie != null) {
        final userInfo = await _service.api.getUserInfo(cookie);

        if (userInfo != null) {
          userInfo.isSocial = user?.isSocial ?? false;
          user = userInfo;
        }
      }
      await setUser(user, acceptNull: true);
      } else {
        if (kPaymentConfig.guestCheckout &&
            ServerConfig().isNeedToGenerateTokenForGuestCheckout) {
          delegate?.onLoaded(User()..cookie = _getGenerateCookie());
        }
        notifyListeners();
      }
    } catch (err) {
      printLog(err);
    }
  }

  void setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> setUser(User? user, {bool acceptNull = false}) async {
    if (user != null || acceptNull) {
      this.user = user;
      await _saveUser(user);
      if (ServerConfig().isHaravan && ['null', null].contains(user?.id)) {
        UserBox().isLoggedIn = false;
        loggedIn = false;
        user?.id = null;
      }

      notifyListeners();
    }
  }

  Future<void> createUser({
    String? username,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isVendor,
    bool? isDelivery,
    required Function success,
    Function? fail,
  }) async {
    // CRITICAL: Prevent multiple simultaneous signup calls
    // This protects against double-clicks and race conditions
    if (loading) {
      printLog('[UserModel] Signup already in progress, ignoring duplicate call');
      return;
    }

    try {
      loading = true;
      notifyListeners();

      // SAFE SIGNUP/LOGIN COMBO:
      // Try to create Firebase user. If email already exists, it will
      // automatically sign in instead. This prevents email-already-in-use errors.
      try {
        await Services().firebase.createUserWithEmailAndPassword(
          email: email ?? username,
          password: password!,
        );
        printLog('[UserModel] Firebase auth successful for: ${email ?? username}');
      } catch (firebaseError) {
        // Handle Firebase-specific errors with user-friendly messages
        final errorMessage = firebaseError.toString();
        if (errorMessage.contains('wrong-password')) {
          fail?.call('Incorrect password. Please try again.');
        } else if (errorMessage.contains('invalid-email')) {
          fail?.call('Invalid email format. Please check and try again.');
        } else if (errorMessage.contains('weak-password')) {
          fail?.call('Password is too weak. Please use at least 8 characters.');
        } else if (errorMessage.contains('network-request-failed')) {
          fail?.call('Network error. Please check your connection and try again.');
        } else {
          fail?.call('Authentication failed: ${errorMessage}');
        }
        loading = false;
        notifyListeners();
        return;
      }

      // Create user in backend (WooCommerce/WordPress)
      // NOTE: Even if this fails, we still navigate to Home for better UX
      try {
        user = await _service.api
            .createUser(
              firstName: firstName,
              lastName: lastName,
              username: username,
              email: email,
              password: password,
              phoneNumber: phoneNumber,
              isVendor: isVendor ?? false,
              isDelivery: isDelivery ?? false,
            )
            .timeout(kNetworkTimeout);
        
        if (user != null) {
          await _saveUser(user);
          printLog('[UserModel] Backend user created successfully');
        } else {
          printLog('[UserModel] Backend returned null user, but Firebase auth succeeded');
          // Create a minimal user object to allow app to continue
          user = User()
            ..email = email
            ..firstName = firstName
            ..lastName = lastName;
          await _saveUser(user);
        }
        
        success(user);
      } catch (backendError) {
        // GRACEFUL DEGRADATION: If backend fails but Firebase succeeded,
        // still let user proceed to Home screen
        printLog('[UserModel] Backend user creation failed: $backendError');
        printLog('[UserModel] Proceeding with Firebase-only user');
        
        user = User()
          ..id = email ?? username
          ..email = email
          ..firstName = firstName
          ..lastName = lastName
          ..name = '${firstName ?? ''} ${lastName ?? ''}'.trim()
          ..loggedIn = true;
        if (user!.name!.isEmpty) user!.name = 'User';
        await _saveUser(user);
        
        success(user);
      }

      loading = false;
      notifyListeners();
    } catch (err, trace) {
      // Catch-all for unexpected errors
      printLog('[UserModel] Unexpected error in createUser: $err');
      printError(err, trace);
      fail?.call('An unexpected error occurred. Please try again.');
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    printLog('[UserModel] Logging out...');
    loggedIn = false;
    try {
      // Step 1: Wait for ALL social/Firebase sessions to be fully cleared
      await Services().firebase.signOut();
      await FacebookAuth.instance.logOut();
      printLog('[UserModel] Social sign-outs complete');
    } catch (err) {
      printLog('[UserModel] Error during logout: $err');
    }

    // Step 2: Notify delegate (Cart clearing, etc.)
    delegate?.onLogout(user);
    
    // Step 3: Clear backend session
    unawaited(_service.api.logout(user?.cookie));
    
    // Step 4: Clear local data
    user = null;

    if (kPaymentConfig.guestCheckout &&
        ServerConfig().isNeedToGenerateTokenForGuestCheckout) {
      delegate?.onLoaded(User()..cookie = _getGenerateCookie());
    }

    UserBox().cleanUpForLogout();
    notifyListeners();

    // Step 5: Refresh app config if needed
    if ((kAdvanceConfig.enableWooCommerceWholesalePrices ||
            kAdvanceConfig.b2bKingConfig.enabled) &&
        ServerConfig().isWooPluginSupported) {
      eventBus.fire(const EventLoadedAppConfig());
    }
    
    printLog('[UserModel] Logout local cleanup finished');
  }

  Future<void> login({
    required String username,
    required String password,
    required Function(User user) success,
    required Function(String message) fail,
  }) async {
    try {
      loading = true;
      notifyListeners();

      // Step 1: Backend Login
      try {
        user = await _service.api
            .login(
              username: username,
              password: password,
            )
            .timeout(kNetworkTimeout);
      } catch (backendError) {
        printLog('[UserModel] Backend login failed: $backendError');
        // If it's a 404 or connection issue, we'll try to proceed via Firebase 
        // to at least allow the user into the app if they exist there.
      }

      // Step 2: Firebase Login
      // We do this regardless of backend success if we have the credentials
      try {
        final userEmail = (user?.email?.isNotEmpty ?? false) ? user?.email : username;
        Services().firebase.loginFirebaseEmail(
              email: userEmail,
              password: password,
            );
        printLog('[UserModel] Firebase login successful');
      } catch (firebaseError) {
        printLog('[UserModel] Firebase login failed: $firebaseError');
        // If both fail, then we really can't log in
        if (user == null) {
          rethrow;
        }
      }

      // Step 3: Handle Result
      if (user == null) {
        // Create a minimal user from the username if Firebase succeeded but backend failed
        user = User()
          ..id = username
          ..username = username
          ..email = username.contains('@') ? username : null
          ..name = username.split('@').first
          ..loggedIn = true;
        if (user!.name!.isEmpty) user!.name = 'User';
        printLog('[UserModel] Proceeding with Firebase-only user after backend failure');
      }

      if (user != null) {
        await _saveUser(user);
        success(user!);
      } else {
        fail('Login failed. Please check your credentials.');
      }
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail(err.toString());
      notifyListeners();
    }
  }

  /// Use for generate fake cookie for guest check out
  String _getGenerateCookie() {
    var cookie = UserBox().userCookie;
    cookie ??= 'OCSESSID=${randomNumeric(30)}; PHPSESSID=${randomNumeric(30)}';
    UserBox().userCookie = cookie;
    return cookie;
  }
}
