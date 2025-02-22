import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Android için test ad unit ID
      return 'ca-app-pub-3940256099942544/6300978111';
      // Gerçek uygulama için kendi ad unit ID'nizi kullanın:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      // iOS için test ad unit ID
      return 'ca-app-pub-3940256099942544/2934735716';
      // Gerçek uygulama için kendi ad unit ID'nizi kullanın:
      // return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Android için test ad unit ID
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // iOS için test ad unit ID
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      // Android için test ad unit ID
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      // iOS için test ad unit ID
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }
}