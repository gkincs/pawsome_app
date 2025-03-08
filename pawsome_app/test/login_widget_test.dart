import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawsome_app/screens/login_screen.dart';

void main() {
  testWidgets('LoginWidget displays login fields and button', (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        home: LoginWidget(),
      ),
    );

    expect(find.text('Login to your account'), findsOneWidget);

    // Email és password mezők láthatóak-e
    expect(find.byType(TextField), findsNWidgets(2)); // Két TextField van: Email és Password

    // Login gomb látható-e
    expect(find.byType(ElevatedButton), findsOneWidget);

    // "Forgot password?" gomb látható-e
    expect(find.text('Forgot password?'), findsOneWidget);

    //a"Don't have an account? Sign up" szöveg és gomb látható-e
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('Typing into email and password fields', (WidgetTester tester) async {
    // LoginWidget betöltése
    await tester.pumpWidget(
      MaterialApp(
        home: LoginWidget(),
      ),
    );

    // Keresés az email TextField-en
    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);

    // Email és jelszó beírás
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.pump(); // Várunk, hogy a változások érvényesüljenek

    // A beírt értékek megfelelőek-e
    expect(find.byType(TextField).evaluate().first.widget, isA<TextField>().having((t) => t.controller?.text, 'email text', 'test@example.com'));
    expect(find.byType(TextField).evaluate().last.widget, isA<TextField>().having((t) => t.controller?.text, 'password text', 'password123'));
  });
}
