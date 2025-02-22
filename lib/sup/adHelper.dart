import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1085565023845596/9658681403';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1085565023845596/8793188261';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1085565023845596/5537541362';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1085565023845596/8127808009';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1085565023845596/6666520703';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1085565023845596/1562399656';
    } else {
      throw UnsupportedError('Desteklenmeyen platform');
    }
  }
}