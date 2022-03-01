import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'gorev.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'urun.dart';
import 'package:fluttertoast/fluttertoast.dart';
class gecmisGorevler extends StatefulWidget {
  const gecmisGorevler({Key? key}) : super(key: key);

  @override
  _gecmisGorevlerState createState() => _gecmisGorevlerState();
}

FirebaseAuth auth = FirebaseAuth.instance;
final urunListesiReff = FirebaseFirestore.instance.collection('urunListesi');
List<gelen> gelenGorevList = [];
List<gorev> gorevList = [];
List<urun> urunListt = [];
bool ucusaGidebilirMi = true;
DateTime dt = new DateTime.now();
class _gecmisGorevlerState extends State<gecmisGorevler> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    setState(() {
      firebaseVeriOku();
      _firebaseUrunOku();
      gelenGorevList;
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    gorevList.clear();
    gelenGorevList.clear();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: gorevList.length != 0
            ? ListView.builder(itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  onDismissed: (direction) {
                    setState(() {
                      gorevList.removeAt(index);
                    });
                  },
                  key: Key(index.toString()),
                  child: Card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.map_outlined),
                            Text(
                                "Enlem : ${gorevList[index].enlem.toStringAsPrecision(6)} | Boylam : ${gorevList[index].boylam.toStringAsPrecision(7)}")
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },itemCount: gorevList.length,)
            : Text("Gorev bulunamadi"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(ucusaGidebilirMi == true){
            _agirlikKontrol();
            _firebaseGorevKaydet();
          }
          else{
            Fluttertoast.showToast(
                msg: "Taşınacak olan ürünlerin ağırlığı maksimum değerin üzerinde",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }

        },
        child: Icon(Icons.airplanemode_active),
      ),
      body: Container(
        child: gelenGorevList.length != 0
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _alertDialogOlustur(context, index);
                          });
                    },
                    child: Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.map_outlined),
                            Text(
                                "Enlem : ${double.parse(gelenGorevList[index]._enlem).toStringAsPrecision(7)} | Boylam : ${double.parse(gelenGorevList[index]._boylam).toStringAsPrecision(8)}")
                          ],
                        ),
                        subtitle: Column(
                          children: [
                            Text(
                                "Görev Başlama Tarihi : ${gelenGorevList[index]._gorevBaslangicTarihi}"),
                            Text(
                                "Görev Bitiş Tarihi : ${gelenGorevList[index]._gorevBitisTarihi}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: gelenGorevList.length,
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  firebaseVeriOku() async {
    Map<dynamic, dynamic> gelenMap = new Map();
    await FirebaseDatabase.instance
        .reference()
        .child('tamamlananGorevler')
        .child(auth.currentUser!.uid)
        .get()
        .then((DataSnapshot snapshot) => gelenMap = snapshot.value);
    debugPrint(gelenMap.toString());

    for (var data in gelenMap.values) {
      gelen g = new gelen(
          data['enlem'].toString(),
          data['boylam'].toString(),
          data['urunListesi'],
          data['gorevBitisTarihi'].toString(),
          data['gorevBaslangicTarihi'].toString());
      setState(() {
        gelenGorevList.add(g);
      });
    }
  }

  _alertDialogOlustur(BuildContext context, int index) {
    return AlertDialog(
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Text("Enlem : ${gelenGorevList[index]._enlem}"),
            Text("Boylam : ${gelenGorevList[index]._boylam}"),
            Text(
                "Görev Başlama Tarihi : ${gelenGorevList[index]._gorevBaslangicTarihi}"),
            Text(
                "Görev Bitiş Tarihi : ${gelenGorevList[index]._gorevBitisTarihi}"),
            Center(
              child: Text("Taşınan Ürünler"),
            ),
            Expanded(
                child: Container(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int indexx) {
                  return Card(
                    child: Text(
                        gelenGorevList[index]._urunListesi[indexx].toString()),
                  );
                },
                itemCount: gelenGorevList[index]._urunListesi.length,
              ),
            )),
            RaisedButton(

              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _gorevAlert(context, index);
                    });
              },
              child: Text("Görevi Tekrar Kullan"),
            ),
          ],
        ),
      ),
    );
  }
  _firebaseGorevKaydet() async {
    final reff =
    FirebaseDatabase.instance.reference().child('/').child('gorevler');
    int sayac = 0;
    for (gorev grv in gorevList) {
      List<String> urunListesi = [];
      for (int i = 0; i < grv.urunList.length; i++) {
        urunListesi.add(grv.urunList[i].urunAdi);
      }
      reff.child(sayac.toString()).set({
        'gorevOlusturmaTarihi': dt.toString(),
        'gorevBitisTarihi': "tamamlanmadi",
        'adres': grv.gorevID,
        'enlem': grv.enlem,
        'boylam': grv.boylam,
        'urunListesi': urunListesi,
        'kullaniciID':auth.currentUser!.uid.toString()
      });
      sayac++;
    }
    setState(() {
      gorevList.clear();
    });
    Fluttertoast.showToast(
        msg: "Görevler Yüklendi",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0)
        .whenComplete(() {
      Navigator.pushNamed(context, '/');
    });
  }

  _gorevAlert(BuildContext context, int index) {
    List<urun> missionUrunList = [];
    return AlertDialog(
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Text("Enlem : ${gelenGorevList[index]._enlem}"),
            Text("Boylam : ${gelenGorevList[index]._boylam}"),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.7,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int indexx) {
                    int adet = 0;
                    return Card(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Row(
                          children: [
                            Text(urunListt[indexx].urunAdi),
                            InkWell(
                              child: Icon(Icons.arrow_back_ios_outlined),
                              onTap: () {
                                double toplamAgirlik = 0;
                                for (urun u in missionUrunList){
                                  toplamAgirlik += u.urunAgirlik;
                                }
                                if(toplamAgirlik >= 5.0){
                                  ucusaGidebilirMi = false;
                                  Fluttertoast.showToast(
                                      msg: "Taşınabilecek maksimum ağırlığın üzerine çıktınız",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                }
                                if (adet > 0) {
                                  setState(() {
                                    adet = adet - 1;
                                    missionUrunList.remove(urunListt[index]);
                                  });
                                }
                              },
                            ),

                            InkWell(
                              child: Icon(Icons.arrow_forward_ios_outlined),
                              onTap: () {
                                double toplamAgirlik = 0;
                                for (urun u in missionUrunList){
                                  toplamAgirlik += u.urunAgirlik;
                                }
                                if(toplamAgirlik >= 5.0){
                                  ucusaGidebilirMi = false;
                                  Fluttertoast.showToast(
                                      msg: "Taşınabilecek maksimum ağırlığın üzerine çıktınız",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                }
                                _agirlikKontrol();
                                setState(() {
                                  adet = adet + 1;
                                  debugPrint(adet.toString());
                                  missionUrunList.add(urunListt[index]);
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: urunListt.length,
                ),
              ),
            ),
            RaisedButton(child: Text("Yükle"),onPressed: () {
              setState(() {
                gorev g = new gorev(
                    "qwerty",
                    double.parse(gelenGorevList[index]._enlem),
                    double.parse(gelenGorevList[index]._boylam),
                    missionUrunList);
                gorevList.add(g);
              });
              Navigator.of(context, rootNavigator: true).pop('dialog');
            }),
          ],
        ),
      ),
    );
  }
_agirlikKontrol(){
    double toplamAgirlik = 0;

    for(gorev g in gorevList){
      for(urun u in g.urunList){
        toplamAgirlik +=u.urunAgirlik;
      }
    }
  setState(() {
    if(toplamAgirlik >= 5)
      ucusaGidebilirMi = false;
    else
      ucusaGidebilirMi = true;
  });
}
  _firebaseUrunOku() async {
    await urunListesiReff.get().then((value) {
      for (var a in value.docs) {
        setState(() {
          urun u = new urun(a.id, a.data()['urunAdi'], a.data()['urunFiyat'],
              a.data()['urunAgirlik']);
          urunListt.add(u);
        });
      }
    });
    for (urun u in urunListt) {
      debugPrint(u.urunAdi + " " + u.urunID);
    }
  }
}

class gelen {
  String _enlem;
  String _boylam;
  List<dynamic> _urunListesi;
  String _gorevBitisTarihi;
  String _gorevBaslangicTarihi;

  gelen(this._enlem, this._boylam, this._urunListesi, this._gorevBitisTarihi,
      this._gorevBaslangicTarihi);

  String get gorevBaslangicTarihi => _gorevBaslangicTarihi;

  set gorevBaslangicTarihi(String value) {
    _gorevBaslangicTarihi = value;
  }

  String get gorevBitisTarihi => _gorevBitisTarihi;

  set gorevBitisTarihi(String value) {
    _gorevBitisTarihi = value;
  }

  List<dynamic> get urunListesi => _urunListesi;

  set urunListesi(List<dynamic> value) {
    _urunListesi = value;
  }

  String get boylam => _boylam;

  set boylam(String value) {
    _boylam = value;
  }

  String get enlem => _enlem;

  set enlem(String value) {
    _enlem = value;
  }
}
