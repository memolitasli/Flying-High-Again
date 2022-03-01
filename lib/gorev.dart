import 'urun.dart';
class gorev{
  String _gorevID;
  double _enlem;
  double _boylam;
  List<urun> urunList;

  gorev(this._gorevID, this._enlem, this._boylam, this.urunList);

  double get boylam => _boylam;

  set boylam(double value) {
    _boylam = value;
  }

  double get enlem => _enlem;

  set enlem(double value) {
    _enlem = value;
  }

  String get gorevID => _gorevID;

  set gorevID(String value) {
    _gorevID = value;
  }

}