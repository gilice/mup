import 'dart:developer';

import 'package:MyUsedPots/screens/home_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const MyApp());
}

final themeModeProvider = StateProvider<ThemeMode>(
  (ref) {
    return ThemeMode.system;
  },
);

ThemeData themeFromColorScheme(ColorScheme inp) {
  return ThemeData(
      useMaterial3: true,
      appBarTheme: AppBarTheme(foregroundColor: inp.onBackground),
      dialogBackgroundColor: inp.surface,
      colorScheme: inp,
      cardColor: inp.surface,
      dialogTheme: DialogTheme(backgroundColor: inp.surface),
      textTheme: GoogleFonts.dmSansTextTheme());
}

class LogAllObserver implements ProviderObserver {
  @override
  void didAddProvider(
      ProviderBase provider, Object? value, ProviderContainer container) {
    log("provider added: ${provider.name ?? provider.runtimeType}, value: $value");
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer containers) {
    log("provider disposed: ${provider.name ?? provider.runtimeType}");
  }

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue,
      Object? newValue, ProviderContainer container) {
    log("provider updated: ${provider.name ?? provider.runtimeType}, previous: $previousValue, new: $newValue");
  }

  @override
  void providerDidFail(ProviderBase provider, Object error,
      StackTrace stackTrace, ProviderContainer container) {
    log("provider failed: ${provider.name ?? provider.runtimeType}, error: $error, stack: $stackTrace");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // On Android S+ devices, use the provided dynamic color scheme.
          lightColorScheme = lightDynamic.harmonized();

          // Repeat for the dark color scheme.
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Otherwise, use fallback schemes.
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ).harmonized();
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ).harmonized();
        }
        return ProviderScope(
          observers: kDebugMode ? [LogAllObserver()] : null,
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return MaterialApp(
                title: 'Flutter Demo',
                themeMode: ref.watch(themeModeProvider),
                theme: themeFromColorScheme(lightColorScheme),
                darkTheme: themeFromColorScheme(darkColorScheme),
                home: const HomeScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
