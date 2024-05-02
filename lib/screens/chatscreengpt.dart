import 'dart:convert';
import 'api_key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'loginpage.dart';
import 'userprofile.dart';
import 'fridgelist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatGPTScreen extends StatefulWidget {
  final String? userId;
  final String? email; // E-posta değişkeni eklendi
  const ChatGPTScreen({this.email, this.userId});
  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
  final List<Message> _messages = [];

  final TextEditingController _textEditingController = TextEditingController();

  void onSendMessage() async {
    Message message = Message(text: _textEditingController.text, isMe: true);

    _textEditingController.clear();

    setState(() {
      _messages.insert(0, message);
    });

    String response = await sendMessageToChatGpt(message.text);

    Message chatGpt = Message(text: response, isMe: false);

    setState(() {
      _messages.insert(0, chatGpt);
    });
  }

  Future<String> sendMessageToChatGpt(String message) async {
    Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": message}
      ],
      "max_tokens": 500,
    };

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${APIKey.apiKey}",
      },
      body: json.encode(body),
    );

    print(response.body);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> parsedReponse = json.decode(responseBody);

    String reply = parsedReponse['choices'][0]['message']['content'];

    return reply;
  }

  Widget _buildMessage(Message message) {
    // Konuşma balonları için rengin, widget sınırlarını doldurduğundan emin olun
    BoxDecoration decoration = BoxDecoration(
      color: message.isMe ? Colors.blue.shade50 : Colors.green.shade50,
      borderRadius: BorderRadius.circular(30),
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: decoration,
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.isMe ? 'Siz' : 'GPT',
            style: GoogleFonts.lora(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: message.isMe ? Colors.blue : Colors.green,
              ),
            ),
          ),
          Text(
            message.text,
            style: GoogleFonts.lora(
              textStyle: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yemek Önerileri',
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatGPTScreen(email: widget.email, userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.kitchen, size: 24, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FridgeList(email: widget.email, userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, size: 24, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                        email: widget.email, userId: widget.userId)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, size: 24, color: Colors.white),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              } catch (e) {
                print('Hata oluştu: $e');
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Hata'),
                      content: Text('Çıkış sırasında bir hata oluştu.'),
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
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/fridge.png'), 
          fit: BoxFit.cover,
        ),
      ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50, // Burayı kontrol et
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        hintText: 'Mesajını yaz...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      // Öğün seçenekleri için bir dialog göster
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Öğün Seç'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Text('Kahvaltı'),
                                    onTap: () {
                                      Navigator.pop(context, 'Kahvaltı');
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.all(8.0)),
                                  GestureDetector(
                                    child: Text('Öğle Yemeği'),
                                    onTap: () {
                                      Navigator.pop(context, 'Öğle Yemeği');
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.all(8.0)),
                                  GestureDetector(
                                    child: Text('Akşam Yemeği'),
                                    onTap: () {
                                      Navigator.pop(context, 'Akşam Yemeği');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ).then((selectedMeal) async {
                        if (selectedMeal != null) {
                          // Firestore'dan ilgili kullanıcının buzdolabı belgesindeki öğeleri alın
                          try {
                            final snapshot = await FirebaseFirestore.instance
                                .collection('fridge')
                                .doc(widget.userId)
                                .collection('items')
                                .get();

                            // Belge varsa ve öğe varsa işleme devam edin
                            if (snapshot.docs.isNotEmpty) {
                              // Kullanıcının buzdolabında bulunan öğelerin listesini oluşturun
                              List<String> items = snapshot.docs
                                  .map((doc) => doc.data()['name'].toString())
                                  .toList();

                              // Malzemeleri chat GPT'ye gönder
                              for (String item in items) {
                                String response = await sendMessageToChatGpt(
                                    'Elimde bu malzemeler var: $item.$selectedMeal için öneilerde bulunabilir misin?.Cevabında türkçe karakterler kullanma.');
                                Message chatGpt =
                                    Message(text: response, isMe: false);
                                setState(() {
                                  _messages.insert(0, chatGpt);
                                });
                              }
                            } else {
                              // Buzdolabı boşsa kullanıcıya bilgi verin
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Buzdolabınız Boş'),
                                    content: Text(
                                        'Buzdolabınızda hiçbir öğe bulunmuyor.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Anladım'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            print('Hata oluştu: $e');
                            // Hata mesajını göstermek için bir dialog gösterilebilir
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text(
                                      'An error occurred while fetching fridge items.'),
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
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: onSendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}
