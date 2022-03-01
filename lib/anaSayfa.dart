import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class anaSayfa extends StatelessWidget {

  const anaSayfa({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.red, Colors.purple, Colors.lightBlue]),
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Image(
              image: AssetImage('assets/lambdaLogo.png'),
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Text(
              "Flying High Again",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/urunEkle");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(colors: [
                    Colors.blueGrey,
                    Colors.deepPurpleAccent,
                    Colors.redAccent
                  ]),
                ),
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.no_drinks_sharp,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                    Text(
                      "Ürün Ekle",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/haritaSayfa");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(colors: [
                    Colors.blueGrey,
                    Colors.deepPurpleAccent,
                    Colors.redAccent
                  ]),
                ),
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                    Text(
                      "Görev Belirle",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/gecmisGorevler");
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(colors: [
                    Colors.blueGrey,
                    Colors.deepPurpleAccent,
                    Colors.redAccent
                  ]),
                ),
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                        Icons.timelapse_outlined
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                    Text(
                      "Geçmiş Gorevler",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {
                auth.signOut().whenComplete(
                        () => Navigator.pushNamed(context, '/loginSayfa'));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(colors: [
                    Colors.blueGrey,
                    Colors.deepPurpleAccent,
                    Colors.redAccent
                  ]),
                ),
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                        Icons.highlight_off_outlined
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                    Text(
                      "Çıkış Yap",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
