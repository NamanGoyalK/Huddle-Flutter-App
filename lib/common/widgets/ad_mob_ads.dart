import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  BannerAdWidgetState createState() => BannerAdWidgetState();
}

class BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      // adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test code
      adUnitId: 'ca-app-pub-8526773119793740/5045060690', // Production code
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
            _isAdFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) {
            print('Banner Ad failed to load: $error');
          }
          setState(() {
            _isAdLoaded = false;
            _isAdFailed = true;
          });
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isAdLoaded
            ? Container(
                alignment: Alignment.center,
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              )
            : _isAdFailed
                ? const Text('Advertisement')
                : const SizedBox(
                    height: 1,
                    width: 250,
                    child: LinearProgressIndicator(),
                  ),
      ],
    );
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }
}
