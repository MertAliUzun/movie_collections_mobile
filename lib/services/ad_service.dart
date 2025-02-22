import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../sup/adHelper.dart';
import 'dart:async';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;
  
  // Reklam gösterim zamanını takip etmek için
  DateTime? _lastAdTime;
  // Reklamlar arası minimum süre (dakika)
  static const int _minimumMinutesBetweenAds = 2;

  void loadBannerAd({Function(BannerAd)? onAdLoaded}) {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
          onAdLoaded?.call(bannerAd!);
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner reklam yüklenemedi: $error');
          ad.dispose();
        },
      ),
    ).load();
  }

  void loadInterstitialAd({Function(InterstitialAd)? onAdLoaded}) {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          onAdLoaded?.call(interstitialAd!);
        },
        onAdFailedToLoad: (error) {
          print('Interstitial reklam yüklenemedi: $error');
        },
      ),
    );
  }

  void loadRewardedAd({Function(RewardedAd)? onAdLoaded}) {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          onAdLoaded?.call(rewardedAd!);
        },
        onAdFailedToLoad: (error) {
          print('Rewarded reklam yüklenemedi: $error');
        },
      ),
    );
  }

  // Reklam gösterilip gösterilemeyeceğini kontrol et
  bool canShowAd() {
    if (_lastAdTime == null) return true;
    
    final difference = DateTime.now().difference(_lastAdTime!);
    return difference.inMinutes >= _minimumMinutesBetweenAds;
  }

  // Reklam gösterim zamanını güncelle
  void _updateLastAdTime() {
    _lastAdTime = DateTime.now();
  }

  // Interstitial reklam gösterme fonksiyonu
  Future<bool> showInterstitialAd() async {
    if (!canShowAd()) {
      print('Reklam göstermek için çok erken. Kalan süre: ${_getRemainingTime()} dakika');
      return false;
    }

    if (interstitialAd == null) {
      print('Interstitial reklam yüklü değil');
      return false;
    }

    try {
      await interstitialAd!.show();
      loadInterstitialAd();
      return true;
    } catch (e) {
      print('Interstitial reklam gösterilirken hata: $e');
      return false;
    }
  }

  // Rewarded reklam gösterme fonksiyonu
  Future<bool> showRewardedAd() async {
    if(!canShowAd()) { return true;}
    print(canShowAd());
    if (rewardedAd == null) {
      print('Rewarded reklam yüklü değil');
      return false;
    }

    try {
      await rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _updateLastAdTime();
          print('Reklam izlendi! ${_minimumMinutesBetweenAds} dakika boyunca reklam gösterilmeyecek.');
        }
      );
      _updateLastAdTime();
      loadRewardedAd();
      return true;
    } catch (e) {
      print('Rewarded reklam gösterilirken hata: $e');
      return false;
    }
  }

  // Kalan süreyi hesapla
  String _getRemainingTime() {
    if (_lastAdTime == null) return '0';
    
    final difference = DateTime.now().difference(_lastAdTime!);
    final remainingMinutes = _minimumMinutesBetweenAds - difference.inMinutes;
    return remainingMinutes.toString();
  }

  void disposeAds() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
  }
} 