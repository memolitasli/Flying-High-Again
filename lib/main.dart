import 'dart:convert';
import 'package:odev/gecmisGorevler.dart';
import 'package:odev/urunEkle.dart';
import 'urun.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_controller/google_maps_controller.dart';
import 'gorev.dart';
import 'anaSayfa.dart';
import 'urunEkle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'loginSayfa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'flaskAPI.dart';
import 'package:http/http.dart' as http;
const apikey = "AIzaSyBR9L4muvocP9hk4Je6TBQkczQr-ZDMuYQ";
FirebaseAuth auth = FirebaseAuth.instance;

void main() async {
  final _placesservice = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(MaterialApp(
    initialRoute: auth.currentUser != null ? '/' : '/loginSayfa',
    routes: {
      "/": (context) => anaSayfa(),
      '/loginSayfa': (context) => loginSayfa(),
      '/anaSayfa': (context) => anaSayfa(),
      "/haritaSayfa": (context) => haritaSayfa(),
      "/urunEkle": (context) => urunEkle(),
      "/gecmisGorevler": (context) => gecmisGorevler()
    },
  ));
}

class haritaSayfa extends StatefulWidget {
  const haritaSayfa({Key? key}) : super(key: key);

  @override
  _haritaSayfaState createState() => _haritaSayfaState();
}

String donusenAdres = "";
List<gorev> gorevListesi = [];
DateTime dt = new DateTime.now();

class _haritaSayfaState extends State<haritaSayfa> {
  Set<Marker> _markers = {};
  String girilenAdres = "";
  var urunListJson;
  List<urun> _urunList = [];
  double kameraEnlem = -35.3638734;
  double kameraBoylam = 149.1649175;
  late double adresEnlem;
  late double adresBoylam;
  List gorevUrunListesi = [];
  var controller = GoogleMapsController();
  bool goreveGidebilirmi = false;

  Future<void> jsonOku() async {
    String adres = await rootBundle.loadString('assets/urunListesi.json');
    final data = await json.decode(adres);
    setState(() {
      _urunList = data["urunler"];
    });
  }

