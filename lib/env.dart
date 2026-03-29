import 'package:flutter_dotenv/flutter_dotenv.dart';

// ignore_for_file: prefer_single_quotes, lines_longer_than_80_chars final
String _env(String key, [String defaultValue = '']) {
  final value = dotenv.env[key];
  return value == null || value.isEmpty ? defaultValue : value;
}

final Map<String, dynamic> environment = _buildEnvironment();

Map<String, dynamic> _buildEnvironment() => {
  "appConfig": "lib/config/config_en.json",
  "serverConfig": {
    "url": _env('SERVER_URL', 'https://ktskw.com'),
    "type": "woo",
    "consumerKey": _env('WOOCOMMERCE_CONSUMER_KEY'),
    "consumerSecret": _env('WOOCOMMERCE_CONSUMER_SECRET')
  },
  "defaultDarkTheme": false,
  "enableRemoteConfigFirebase": true,
  "firebaseAnalyticsConfig": {
    "enableFirebaseAnalytics": true,
    "adStorageConsentGranted": null,
    "analyticsStorageConsentGranted": null,
    "adPersonalizationSignalsConsentGranted": null,
    "adUserDataConsentGranted": null,
    "functionalityStorageConsentGranted": null,
    "personalizationStorageConsentGranted": null,
    "securityStorageConsentGranted": null
  },
  "enableFacebookAppEvents": false,
  "webProxy": "",
  "maxTextScale": null,
  "loginSMSConstants": {
    "nameDefault": "Kuwait",
    "dialCodeDefault": "+965",
    "countryCodeDefault": "KW"
  },
  "phoneNumberConfig": {
    "enable": false,
    "selectorType": "BOTTOM_SHEET",
    "dialCodeDefault": "+965",
    "showCountryFlag": true,
    "customCountryList": ["KW"],
    "countryCodeDefault": "KW",
    "useInternationalFormat": true,
    "selectorFlagAsPrefixIcon": true
  },
  "appRatingConfig": {
    "ios": "1469772800",
    "android": "com.teleseen.webstore",
    "minDays": 7,
    "remindDays": 7,
    "showOnOpen": false,
    "minLaunches": 10,
    "remindLaunches": 10
  },
  "advanceConfig": {
    "DefaultLanguage": "en",
    "DetailedBlogLayout": "halfSizeImageType",
    "EnablePointReward": false,
    "hideOutOfStock": false,
    "HideEmptyTags": true,
    "HideEmptyCategories": true,
    "EnableRating": true,
    "hideEmptyRating": true,
    "EnableCart": true,
    "ShowBottomCornerCart": true,
    "EnableSkuSearch": true,
    "showStockStatus": true,
    "GridCount": 3,
    "isCaching": false,
    "OptimizeImage": {"enable": false, "plugin": "optimole"},
    "httpCache": false,
    "DefaultCurrency": {
      "symbol": "د.ك",
      "currency": "KWD",
      "countryCode": "",
      "currencyCode": "KWD",
      "decimalDigits": 2,
      "symbolBeforeTheNumber": true
    },
    "Currencies": [
      {
        "symbol": "د.ك",
        "currency": "KWD",
        "countryCode": "",
        "currencyCode": "KWD",
        "decimalDigits": 2,
        "symbolBeforeTheNumber": true
      }
    ],
    "DefaultStoreViewCode": "",
    "EnableAttributesConfigurableProduct": ["color", "size"],
    "isMultiLanguages": true,
    "EnableApprovedReview": false,
    "EnableSyncCartFromWebsite": true,
    "EnableSyncCartToWebsite": true,
    "EnableFirebase": true,
    "RatioProductImage": 1.2,
    "EnableCouponCode": true,
    "ShowCouponList": true,
    "ShowAllCoupons": true,
    "ShowExpiredCoupons": true,
    "AlwaysShowTabBar": false,
    "PrivacyPoliciesPageUrlOrId": "https://ktskw.com/privacy-policy/",
    "AboutUSPageUrl": "https://codecanyon.net/user/inspireui",
    "NewsPageUrl": "https://products.inspireui.com/",
    "FAQPageUrl": "https://products.inspireui.com/have-a-question/",
    "SupportPageUrl": "https://support.inspireui.com/",
    "DownloadPageUrl": "https://fluxstore.app/",
    "SocialConnectUrl": [
      {
        "url": "https://www.youtube.com/inspireui?sub_confirmation=1",
        "icon": "assets/icons/brands/youtube.svg",
        "name": "Youtube"
      },
      {
        "url": "https://www.facebook.com/inspireUI/",
        "icon": "assets/icons/brands/facebook.svg",
        "name": "Facebook"
      },
      {
        "url": "https://twitter.com/InspireUI",
        "icon": "assets/icons/brands/twitter.svg",
        "name": "Twitter"
      }
    ],
    "AutoDetectLanguage": true,
    "QueryRadiusDistance": 10,
    "MinQueryRadiusDistance": 1,
    "MaxQueryRadiusDistance": 10,
    "EnableWooCommerceWholesalePrices": false,
    "IsRequiredSiteSelection": true,
    "EnableDeliveryDateOnCheckout": false,
    "EnableNewSMSLogin": true,
    "EnableBottomAddToCart": true,
    "inAppWebView": true,
    "EnableWOOCSCurrencySwitcher": true,
    "enableProductBackdrop": false,
    "allowFilterMultipleCategory": false,
    "enableProductListCategoryMenu": true,
    "categoryImageMenu": true,
    "categoryImageBoxFit": null,
    "EnableDigitsMobileLogin": false,
    "EnableDigitsMobileFirebase": false,
    "EnableDigitsMobileWhatsApp": false,
    "WebViewScript": "",
    "versionCheck": {"enable": true, "iOSAppStoreCountry": "US"},
    "AjaxSearchURL": "",
    "AlwaysClearWebViewCache": false,
    "AlwaysClearWebViewCookie": false,
    "AlwaysRefreshBlog": false,
    "OrderNotesWithPrivateNote": true,
    "OrderNotesLinkSupport": false,
    "inAppUpdateForAndroid": {"enable": true, "typeUpdate": "flexible"},
    "categoryConfig": {"deepLevel": 3, "enableLargeCategories": false},
    "pinnedProductTags": [],
    "showOpeningStatus": true,
    "TimeShowToastMessage": 1500,
    "b2bKingConfig": {
      "enabled": false,
      "guestAccessRestriction": "replace_prices_quote"
    },
    "EnableTeraWalletWithdrawal": false,
    "allowGetDatasByCategoryFilter": false,
    "EnableIsAllData": false,
    "EnableWooSimpleAuction": false,
    "EnableManualAppTrackingTransparency": true,
    "gdpr": {
      "confirmCaptcha": "PERMANENTLY DELETE",
      "showDeleteAccount": true,
      "showPrivacyPolicyFirstTime": true
    },
    "kIsResizeImage": false,
    "PrivacyPoliciesPageId": null,
    "showRequestNotification": true,
    "cartCheckoutButtonLocation": "centerTop"
  },
  "pointsOfflineStoreConfig": {
    "enabled": false,
    "cardName": "FluxStore Card",
    "addPointRateForOnePoint": 100,
    "usePointRateForOnePoint": 1
  },
  "loyaltyConfig": {
    "enabled": false,
    "useTotalPointsForTier": true,
    "levels": {"bronze": 0, "silver": 500, "gold": 1000, "platinum": 1500},
    "usePointRateForOnePoint": 1,
    "addPointRateForOnePoint": 100
  },
  "defaultDrawer": {
    "logo": "assets/images/app_icon.png",
    "items": [
      {"show": true, "type": "home"},
      {"show": true, "type": "blog"},
      {"show": true, "type": "categories"},
      {"show": true, "type": "cart"},
      {"show": true, "type": "profile"},
      {"show": true, "type": "login"},
      {"show": true, "type": "category"}
    ],
    "background": null
  },
  "wishListConfig": {"type": "normal", "showCartButton": true},
  "defaultSettings": [
    "biometrics",
    "wallet",
    "wishlist",
    "notifications",
    "language",
    "currencies",
    "darkTheme",
    "order",
    "point",
    "rating",
    "privacy",
    "about",
    "my-rating"
  ],
  "loginSetting": {
    "IsRequiredLogin": false,
    "showAppleLogin": false,
    "showFacebook": false,
    "showSMSLogin": false,
    "showGoogleLogin": true,
    "showPhoneNumberWhenRegister": true,
    "requirePhoneNumberWhenRegister": true,
    "isResetPasswordSupported": true,
    "facebookAppId": "430258564493822",
    "facebookLoginProtocolScheme": "fb430258564493822",
    "facebookClientToken": "",
    "smsLoginAsDefault": false,
    "appleLoginSetting": {
      "iOSBundleId": "com.inspireui.mstore.flutter",
      "appleAccountTeamID": "S9RPAM8224"
    },
    "enable": true,
    "enableRegister": true,
    "requireUsernameWhenRegister": true
  },
  "oneSignalKey": {"appID": _env('ONESIGNAL_APP_ID'), "enable": false},
  "onBoardingConfig": {
    "data": [
      {
        "desc":
            "Incorporated in 1996, Kuwait Tele Seen, The first Tele-shopping company in Kuwait",
        "image": "assets/images/fogg-delivery-1.png",
        "title": "Welcome to Tele Seen"
      },
      {
        "desc":
            "See all things happening around you just by a click in your phone. Fast, convenient and clean.",
        "image": "assets/images/fogg-uploading-1.png",
        "title": "Connect Surrounding World"
      },
      {
        "desc": "Waiting no more, let's see what we get!",
        "image": "assets/images/fogg-order-completed.png",
        "title": "Let's Get Started"
      }
    ],
    "version": 1,
    "showLanguage": true,
    "enableOnBoarding": true,
    "showLanguagePopup": true,
    "autoCropImageByDesign": true,
    "isOnlyShowOnFirstTime": true
  },
  "adConfig": {
    "ads": [
      {
        "type": "banner",
        "iosId": "ca-app-pub-3940256099942544/2934735716",
        "provider": "google",
        "androidId": "ca-app-pub-3940256099942544/6300978111",
        "showOnScreens": ["home", "search"],
        "waitingTimeToDisplay": 2
      },
      {
        "type": "banner",
        "iosId": "ca-app-pub-2101182411274198/5418791562",
        "provider": "google",
        "androidId": "ca-app-pub-2101182411274198/4052745095"
      },
      {
        "type": "interstitial",
        "iosId": "ca-app-pub-3940256099942544/4411468910",
        "provider": "google",
        "androidId": "ca-app-pub-3940256099942544/4411468910",
        "showOnScreens": ["profile"],
        "waitingTimeToDisplay": 5
      },
      {
        "type": "reward",
        "iosId": "ca-app-pub-3940256099942544/1712485313",
        "provider": "google",
        "androidId": "ca-app-pub-3940256099942544/4411468910",
        "showOnScreens": ["cart"]
      },
      {
        "type": "banner",
        "iosId": "IMG_16_9_APP_INSTALL#430258564493822_876131259906548",
        "provider": "facebook",
        "androidId": "IMG_16_9_APP_INSTALL#430258564493822_489007588618919",
        "showOnScreens": ["home"]
      },
      {
        "type": "interstitial",
        "iosId": "430258564493822_489092398610438",
        "provider": "facebook",
        "androidId": "IMG_16_9_APP_INSTALL#430258564493822_489092398610438"
      }
    ],
    "enable": false,
    "adMobAppIdIos": "ca-app-pub-7432665165146018~2664444130",
    "googleTestingId": [],
    "adMobAppIdAndroid": "ca-app-pub-7432665165146018~2664444130",
    "facebookTestingId": ""
  },
  "dynamicLinkConfig": {
    "type": "firebase",
    "serviceConfigs": {
      "branchIO": {
        "keyLive": "",
        "keyTest": "",
        "testMode": true,
        "liveLinkDomain": "",
        "testLinkDomain": "",
        "liveAlternateLinkDomain": "",
        "testAlternateLinkDomain": ""
      },
      "firebase": {
        "link": "https://mstore.io/",
        "isEnabled": true,
        "uriPrefix": "https://fluxstoreinspireui.page.link",
        "iOSBundleId": "com.inspireui.mstore.flutter",
        "iOSAppStoreId": "1469772800",
        "androidPackageName": "com.teleseen.webstore",
        "iOSAppMinimumVersion": "1.0.1",
        "shortDynamicLinkEnable": true,
        "androidAppMinimumVersion": 1
      }
    }
  },
  "languagesInfo": [
    {
      "code": "en",
      "icon": "assets/images/country/gb.png",
      "name": "English",
      "text": "English",
      "storeViewCode": ""
    },
    {
      "code": "ar",
      "icon": "assets/images/country/ar.png",
      "name": "Arabic",
      "text": "العربية",
      "storeViewCode": "ar"
    }
  ],
  "paymentConfig": {
    "DefaultCountryISOCode": "KW",
    "DefaultStateISOCode": "",
    "enableOrderDetailSuccessful": true,
    "EnableShipping": true,
    "EnableAddress": true,
    "EnableCustomerNote": true,
    "EnableAddressLocationNote": false,
    "EnableAlphanumericZipCode": false,
    "EnableReview": true,
    "allowSearchingAddress": true,
    "GoogleApiKey": "",
    "GuestCheckout": true,
    "EnableWebviewCheckout": true,
    "ShowNativeCheckoutSuccessScreenForWebview": true,
    "EnableNativeCheckout": false,
    "CheckoutPageSlug": {"en": "checkout"},
    "EnableCreditCard": false,
    "UpdateOrderStatus": false,
    "ShowOrderNotes": true,
    "EnableRefundCancel": true,
    "RefundPeriod": 7,
    "SmartCOD": {"extraFee": 10, "amountStop": 200, "enabled": false},
    "excludedPaymentIds": [],
    "webPaymentIds": ["bacs"],
    "ShowTransactionDetails": true,
    "PaymentListAllowsCancelAndRefund": [],
    "EnableDownloadProduct": false
  },
  "payments": {
    "tap": "assets/icons/payment/tap.png",
    "paypal": "assets/icons/payment/paypal.svg",
    "stripe": "assets/icons/payment/stripe.svg",
    "midtrans": "assets/icons/payment/midtrans.png",
    "paystack": "assets/icons/payment/paystack.png",
    "razorpay": "assets/icons/payment/razorpay.svg",
    "xendit_cc": "assets/icons/payment/xendit.png",
    "thawani_gw": "assets/icons/payment/thawani.png",
    "ppcp-gateway": "assets/icons/payment/paypal.svg",
    "myfatoorah_v2": "assets/icons/payment/myfatoorah.png",
    "stripe_v2_apple_pay": "assets/icons/payment/apple-pay-mark.svg",
    "thai-promptpay-easy": "assets/icons/payment/prompt-pay.png",
    "expresspay_apple_pay": "assets/icons/payment/apple-pay-mark.svg",
    "stripe_v2_google_pay": "assets/icons/payment/google-pay-mark.png"
  },
  "paypalConfig": {
    "secret": _env('PAYPAL_SECRET'),
    "enabled": true,
    "clientId": _env('PAYPAL_CLIENT_ID'),
    "returnUrl": "com.teleseen.app://paypalpay",
    "nativeMode": false,
    "production": false,
    "paymentMethodId": "paypal"
  },
  "razorpayConfig": {
    "keyId": _env('RAZORPAY_KEY_ID'),
    "enabled": true,
    "keySecret": _env('RAZORPAY_KEY_SECRET'),
    "paymentMethodId": "razorpay"
  },
  "mercadoPagoConfig": {
    "enabled": true,
    "production": false,
    "accessToken": _env('MERCADOPAGO_ACCESS_TOKEN'),
    "paymentMethodId": "woo-mercado-pago-basic"
  },
  "payTmConfig": {
    "enabled": true,
    "merchantId": "your-merchant-id",
    "production": false,
    "paymentMethodId": "paytm"
  },
  "payStackConfig": {
    "enabled": true,
    "publicKey": _env('PAYSTACK_PUBLIC_KEY'),
    "secretKey": _env('PAYSTACK_SECRET_KEY'),
    "production": false,
    "paymentMethodId": "paystack",
    "enableMobileMoney": true,
    "supportedCurrencies": ["ZAR"]
  },
  "flutterwaveConfig": {
    "enabled": true,
    "publicKey": _env('FLUTTERWAVE_PUBLIC_KEY'),
    "production": false,
    "paymentMethodId": "rave"
  },
  "inAppPurchaseConfig": {
    "enabled": false,
    "consumableProductIDs": ["com.teleseen.webstore.test"],
    "subscriptionProductIDs": ["com.teleseen.webstore.subscription.test"],
    "nonConsumableProductIDs": []
  },
  "expressPayConfig": {
    "enabled": true,
    "merchantId": _env('EXPRESSPAY_MERCHANT_ID'),
    "production": false,
    "merchantKey": _env('EXPRESSPAY_MERCHANT_KEY'),
    "paymentMethodId": "shahbandrpay",
    "merchantPassword": _env('EXPRESSPAY_MERCHANT_PASSWORD')
  },
  "thaiPromptPayConfig": {
    "enabled": false,
    "paymentMethodId": "thai-promptpay-easy"
  },
  "phonepeConfig": {
    "enabled": true,
    "saltKey": _env('PHONEPE_SALT_KEY'),
    "merchantId": _env('PHONEPE_MERCHANT_ID'),
    "production": false,
    "iOSBundleId": "com.inspireui.mstore.flutter",
    "saltKeyIndex": "1",
    "paymentMethodIds": ["phonepe"],
    "androidPackageName": "com.teleseen.webstore"
  },
  "defaultCountryShipping": [
    {
      "name": "Kuwait",
      "iosCode": "KW",
      "icon": "https://cdn.britannica.com/70/6070-004-2367807D/Flag-Kuwait.jpg"
    }
  ],
  "afterShip": {
    "api": _env('AFTERSHIP_API_KEY'),
    "tracking_url": "https://fluxstore.aftership.com"
  },
  "googleApiKey": {
    "ios": _env('GOOGLE_API_KEY_IOS'),
    "web": _env('GOOGLE_API_KEY_WEB'),
    "android": _env('GOOGLE_API_KEY_ANDROID')
  },
  "productCard": {"defaultImage": "assets/images/no_product_image.png"},
  "productDetail": {
    "boxFit": "contain",
    "height": 0.4,
    "layout": "simpleType",
    "showSku": true,
    "safeArea": false,
    "marginTop": 88.9,
    "showBrand": true,
    "showVideo": true,
    "expandTags": true,
    "showRating": true,
    "borderRadius": 3,
    "enableReview": true,
    "expandBrands": true,
    "expandInfors": true,
    "allowMultiple": false,
    "expandReviews": true,
    "buyButtonStyle": "fixedBottom",
    "attributeLayout": "normal",
    "autoPlayGallery": true,
    "expandSizeGuide": true,
    "limitDayBooking": 14,
    "showProductTags": true,
    "showStockStatus": true,
    "sizeGuideConfig": {
      "url": "",
      "enable": false,
      "attributes": ["Size"]
    },
    "ShowImageGallery": true,
    "expandCategories": true,
    "expandDescription": true,
    "showRecentProduct": true,
    "showStockQuantity": true,
    "productImageLayout": "page",
    "productMetaDataKey": "",
    "showQuantityInList": false,
    "showRelatedProduct": true,
    "SliderIndicatorType": "number",
    "alwaysShowBuyButton": true,
    "attributeImagesSize": 50,
    "ForceWhiteBackground": false,
    "showThumbnailAtLeast": 1,
    "allowShareProductData": true,
    "hideInvalidAttributes": false,
    "productListItemHeight": 125,
    "showProductCategories": true,
    "SliderShowGoBackButton": true,
    "AutoSelectFirstAttribute": true,
    "ShowSelectedImageVariant": true,
    "showAddToCartInSearchResult": true
  },
  "blogDetail": {
    "showHeart": true,
    "showComment": true,
    "showSharing": true,
    "showAuthorInfo": true,
    "showRelatedBlog": true,
    "enableAudioSupport": false,
    "showTextAdjustment": true
  },
  "productVariantLayout": {
    "size": "box",
    "color": "color",
    "height": "option",
    "color-image": "image"
  },
  "productAddons": {
    "allowMultiple": false,
    "allowImageType": true,
    "allowVideoType": true,
    "allowCustomType": true,
    "allowedCustomType": ["png", "pdf", "docx"],
    "fileUploadSizeLimit": 5
  },
  "cartDetail": {
    "style": "style01",
    "maxAllowQuantity": 10,
    "minAllowTotalCartValue": 0
  },
  "productVariantLanguage": {
    "ar": {
      "size": "بحجم",
      "color": "اللون",
      "height": "ارتفاع",
      "color-image": "اللون"
    },
    "en": {
      "size": "Size",
      "color": "Color",
      "height": "Height",
      "color-image": "Color"
    },
    "vi": {
      "size": "Kích thước",
      "color": "Màu",
      "height": "Chiều Cao",
      "color-image": "Màu"
    }
  },
  "excludedCategoryIDs": "",
  "excludedProductIDs": "",
  "saleOffProduct": {
    "Color": "#C7222B",
    "ShowCountDown": true,
    "HideEmptySaleOffLayout": false
  },
  "notStrictVisibleVariant": true,
  "configChat": {
    "version": "2",
    "iconConfig": {
      "icon": "chat_rounded",
      "size": 32,
      "color": null,
      "fontFamily": ""
    },
    "hideOnScreens": [],
    "showOnScreens": ["profile"],
    "EnableSmartChat": true,
    "enableVendorChat": true,
    "realtimeChatConfig": {
      "enable": true,
      "adminName": "InspireUI",
      "adminEmail": "admininspireui@gmail.com",
      "userCanDeleteChat": false,
      "userCanBlockAnotherUser": false,
      "adminCanAccessAllChatRooms": false
    }
  },
  "smartChat": [
    {
      "app": "https://wa.me/96566808808",
      "iconData": "whatsapp",
      "description": "WhatsApp"
    },
    {"app": "tel:96566808808", "iconData": "phone", "description": "Call Us"},
  ],
  "vendorConfig": {
    "BannerFit": "cover",
    "VendorRegister": true,
    "DeliveryRegister": false,
    "NewProductStatus": "draft",
    "DefaultStoreImage": "assets/images/default-store-banner.png",
    "VendorDashboardUrl": "",
    "DeliveryDashboardUrl": "",
    "HideStoreContactInfo": false,
    "ShowAllVendorMarkers": true,
    "DisablePendingProduct": false,
    "DisableVendorShipping": false,
    "DisableMultiVendorCheckout": false,
    "DisableNativeStoreManagement": true,
    "ExpandStoreLocationByDefault": true,
    "EnableAutoApplicationApproval": false,
    "ShowPopUpIfMultiVendorDetected": false,
    "DisableNativeDeliveryManagement": true
  },
  "deliveryConfig": {
    "appLogo": "assets/images/app_icon.png",
    "appName": "TeleSeen Delivery",
    "dashboardName1": "TeleSeen",
    "dashboardName2": "Delivery",
    "enableSystemNotes": false
  },
  "managerConfig": {
    "appLogo": "assets/images/app_icon.png",
    "appName": "TeleSeen Admin",
    "enableDeliveryFeature": false
  },
  "loadingIcon": {"size": 34.7, "type": "threeInOut", "layout": "spinkit"},
  "splashScreen": {
    "type": "fade-in",
    "image": "assets/images/splashscreen_new.png",
    "boxFit": "contain",
    "enable": true,
    "duration": 2000,
    "paddingTop": 0,
    "paddingLeft": 0,
    "paddingRight": 0,
    "animationName": "Tele Seen",
    "paddingBottom": 0,
    "backgroundColor": "#ffffff"
  },
  "reviewConfig": {
    "service": "judge",
    "maxImage": 5,
    "judgeConfig": {
      "apiKey": _env('JUDGE_REVIEW_API_KEY'),
      "domain": "https://inspireui-mstore.myshopify.com"
    },
    "enableReview": true,
    "enableReviewImage": true
  },
  "orderConfig": {"version": 1},
  "bankTransferConfig": {
    "paymentMethodIds": ["bacs"]
  },
  "cashOnDeliveryConfig": {
    "paymentMethodIds": []
  },
  "version": "",
  "darkConfig": {
    "logo": "assets/images/app_icon.png",
    "MainColor": "FFF44336",
    "saleColor": "#E15241"
  },
  "lightConfig": {
    "logo": "assets/images/app_icon.png",
    "MainColor": "FFF44336",
    "saleColor": "#E15241"
  },
  "enableFirebaseAnalytics": true
};
