import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Pawsome());
}

class Pawsome extends StatelessWidget {
  const Pawsome({super.key});

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