import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    //if(!dotenv.isInitialized) { await dotenv.load(fileName: ".env"); }
    if (Platform.isAndroid) {
      return dotenv.env['BANNER_AD_UNIT_ID_ANDROID'] ?? 'default-banner-ad-id';
    } else if (Platform.isIOS) {
      return dotenv.env['BANNER_AD_UNIT_ID_IOS'] ?? 'default-banner-ad-id';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['INTERSTITIAL_AD_UNIT_ID_ANDROID'] ?? 'default-interstitial-ad-id';
    } else if (Platform.isIOS) {
      return dotenv.env['INTERSTITIAL_AD_UNIT_ID_IOS'] ?? 'default-interstitial-ad-id';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['REWARDED_AD_UNIT_ID_ANDROID'] ?? 'default-rewarded-ad-id';
    } else if (Platform.isIOS) {
      return dotenv.env['REWARDED_AD_UNIT_ID_IOS'] ?? 'default-rewarded-ad-id';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }
}
