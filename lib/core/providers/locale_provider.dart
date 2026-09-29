import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Locale provider to manage locale state
/// use setLocale to change locale

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // from Shared preferences get saved locale if exists else default to System locale
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  /// setLocale to change locale
  void setLocale(Locale locale) {
    state = locale;
  }
}

/// locale provider instance
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});
