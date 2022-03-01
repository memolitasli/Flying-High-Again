import 'dart:io';
class urun{
  String _urunID;
  String _urunAdi;
  double _urunFiyat;
  double _urunAgirlik;

  String get urunID => _urunID;

  set urunID(String value) {
    _urunID = value;
  }

  String get urunAdi => _urunAdi;

  double get urunAgirlik => _urunAgirlik;

  set urunAgirlik(double value) {
    _urunAgirlik = value;
  }

  double get urunFiyat => _urunFiyat;

  set urunFiyat(double value) {
    _urunFiyat = value;
  }

  set urunAdi(String value) {
    _urunAdi = value;
  }

  urun(this._urunID, this._urunAdi, this._urunFiyat, this._urunAgirlik);
}