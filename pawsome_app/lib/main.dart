import 'package:flutter/material.dart';
//import 'screens/signin_screen.dart';
//import 'screens/new_account_screen.dart'; 

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, // Elrejti a debug bannert
//       home: Scaffold(
//         body: SigninWidget(),
//       ),
//     );
//   }
// 

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text(''),
//         ),
//         body: Center(
//           child: NewAccountWidget(), // Use the NewAccountWidget here
//         ),
//       ),
//     );
//   }
// }


import 'screens/login_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginWidget(), 
    );
  }
}