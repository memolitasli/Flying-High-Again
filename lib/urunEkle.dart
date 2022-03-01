import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'urun.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class urunEkle extends StatefulWidget {
  const urunEkle({Key? key}) : super(key: key);

  @override
  _urunEkleState createState() => _urunEkleState();
}

String _urunAdi = "";
double _urunFiyat = 0.0;
double _urunAgirlik = 0.0;
List<urun> urunList = [];
List<String> uuidList =[];

final urunListesiReff = FirebaseFirestore.instance.collection('urunListesi');

class _urunEkleState extends State<urunEkle> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseUrunOku();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Ürün Ekleme Sayfası"),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.deepPurple, Colors.amber])),
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.deepPurpleAccent])),
              //color: Colors.lightBlue,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: "Ürün Adı",prefixIcon: Icon(Icons.no_drinks_sharp)),
                    onChanged: (value) {
                      setState(() {
                        _urunAdi = value;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Ürün Fiyat",prefixIcon: Icon(Icons.money_off)),
                    onChanged: (value) {
                      setState(() {
                        _urunFiyat = double.parse(value);
                      });
                    },
                  ),
                  TextField(
                      decoration: InputDecoration(hintText: "Ürün Ağırlık",prefixIcon: Icon(Icons.add_shopping_cart)),
                      onChanged: (value) {
                        setState(() {
                          _urunAgirlik = double.parse(value);
                        });
                      }),
                  RaisedButton(
                    onPressed: () {
                      firebaseUrunEkle(_urunAdi, _urunAgirlik, _urunFiyat);
                    },
                    child: Text("Yükle"),
                  ),
                ],
              ),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("urunListesi")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> querySnapshot) {
                if (querySnapshot.hasError) {
                  return Text("Hata oluştu");
                }
                if (querySnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  final list = querySnapshot.data!.docs;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){
                          showDialog(context: context, builder: (BuildContext context){
                            return _alertDialog(context,index,list);
                          });

                        },
                        child: Card(
                          child: ListTile(
                            title: Text(list[index]['urunAdi']),
                            subtitle: Row(children: [
                              Text("${list[index]['urunFiyat']} TL | "),
                              Text("${list[index]['urunAgirlik']} Kg"),
                            ],),
                          ),
                        ),
                      );
                    },
                    itemCount: list.length,
                  );
                }
              },
            ))
          ],
        ),
      ),
    );
  }
_alertDialog(BuildContext context,int index,var liste){
    String yeniisim = liste[index]['urunAdi'];
    double yeniFiyat = liste[index]['urunFiyat'];
    double yeniAgirlik = liste[index]['urunAgirlik'];
    return AlertDialog(
      content: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: liste[index]['urunAdi'].toString(),
            ),
            onChanged: (deger){
              yeniisim = deger;
            },
          ),
          TextField(keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText:"Fiyat : "+liste[index]['urunFiyat'].toString(),
            ),
            onChanged: (deger){
              yeniFiyat = double.parse(deger);
            },
          ),
          TextField(keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Ağırlık : " + liste[index]['urunAgirlik'].toString(),
            ),
            onChanged: (deger){
              yeniAgirlik = double.parse(deger);
            },
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,children: [
            RaisedButton.icon(onPressed:(){
              Map<String,dynamic> urunMap = new Map();

             urunMap['urunAdi'] = yeniisim;
             urunMap['urunFiyat'] = yeniFiyat;
             urunMap['urunAgirlik'] = yeniAgirlik;
             urunGuncelle(urunMap, index);

            } , icon: Icon(Icons.upload_rounded), label: Text("Güncelle")),
            new Spacer(),
            RaisedButton.icon(onPressed:()async{
              await urunListesiReff.doc(uuidList[index]).delete().then((value){
                Fluttertoast.showToast(
                    msg: "Ürün Silindi",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                  Navigator.pushNamed(context, '/urunEkle');
              });
            } , icon: Icon(Icons.delete), label: Text("Sil")),
          ],)
        ],
      ),
    );
}
urunGuncelle(Map<String,dynamic> urun,int index)async{
  await urunListesiReff.doc(uuidList[index].toString()).update(urun).then((value){
    Fluttertoast.showToast(
        msg: "Ürün Güncellendi",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

  });
}
  firebaseUrunOku() async {
    await urunListesiReff.get().then((value) {
      debugPrint(value.docs.asMap().keys.toString());
      for (var a in value.docs) {

        setState(() {
          urun u = new urun(a.id, a.data()['urunAdi'], a.data()['urunFiyat'],
              a.data()['urunAgirlik']);
          debugPrint(a.id.toString());
          uuidList.add(a.id);
          urunList.add(u);
        });
      }
    });
    for (urun u in urunList) {
      debugPrint(u.urunAdi + " " + u.urunID);
    }
  }
}

firebaseUrunEkle(String urunAdi, double urunAgirlik, double urunFiyat) async {
  Map<String, dynamic> urunMap = Map<String, dynamic>();
  urunMap['urunAdi'] = urunAdi;
  urunMap['urunAgirlik'] = urunAgirlik;
  urunMap['urunFiyat'] = urunFiyat;
  await urunListesiReff.add(urunMap).then((value) => debugPrint("basarili"));
}
