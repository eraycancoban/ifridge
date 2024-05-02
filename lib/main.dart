import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/loginpage.dart'; // LoginPage sınıfının bulunduğu dosyayı import edin


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyDKaV6N_bfjfpw7r_ewytodStt49BvfjD0", 
    appId: "1:695463804507:web:6b6076b3c87c6f2ad7097e",
    messagingSenderId: "695463804507", 
    projectId: "fridge-b6fda"));
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // LoginPage'i ana sayfa olarak belirledik
    );
  }
}



