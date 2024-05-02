import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userprofile.dart';
import 'loginpage.dart';
import 'chatscreengpt.dart';
import 'package:google_fonts/google_fonts.dart';

class Item {
  String name;
  int quantity;
  String unit;

  Item({required this.name, required this.quantity, required this.unit});
}

class FridgeList extends StatefulWidget {
  final String? userId;
  final String? email;

  const FridgeList({Key? key, this.userId, this.email}) : super(key: key);

  @override
  _FridgeListState createState() => _FridgeListState();
}

class _FridgeListState extends State<FridgeList> {
  final List<String> categories = [
    'Meyve',
    'Sebze',
    'Süt Ürünleri',
    'Et Ürünleri',
    'Baklagiller'
  ];

  final Map<String, List<Item>> itemsByCategory = {
    'Meyve': [],
    'Sebze': [],
    'Süt Ürünleri': [],
    'Et Ürünleri': [],
    'Baklagiller': [],
  };

  String? selectedCategory;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buzdolabım', 
          style: GoogleFonts.lora(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        leading: null, // Geri dönüş işaretini kaldırma 
        backgroundColor: Colors.blueGrey, 
        actions: [
          IconButton(
           icon: Icon(Icons.chat, size: 24, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatGPTScreen(email: widget.email, userId: widget.userId),
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
                  builder: (context) => FridgeList(email: widget.email, userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, size: 24,color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(email: widget.email, userId: widget.userId)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, size: 24,color: Colors.white),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              } catch (e) {
                print('Hata oluştu: $e');
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Hata'),
                      content: Text('Çıkış Yap '),
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('fridge').doc(widget.userId).collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<dynamic> firestoreItems = snapshot.data!.docs;
          itemsByCategory.forEach((category, itemList) {
            itemList.clear();
          });
          firestoreItems.forEach((itemData) {
            final String category = itemData['category'];
            final String name = itemData['name'];
            final int quantity = itemData['quantity'];
            final String unit = itemData['unit'];
            itemsByCategory[category]!.add(Item(name: name, quantity: quantity, unit: unit));
          });

          return Container(
  margin: EdgeInsets.fromLTRB(
    MediaQuery.of(context).size.width * 0.01, // Sol kenar
    MediaQuery.of(context).size.width * 0.01, // Üst kenar
    MediaQuery.of(context).size.width * 0.01, // Sağ kenar
    MediaQuery.of(context).size.width * 0.01, // Alt kenar (%2 margin)
  ),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.black),
    borderRadius: BorderRadius.circular(12), // Category'lere border radius uygulandı
  ),
  padding: EdgeInsets.all(8), // Kenar boşluğu ekledik
  child: ListView.builder(
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      final items = itemsByCategory[category]!;
      
        return Padding(
          padding: EdgeInsets.only(bottom: 8), // Listenin altına 8 piksel boşluk ekledik
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(category),
                tileColor: _getCategoryColor(category),
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                trailing: Text('${items.length} ürün'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // ListTile'lara da border radius uygulandı
                ),
              ),
              if (selectedCategory == category)
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(left: 16), // Liste içindeki öğeleri içeriye doğru 16 piksel kaydırdık
                    child: ListTile(
                      leading: Icon(Icons.circle, size: 8),
                      title: Row(
                        children: [
                          Expanded(child: Text('${item.name} - ${item.quantity} ${item.unit}')),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteItemFromListAndFirestore(category, item.name);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
    },
  ),
);

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedCategory == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lütfen bir kategori seçin')),
            );
            return;
          }
          _showAddItemDialog(context);
        },
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: const Color.fromARGB(255, 132, 170, 189),
      ),
    );
  }
Color _getCategoryColor(String category) {
  switch (category) {
    case 'Meyve':
      return Colors.deepPurple.shade100; // Daha derin bir mor tonu
    case 'Sebze':
      return Colors.teal.shade100; // Yumuşak bir turkuaz tonu
    case 'Süt Ürünleri':
      return Colors.orange.shade100; // Turuncu tonu süt ürünleri için
    case 'Et Ürünleri':
      return Colors.pink.shade100; // Hafif pembe
    case 'Baklagiller':
      return Colors.lightBlue.shade100; // Hafif mavi tonu
    default:
      return Colors.grey.shade200; // Daha nötr bir seçenek
  }
}

  void _showAddItemDialog(BuildContext context) {
    final selected = selectedCategory ?? categories.first;
    String itemName = '';
    int quantity = 0;
    String unit = 'Adet';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yeni Öğe Ekle - $selected'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    itemName = value;
                  },
                  decoration: InputDecoration(labelText: 'Ürün Adı'),
                ),
                TextField(
                  onChanged: (value) {
                    quantity = int.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(labelText: 'Miktar'),
                ),
                DropdownButton<String>(
                  value: unit,
                  onChanged: (String? newValue) {
                    setState(() {
                      unit = newValue!;
                    });
                  },
                  items: <String>['Adet', 'Kilogram', 'Litre']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  itemsByCategory[selected]!.add(Item(name: itemName, quantity: quantity, unit: unit));
                });
                _addItemToFirestore(selected, itemName, quantity, unit);
                Navigator.of(context).pop();
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        selectedCategory = null;
      });
    });
  }

  void _addItemToFirestore(String category, String itemName, int quantity, String unit) async {
    try {
      await _firestore.collection('fridge').doc(widget.userId).collection('items').doc().set({
        'category': category,
        'name': itemName,
        'quantity': quantity,
        'unit': unit,
      });
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  void _deleteItemFromListAndFirestore(String category, String itemName) async {
    setState(() {
      itemsByCategory[category]!.removeWhere((item) => item.name == itemName);
    });
    try {
      await _firestore
          .collection('fridge')
          .doc(widget.userId)
          .collection('items')
          .where('category', isEqualTo: category)
          .where('name', isEqualTo: itemName)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }
}
