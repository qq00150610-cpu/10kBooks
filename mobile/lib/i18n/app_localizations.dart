import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  static const LocalizationsDelegate<dynamic> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
  ];
  
  static String getString(BuildContext context, String key) {
    return key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<dynamic> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en', 'ja', 'ko'].contains(locale.languageCode);
  }

  @override
  dynamic load(Locale locale) {
    return {};
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

const List<Locale> supportedLocales = [
  Locale('zh', 'CN'),
  Locale('en', 'US'),
  Locale('ja', 'JP'),
  Locale('ko', 'KR'),
];