  _agirlikKontrol() {
    double agirlik = 0;
    for (gorev g in gorevListesi) {
      for (urun u in g.urunList) {
        agirlik += u.urunAgirlik;
      }
    }
    if (agirlik >= 5.0) {
      Fluttertoast.showToast(
          msg:
              "Dronun taşıyabileceğinden daha fazla ağırlık var lutfen bazılarını çıkartınız...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        goreveGidebilirmi = false;
      });
    } else {
      setState(() {
        goreveGidebilirmi = true;
      });
    }
  }

  firebaseVeriOku() async {
    FirebaseFirestore.instance.collection("urunListesi").get().then((snapshot) {
      for (int i = 0; i < snapshot.docs.length; i++) {
        urun u = new urun(
            snapshot.docs[i].id,
            snapshot.docs[i].data()['urunAdi'],
            snapshot.docs[i].data()['urunFiyat'],
            snapshot.docs[i].data()['urunAgirlik']);
        _urunList.add(u);
        debugPrint(u.urunAdi.toString());
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      firebaseVeriOku();
      FirebaseMessaging.instance.subscribeToTopic("gorevBilgi${auth.currentUser!.uid}");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.airplanemode_active),
        onPressed: () {
          _apiGorevKaydet();
          /*
          * if (gorevListesi.length > 0) {
           _firebaseGorevListesiTemizle();


            _firebaseGorevKaydet();
          }
          * else{
            Fluttertoast.showToast(
                msg: "Listede görev bulunamadı",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);

          }
          * */

        },
      ),
      drawer: Drawer(
        child: gorevListesi.length > 0
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return Dismissible(
                    direction: DismissDirection.startToEnd,
                    onDismissed: (DismissDirection direction) {
                      if (direction == DismissDirection.startToEnd) {
                        for (gorev g in gorevListesi) {
                          if (g.gorevID == gorevListesi[index].gorevID) {
                            setState(() {
                              _markers.remove(_markers.elementAt(index));
                              gorevListesi.remove(g);
                            });
                          }
                        }
                      }
                    },
                    key: Key(gorevListesi[index].gorevID),
                    child: Card(
                      child: ListTile(
                        title: Text(gorevListesi[index].gorevID),
                        subtitle: Row(
                          children: [
                            Text(
                                "Enlem : ${gorevListesi[index].enlem.toStringAsPrecision(7)}"),
                            new Spacer(),
                            Text(
                                "Boylam : ${gorevListesi[index].boylam.toStringAsPrecision(7)}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: gorevListesi.length,
              )
            : Card(
                child: Text("Görev Bulunmamaktadır"),
              ),
      ),
      appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          actions: [
            RaisedButton.icon(
                onPressed: () {
                  setState(() {
                    _adresToCord(girilenAdres);
                    adresKonumEkle(LatLng(adresEnlem, adresBoylam));
                    debugPrint("Liste Olsturuluyor...");
                  });
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _dialogOlustur(
                            context,
                            LatLng(adresEnlem, adresBoylam),
                            _urunList,
                            donusenAdres,
                            gorevUrunListesi);
                      });
                },
                icon: Icon(Icons.search),
                label: Text(""))
          ],
          title: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.home,
              ),
              hintText: "ADRES",
            ),
            onChanged: (value) {
              setState(() {
                girilenAdres = value;
              });
            },
            onSubmitted: (value) => debugPrint(value),
          )),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        initialCameraPosition: CameraPosition(
            target: LatLng(kameraEnlem, kameraBoylam), zoom: 11.5),
        markers: _markers,
        myLocationEnabled: true,
        onTap: (LatLng pos) {
          setState(() {
            _cordToAdress(pos);
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return _dialogOlustur(
                    context, pos, _urunList, donusenAdres, gorevUrunListesi);
              });

          setState(() {
            _markers.add(_addMarker(pos, "${pos.latitude},${pos.longitude}"));
            _cordToAdress(pos);
          });
        },
      ),
    );
  }

  Future<void> _cordToAdress(LatLng pos) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    setState(() {
      gorevListesi;
      donusenAdres = placemarks[0].subLocality.toString() +
          " Mahallesi " +
          placemarks[0].thoroughfare.toString() +
          " Bina " +
          placemarks[0].subThoroughfare.toString() +
          "  " +
          placemarks[0].administrativeArea.toString() +
          placemarks[0].subAdministrativeArea.toString();
    });
    debugPrint(donusenAdres);
  }

  _firebaseGorevListesiTemizle() async {
    final reff =
        FirebaseDatabase.instance.reference().child('/').child('gorevler');
    await reff.remove();
  }
  _apiGorevKaydet()async{
    int sayac = 0;
    final url = "http://10.0.2.2:5000/gorev/"+auth.currentUser!.uid.toString();

    for(gorev g in gorevListesi){
      debugPrint(g.enlem.toString());
  Map<String,dynamic> gidenMap = Map();
  gidenMap['userID'] = auth.currentUser!.uid.toString();
  gidenMap['enlem']=g.enlem.toString();
  gidenMap['boylam']=g.boylam.toString();
  postData(url,gidenMap);
  sayac++;

}
}
  _dialogOlustur(BuildContext context, LatLng pos, List<urun> urunList,
      String adres, List gorevUrunListesi) {
    List<urun> missionUrunList = [];
    return AlertDialog(
      content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Enlem : ${pos.latitude}",
            ),
            Text("Boylam : ${pos.longitude}"),
            Text(
              "${donusenAdres}",
            ),
            SizedBox(
              height: 10,
              width: 10,
            ),
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 400,
                child: ListView.builder(
                    itemCount: urunList.length,
                    itemBuilder: (context, index) {
                      int adet = 0;

                      return Card(
                        child: ListTile(
                          title: Text(urunList[index].urunAdi),
                          subtitle: Row(
                            children: [
                              Text(
                                  "${urunList[index].urunFiyat.toString()} TL | "),
                              Text(
                                  "${urunList[index].urunAgirlik.toString()} Kg"),
                              new Spacer(),
                              Container(
                                alignment: AlignmentDirectional.centerEnd,
                                width: MediaQuery.of(context).size.width * 0.2,
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                                child: Row(
                                  children: [
                                    InkWell(
                                      child:
                                          Icon(Icons.arrow_back_ios_outlined),
                                      onTap: () {
                                        if (adet > 0) {
                                          setState(() {
                                            adet = adet - 1;
                                            missionUrunList
                                                .remove(urunList[index]);
                                            Fluttertoast.showToast(
                                                msg: "${urunList[index].urunAdi} Listeden Çıkartıldı",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            double toplamAgirlik = 0;
                                            for(urun u in missionUrunList){
                                              toplamAgirlik += u.urunAgirlik;
                                            }
                                            if(toplamAgirlik >= 5.0){
                                              Fluttertoast.showToast(
                                                  msg: "Dronun taşıyabileceği maksimum ağırlığın üstüne çıktınız, bazı ürünleri çıkartın...",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                            }
                                          });
                                        }
                                        _agirlikKontrol();
                                      },
                                    ),
                                    SizedBox(width: 10,),
                                    InkWell(
                                      child: Icon(
                                          Icons.arrow_forward_ios_outlined),
                                      onTap: () {
                                        setState(() {
                                          double toplamAgirlik = 0;
                                          for(urun u in missionUrunList){
                                            toplamAgirlik += u.urunAgirlik;
                                          }
                                          if(toplamAgirlik <= 5.0){

                                            adet = adet + 1;
                                            debugPrint(adet.toString());
                                            missionUrunList.add(urunList[index]);
                                            _agirlikKontrol();
                                            Fluttertoast.showToast(
                                                msg: "${urunList[index].urunAdi} Listeye Eklendi",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                          else if(toplamAgirlik > 5.0){
                                            Fluttertoast.showToast(
                                                msg: "Dronun taşıyabileceği maksimum ağırlığın üstüne çıktınız, bazı ürünleri çıkartın...",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);

                                          }
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton.icon(
                    onPressed: () {
                      gorev g = new gorev(donusenAdres, pos.latitude,
                          pos.longitude, missionUrunList);
                      setState(() {
                        gorevListesi.add(g);
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                        Fluttertoast.showToast(
                                msg: "Konum Listeye Eklendi...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0)
                            .whenComplete(() {});
                      });
                    },
                    icon: Icon(Icons.upload_rounded),
                    label: Text("")),
                SizedBox(
                  width: 10,
                ),
                RaisedButton.icon(
                    onPressed: () {
                      setState(() {
                        _markers.remove(_markers.last);
                      });
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    icon: Icon(Icons.cancel),
                    label: Text(""))
              ],
            ),
          ]),
    );
  }


  _firebaseGorevKaydet() async {
    setState(() {
      _agirlikKontrol();
    });
    if (goreveGidebilirmi == true) {
      final reff =
          FirebaseDatabase.instance.reference().child('/').child('gorevler');
      int sayac = 0;
      for (gorev grv in gorevListesi) {
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
          'kullaniciID': auth.currentUser!.uid.toString()
        });
        sayac++;
      }
      setState(() {
        gorevListesi.clear();
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
  }

  _bilgiPaneliOlustur() {
    return AlertDialog(
      content: Column(
        children: [
          Text("Seçili konumlar sisteme yüklendi"),
          SingleChildScrollView(
            child: ListView.builder(itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(
                      "Enlem : ${gorevListesi[index].enlem.toStringAsPrecision(4)} , Boylam ${gorevListesi[index].boylam.toStringAsPrecision(4)}"),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  _adresToCord(String adres) async {
    var locations = await locationFromAddress(adres);
    debugPrint(locations.first.longitude.toString());
    debugPrint(locations.first.latitude.toString());
    setState(() {
      gorevListesi;
      adresEnlem = locations.first.latitude;
      adresBoylam = locations.first.longitude;
    });
    _dialogOlustur(
        context,
        LatLng(locations.first.latitude, locations.first.longitude),
        urunList,
        adres,
        gorevUrunListesi);
  }

  adresKonumEkle(LatLng pos) {
    String id = pos.latitude.toString() + pos.longitude.toString();
    setState(() {
      _markers.add(_addMarker(pos, id));
      gorevListesi;
    });
  }
}

Marker _addMarker(
  LatLng pos,
  String markerID,
) {
  Marker m = Marker(
    markerId: MarkerId(markerID),
    position: pos,
    infoWindow: InfoWindow(
      title:
          "Enlem : ${pos.latitude.toStringAsPrecision(7)} Boylam : ${pos.longitude.toStringAsPrecision(7)}",
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    onTap: () {},
  );
  return m;
}
