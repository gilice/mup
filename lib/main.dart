import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_used_pots/constants.dart';
import 'package:my_used_pots/log_all_observer.dart';
import 'package:my_used_pots/screens/home_screen.dart';

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
      brightness: inp.brightness,
      cardColor: inp.surface,
      dialogTheme: DialogTheme(
          backgroundColor: inp.surface,
          contentTextStyle: GoogleFonts.dmSans(color: inp.onSurface)),
      textTheme: GoogleFonts.dmSansTextTheme()
          .apply(bodyColor: inp.onBackground, displayColor: inp.onBackground));
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
                title: appDisplayName,
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
