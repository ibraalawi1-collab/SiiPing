import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

class LanguageProvider extends Notifier<Locale> {
  @override
  Locale build() {
    return _getDefaultLocale();
  }

  Locale _getDefaultLocale() {
    // Basic auto-detect logic.
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == 'ar') {
      return const Locale('ar', 'SA');
    }
    return const Locale('en', 'US');
  }

  void toggleLanguage() {
    if (state.languageCode == 'en') {
      state = const Locale('ar', 'SA');
    } else {
      state = const Locale('en', 'US');
    }
  }
}

final languageProvider = NotifierProvider<LanguageProvider, Locale>(LanguageProvider.new);
