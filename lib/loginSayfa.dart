import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class loginSayfa extends StatefulWidget {
  const loginSayfa({Key? key}) : super(key: key);

  @override
  _loginSayfaState createState() => _loginSayfaState();
}

String _mailAdresi = "";
String _parola = "";
FirebaseAuth auth = FirebaseAuth.instance;

class _loginSayfaState extends State<loginSayfa> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                _mailAdresi = value;
              },
              decoration: InputDecoration(
                  hintText: 'Mail Adresi', icon: Icon(Icons.mail)),
            ),
            TextField(
              decoration: InputDecoration(
                  hintText: 'parola', icon: Icon(Icons.password)),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (value) {
                _parola = value;
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton.icon(
                    onPressed: () {
                        auth.signInWithEmailAndPassword(email: _mailAdresi, password: _parola).catchError((e){debugPrint(e.toString());}).whenComplete((){
                          Navigator.pushNamed(context,'/');
                         debugPrint(auth.currentUser!.email.toString());

                        });},
                    icon: Icon(Icons.login),
                    label: Text("Giriş Yap")),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                RaisedButton.icon(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _kayitSekmesiOlustur(context);
                          });
                    },
                    icon: Icon(Icons.app_registration),
                    label: Text("Kayıt Ol"))
              ],
            )
          ],
        ),
      ),
    );
  }

  _kayitSekmesiOlustur(BuildContext context) {
    String mailAdresi = "";
    String parola = "";
    return AlertDialog(
      content: Column(
        children: [
          TextField(
            decoration:
                InputDecoration(prefixIcon: Icon(Icons.mail), hintText: "Mail"),
            onChanged: (deger) {
              setState(() {
                mailAdresi = deger;
              });
            },
          ),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.password), hintText: "Parola"),
            onChanged: (deger) {
              setState(() {
                parola = deger;
              });
            },
          ),
          RaisedButton(
            onPressed: () {
              auth.createUserWithEmailAndPassword(email: mailAdresi, password: parola).catchError((e){
                debugPrint(e.toString());
              }).whenComplete((){

              });
            },
            child: Text("Kayıt Ol"),
          )
        ],
      ),
    );
  }
}
