import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signuppage.dart';
import 'fridgelist.dart'; // Yeni ekledik
import 'passwordpage.dart'; // Yeni ekledik
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );
      String userId = _getUserId(userCredential.user!);
      String email = _usernameController.text; // E-posta adresini al

      // Giriş başarılı oldu, yönlendirme yapılıyor
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FridgeList(
                userId: userId,
                email:
                    email)), // FridgeList ekranına yönlendirme, email de ekleniyor
      );
      print('Kullanıcı başarıyla giriş yaptı: $userId');
    } catch (e) {
      // Giriş sırasında bir hata oluştu.
      print('Hata oluştu: $e');
      // Hata mesajını göstermek için bir dialog gösterilebilir
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while signing in.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  String _getUserId(User user) {
    return user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(),
            _inputField(),
            _loginButton(context),
            _loginOptions(context),
            _signup(context),
          ],
        ),
      ),
    );
  }

Widget _header() {
  return Column(
    children: [
      Text(
        'iFridge',
        style: GoogleFonts.lora(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Colors.blueGrey,
          ),
        ),
      ),
      Text(
        
        "Ne yesem diyenler için",
        style: GoogleFonts.lora(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
               ),
        ), // İsteğe bağlı olarak stil ekleyebilirsiniz
      ),
    ],
  );
}


  Widget _inputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blueGrey.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Şifre",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blueGrey.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _loginOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
            );
          },
          child:  Text('Şifremi unuttum',
        style: GoogleFonts.lora(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueGrey,
          ),
        ),
      ),
        ),
      ],
    );
  }

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _signInWithEmailAndPassword(context);
      },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blueGrey,
        // Make the button span the width of the screen
        minimumSize: Size(double.infinity, 48),
      ),
      child:  Text(
      'Giriş',
        style: GoogleFonts.lora(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Hesabınız yok mu?',
        style: GoogleFonts.lora(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
      ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupPage()),
            );
          },
          child:  Text(
          'Kayıt Olun',
        style: GoogleFonts.lora(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueGrey,
          ),
        ),
      ),
        ),
      ],
    );
  }
}
