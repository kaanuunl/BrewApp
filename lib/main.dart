import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'screens/startup_screen.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final useTurkishFormatting =
      deviceLocale.languageCode.toLowerCase() == 'tr' ||
      deviceLocale.countryCode?.toUpperCase() == 'TR';
  Intl.defaultLocale = useTurkishFormatting ? 'tr_TR' : 'en_US';
  runApp(const BrewApp());
}

class BrewApp extends StatelessWidget {
  const BrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Brew App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            supportedLocales: const [Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            locale: const Locale('en'),
            home: FutureBuilder<void>(
              future: state.ready,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return StartupErrorScreen(error: snapshot.error!);
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const StartupScreen();
                }
                return const HomeScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
