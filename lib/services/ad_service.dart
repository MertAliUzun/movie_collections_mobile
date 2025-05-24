import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../sup/adHelper.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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
  static const int _minimumMinutesBetweenAds = 7;

  // Reklam sayacını ayarla
  void setAdCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ad_counter', value);
  }

  // Reklam sayacını al
  Future<int> getAdCounter()async {
    final prefs = await SharedPreferences.getInstance(); 
    return prefs.getInt('ad_counter') ?? 0;
  }

  // Reklam sayacını artır
  void incrementAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int adCounter = (prefs.getInt('ad_counter') ?? 0) + 1;
    await prefs.setInt('ad_counter', adCounter);
  }

  // Reklam sayacını sıfırla
  void resetAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ad_counter', 0);
  }

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
          //print('Banner reklam yüklenemedi: $error');
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
          //print('Interstitial reklam yüklenemedi: $error');
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
          //print('Rewarded reklam yüklenemedi: $error');
        },
      ),
    );
  }

  // Reklam gösterilip gösterilemeyeceğini kontrol et
  Future<bool> canShowAd() async {
    final prefs = await SharedPreferences.getInstance(); 
    int adCounter = prefs.getInt('ad_counter') ?? 0;
    return adCounter >= 20;
  }

  // Reklam gösterim zamanını güncelle
  void _updateLastAdTime() {
    _lastAdTime = DateTime.now();
  }

  // Interstitial reklam gösterme fonksiyonu
  Future<bool> showInterstitialAd() async {
    if (await _isPremium()) {
      return true; // Premium kullanıcılara reklam gösterme
    }

    if (!(await canShowAd())) {
      incrementAdCounter();
      return false;
    }

    if (interstitialAd == null) {
      //print('Interstitial reklam yüklü değil');
      return false;
    }

    try {
      await interstitialAd!.show();
      resetAdCounter();
      loadInterstitialAd();
      return true;
    } catch (e) {
      //print('Interstitial reklam gösterilirken hata: $e');
      return false;
    }
  }

  Future<bool> _isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
  }

  // Rewarded reklam gösterme fonksiyonu
  Future<bool> showRewardedAd() async {
    return false;
    if (await _isPremium()) {
      return true; // Premium kullanıcılara reklam gösterme
    }

    if (!(await canShowAd())) {
      incrementAdCounter();
      return false;
    }

    if (rewardedAd == null) {
      //print('Rewarded reklam yüklü değil');
      return false;
    }

    try {
      await rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _updateLastAdTime();
          resetAdCounter();
          //print('Reklam izlendi! ${_minimumMinutesBetweenAds} dakika boyunca reklam gösterilmeyecek.');
        }
      );
      _updateLastAdTime();
      loadRewardedAd();
      return true;
    } catch (e) {
      //print('Rewarded reklam gösterilirken hata: $e');
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

  Future<Widget> showBannerAd(bool isTablet) async {
  if (await _isPremium()) {
    return const SizedBox.shrink(); // Premium kullanıcılara reklam gösterme
  }

  final Completer<BannerAd> completer = Completer();

  final BannerAd newBannerAd = BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (ad) {
        completer.complete(ad as BannerAd);
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        completer.completeError(error);
      },
    ),
  );

  newBannerAd.load();

  try {
    final BannerAd loadedAd = await completer.future;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: isTablet
            ? loadedAd.size.width.toDouble() * 1.5
            : loadedAd.size.width.toDouble(),
        height: isTablet
            ? loadedAd.size.height.toDouble() * 1.5
            : loadedAd.size.height.toDouble(),
        child: AdWidget(ad: loadedAd),
      ),
    );
  } catch (e) {
    return const SizedBox.shrink();
  }
}


  void disposeAds() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
  }
} 