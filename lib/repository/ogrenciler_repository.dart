import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ogrenci.dart';

class OgrencilerRepository extends ChangeNotifier{
  final ogrenciler = [
    Ogrenci("Ali", "Yılmaz", 18, "Erkek"),
    Ogrenci("Ayşe", "Çelik", 20, "Kadın")
  ];

  final Set<Ogrenci> sevdiklerim = {};

  void sev(Ogrenci ogrenci, bool seviyorMuyum) {
    if (seviyorMuyum){
      sevdiklerim.add(ogrenci);
    } else {
      sevdiklerim.remove(ogrenci);
    }
    notifyListeners();
  }

  bool seviyorMuyum(Ogrenci ogrenci) {
    return sevdiklerim.contains(ogrenci);
  }
}

final ogrencilerProvider = ChangeNotifierProvider(
  (ref) {
    return OgrencilerRepository();
  }
);

