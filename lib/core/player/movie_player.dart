import 'dart:developer';
import 'dart:io';
import 'package:easy_web_view/easy_web_view.dart';
import 'package:flixstar/api/api.dart';

import 'package:flixstar/injection_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:startapp_sdk/startapp.dart';

class MoviePlayer extends StatefulWidget {
  final int id;
  const MoviePlayer({super.key, required this.id});

  @override
  State<MoviePlayer> createState() => _WebVideoPlayerState();
}

// Comment
//

class _WebVideoPlayerState extends State<MoviePlayer> {
  StartAppInterstitialAd? _interstitialAd;
  final startApp = sl<StartAppSdk>();
  String source = '';

  @override
  void initState() {
    final api = sl<API>();
    source = api.getMovieSource(widget.id);
    _createInterstitialAd();

    super.initState();
  }

  void _createInterstitialAd() {
    if (!kIsWeb && !Platform.isWindows) {
      startApp.loadInterstitialAd().then((ad) {
        setState(() {
          _interstitialAd = ad;
        });
      }).onError((ex, stackTrace) {
        _interstitialAd = null;
        debugPrint("Error Loading Interstitial Ad: $ex");
      });
    }
  }

  void _showInterstitialAd() {
    if (!kIsWeb) {
      if (!Platform.isWindows) {
        if (_interstitialAd == null) {
          log('Warning: attempt to show interstitial before loaded.');
          return;
        }
        if (_interstitialAd != null) {
          _interstitialAd!.show().then((shown) {
            if (shown) {
              setState(() {
                // NOTE interstitial ad can be shown only once
                _interstitialAd = null;

                // NOTE load again
                _createInterstitialAd();
              });
            }

            return null;
          }).onError((error, stackTrace) {
            debugPrint("Error showing Interstitial ad: $error");
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Reset orientation and UI mode
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set immersive mode for video playback
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return WillPopScope(
      onWillPop: () async {
        // Reset orientation and UI mode on back navigation
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: buildEZWV(context, source),
    );
  }
}

EasyWebView buildEZWV(BuildContext context, String url) {
  log('Current URL is: $url');
  return EasyWebView(
    src: url,
    width: context.height,
    height: context.width,
    options: WebViewOptions(
      navigationDelegate: (WebNavigationRequest request) {
        return WebNavigationDecision.prevent;
      },
      browser: BrowserWebViewOptions(
        allowFullScreen: true,
        allow: 'autoplay; fullscreen; encrypted-media',
      ),
    ),
  );
}
