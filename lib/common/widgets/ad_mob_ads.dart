import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  BannerAdWidgetState createState() => BannerAdWidgetState();
}

class BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    setState(() {
      _bannerAd = BannerAd(
        // adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test code
        adUnitId: 'ca-app-pub-8526773119793740/2805910163', // Production code
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _isAdLoaded && _bannerAd != null
            ? Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Builder(
                  builder: (context) {
                    // Calculate responsive border radius based on ad height
                    final adHeight = _bannerAd!.size.height.toDouble();
                    final borderRadius = (adHeight * 0.08).clamp(4.0, 12.0);

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius - 1.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : _isAdFailed
                ? const SizedBox(
                    height: 0.1,
                    width: 20,
                    child: SizedBox.shrink(),
                  )
                : SizedBox(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
      ],
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
