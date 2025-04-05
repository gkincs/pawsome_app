import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/auth_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'package:pawsome_app/repositories/user_repository.dart';
import 'package:pawsome_app/screens/main_screen.dart';
import 'package:pawsome_app/screens/signin_screen.dart';
import 'package:pawsome_app/screens/first_step_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'services/language_service.dart';

// Az alkalmazás belépési pontja.
/// Inicializálja a Firebase-t, beállítja a Bloc és Provider állapotkezelést,
///Kezeli az alkalmazás életciklusát és a nyelvi beállításokat.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Pawsome());
}

/// A Pawsome osztály az alkalmazás gyökér widgetje.
class Pawsome extends StatefulWidget {
  const Pawsome({super.key});

  @override
  State<Pawsome> createState() => _PawsomeState();
}

class _PawsomeState extends State<Pawsome> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Amikor az alkalmazás visszatér a háttérből
      final authBloc = context.read<AuthBloc>();
      if (authBloc.state.user != null) {
        // Ha a felhasználó be van jelentkezve, frissítjük az állapotot
        authBloc.add(CheckAuthStatus());
      }
    }
  }

 /// Ha az alkalmazás visszatér a háttérből, ellenőrzi a felhasználó hitelesítési állapotát.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(UserRepository()),
        ),
        BlocProvider<BottomNavigationBloc>(
          create: (context) => BottomNavigationBloc(),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => LanguageService(),
        child: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF65558F)),
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                  ),
                ),
              ),
              locale: languageService.currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('hu'),
              ],
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state.user == null) {
                    return const SigninWidget();
                  }
                  if (state.isFirstLogin) {
                    return const FirststepWidget();
                  }
                  return MainScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}