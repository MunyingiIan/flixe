import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flixstar/core/const/const.dart';
import 'package:flixstar/core/const/constants.dart';
import 'package:flutter/foundation.dart';

Future<void> fetchFirebaseData() async {
  if (!kIsWeb && !Platform.isWindows) {
    try {
      final db = FirebaseFirestore.instance;
      final ref = await db.collection('config').doc('settings').get();

      if (!ref.exists) {
        log('Firebase config document does not exist. Using defaults.');
        // Create the document with default values
        await db.collection('config').doc('settings').set({
          'streamMode': true,
          'showAds': false,
          'forceUpdate': false,
          'vidsrc_base': 'https://vidsrc.pm',
        });
      }

      final settings = ref.data() ?? {};
      log('Firebase settings: $settings');

      // Use null-safe access with defaults
      streamMode = settings['streamMode'] ?? true;
      showAds = settings['showAds'] ?? false;
      forceUpdate = settings['forceUpdate'] ?? false;
      vidSrcBaseUrl = settings['vidsrc_base'] ?? 'https://vidsrc.pm';

      log('Configured with: streamMode=$streamMode, showAds=$showAds, forceUpdate=$forceUpdate, vidSrcBaseUrl=$vidSrcBaseUrl');
    } catch (e) {
      log('Error fetching Firebase data: $e');
      // Set default values if Firebase fetch fails
      streamMode = true;
      showAds = false;
      forceUpdate = false;
      vidSrcBaseUrl = 'https://vidsrc.pm';
    }
  }
}
