import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ogretmen.dart';

class DataService {
  final String baseUrl = "https://6287867ce9494df61b3adab5.mockapi.io/";

  Future<Ogretmen> ogretmenIndir() async {
    // http.get ile veriyi alıyoruz.
    final response = await http.get(Uri.parse("$baseUrl/ogretmen/1"));

    if (response.statusCode == 200){
      return Ogretmen.fromMap(jsonDecode(response.body));
    } else {
      throw Exception("Öğretmen İndirilemedi. ${response.statusCode}");
    }
  }

  Future<void> ogretmenEkle(Ogretmen ogretmen) async {
    // Firebase 'e kayıt.
    await FirebaseFirestore.instance.collection("ogretmenler").add(ogretmen.toMap());
  }

  Future<List<Ogretmen>> ogretmenleriGetir() async {
    // Firebase ile alalım.
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection("ogretmenler").get();
    return querySnapshot.docs.map((e) => Ogretmen.fromMap(e.data())).toList();
  }

}

final dataServiceProvider = Provider(
    (ref) {
      return DataService();
    }
);
