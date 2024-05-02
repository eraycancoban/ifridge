import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginpage.dart';
import 'chatscreengpt.dart';
import 'fridgelist.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfilePage extends StatelessWidget {
  final String? userId;
  final String? email;

  UserProfilePage({this.email, this.userId});

  Future<void> _deleteAccount(BuildContext context) async {
    // Silme işleminden önce kullanıcıya emin olup olmadığını sormak için bir dialog göster
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hesabı Sil'),
          content: Text(
              'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
          backgroundColor: Colors.white, // Dialog arka plan rengi
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: Text('İptal',
                  style: TextStyle(
                      color: Colors.blueGrey)), // İptal butonunun metin rengi
            ),
            TextButton(
              onPressed: () async {
                // Hesabı silme işlemi
                try {
                  await FirebaseAuth.instance.currentUser?.delete();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                } catch (e) {
                  print('Hesap silinirken hata oluştu: $e');
                  // Hata durumunda kullanıcıya bilgi vermek için bir dialog gösterilebilir
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Hata'),
                        content: Text('Hesap silinirken bir hata oluştu.'),
                        backgroundColor:
                            Colors.blueGrey, // Dialog arka plan rengi
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Tamam',
                                style: TextStyle(
                                    color: Colors
                                        .black)), // Tamam butonunun metin rengi
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Eminim',
                  style: TextStyle(
                      color: Colors.blueGrey)), // Eminim butonunun metin rengi
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Başarılı'),
            content: Text(
                'Şifre değiştirmek için email yollanmıştır.Lütfen kontrol ediniz.'),
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
    } catch (e) {
      print('Şifre değiştirme sırasında hata oluştu: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Şifre değiştirme sırasında hata oluştu'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kullanıcı',
          style: GoogleFonts.lora(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.chat, size: 24, color: Colors.white),
            onPressed: () {
              // Chat sayfasına yönlendirme
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChatGPTScreen(email: email, userId: userId)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.kitchen, size: 24, color: Colors.white),
            onPressed: () {
              // Not defteri sayfasına yönlendirme
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FridgeList(email: email, userId: userId)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, size: 24, color: Colors.white),
            onPressed: () {
              // Ayarlar sayfasına yönlendirme
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                        email: email,
                        userId: userId)), // FridgeList ekranına yönlendirme
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, size: 24, color: Colors.white),
            onPressed: () async {
              try {
                await FirebaseAuth.instance
                    .signOut(); // Firebase oturumu kapatılıyor
                // Oturum kapatıldıktan sonra giriş sayfasına yönlendirme yapılıyor
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } catch (e) {
                // Çıkış sırasında bir hata oluştu.
                print('Hata oluştu: $e');
                // Hata mesajını göstermek için bir dialog gösterilebilir
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Hata'),
                      content: Text('Çıkış yapılırken hata oluştu'),
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
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kullanıcı E-posta: $email',
              style: GoogleFonts.lora(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _deleteAccount(context),
              child: Text(
                'Hesabı sil',
                style: GoogleFonts.lora(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white, // Metin rengi
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey, // Arka plan rengi
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: Text(
                'Şifreyi değiştir',
                style: GoogleFonts.lora(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white, // Metin rengi
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey, // Arka plan rengi
              ),
            ),
          ],
        ),
      ),
    );
  }
}
