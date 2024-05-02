import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ifridge/screens/loginpage.dart'; // LoginPage sınıfının bulunduğu dosyayı import edin
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  Future<void> _signUpWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Başarılı'),
            content: Text('Kullanıcı başarı ile kayot oldu'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
      print('Kullanıcı başarı ile kayot oldu: ${userCredential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'zayıf şifre') {
        _showErrorDialog(context, 'Bu şifre çok zayıf');
      } else if (e.code == 'Email kullanılmakta') {
        _showErrorDialog(context, 'Bu mail ile başka bir hesaba sahibiz.');
      } else {
        _showErrorDialog(context, e.message ?? 'Kayıt olurken hata oluştu.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Kayıt olurken hata oluştu.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = ''; // email değişkenini tanımlayın
    String password = ''; // password değişkenini tanımlayın
    String confirmPassword = ''; // confirmPassword değişkenini tanımlayın

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const SizedBox(height: 60.0),
                    const Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Hesap Oluştur",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none),
                          fillColor: Colors.blueGrey.withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.email)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Şifre",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: Colors.blueGrey.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) {
                        confirmPassword = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Şifreyi tekrar yaz",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: Colors.blueGrey.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: ElevatedButton(
                    onPressed: () {
                      // Şifrelerin eşleşip eşleşmediğini kontrol edin
                      if (password != confirmPassword) {
                        _showErrorDialog(context, 'Şifre eşleşmiyor');
                      } else {
                        // Şifreler eşleşiyorsa kayıt işlemini gerçekleştirin
                        _signUpWithEmailAndPassword(email, password, context);
                      }
                    },
                    child: Text(
                      'Kayıt Ol',
                      style: GoogleFonts.lora(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueGrey,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Zaten hesabın var mı?",
                      style: TextStyle(
                          fontSize:
                              20), // Bu satırda parantez düzgün şekilde kapatılmış
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        "Giriş",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize:
                              20, // Bu satırda da kapatma parantezi doğru yerde
                        ),
                      ),
                    ),
                  ],
                ), // Kapanış parantezi için ekstra kontrol
              ],
            ),
          ),
        ),
      ),
    );
  }
}
