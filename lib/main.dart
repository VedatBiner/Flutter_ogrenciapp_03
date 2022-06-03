/*
Öğrenci Uygulaması, ekran tasarımları
API Servisi kullanımı
http post
http get
Liste çekmek
hata yaratıp, görmek
firebase uygulaması
firebase Splash Screen
firebase Authentication - Google Sign In
firebase Firestore
firebase Rules
animasyon eklendi
Lottie ve Rive ile hareketli animasyon eklendi
*/

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_ogrenciapp_03/utilities/google_sign_in.dart';
import 'package:flutter_ogrenciapp_03/repository/ogrenciler_repository.dart';
import 'package:flutter_ogrenciapp_03/repository/ogretmenler_repository.dart';
import 'package:flutter_ogrenciapp_03/repository/mesajlar_repository.dart';
import 'package:flutter_ogrenciapp_03/pages/mesajlar_sayfasi.dart';
import 'package:flutter_ogrenciapp_03/pages/ogrenciler_sayfasi.dart';
import 'package:flutter_ogrenciapp_03/pages/ogretmenler_sayfasi.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const ProviderScope(
      child: OgrenciApp()
  )
  );
}

class OgrenciApp extends StatelessWidget {
  const OgrenciApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Öğrenci Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isfFirebaseInitialized = false;

  @override
  void initState(){
    super.initState();
    initializeFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isfFirebaseInitialized
            ? ElevatedButton(
          onPressed: () async {
            await signInWithGoogle();
            String uid =  FirebaseAuth.instance.currentUser!.uid;
            await FirebaseFirestore.instance.collection("kullanicilar").doc(uid).set(
              {
                "girisYaptimi" : true,
                "sonGirisTarihi" : FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );
            anaSayfayaGit();
          },
          child: const Text(
              "Google sign In"),
        )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    setState(() {
      isfFirebaseInitialized = true;
    });
    if (FirebaseAuth.instance.currentUser != null){
      anaSayfayaGit();
    }
  }

  void anaSayfayaGit() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder:
          (context) => const AnaSayfa(title: 'Öğrenci Ana Sayfa'),
      ),
    );
  }
}

class AnaSayfa extends ConsumerWidget {
  const AnaSayfa({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final ogrencilerRepository =  ref.watch(ogrencilerProvider);
    final ogretmenlerRepository =  ref.watch(ogretmenlerProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  "animasyonlar/trophy.zip"
                ),
              ),
              const SizedBox(
                width: 200,
                height: 200,
                child: RiveAnimation.asset(
                    "animasyonlar/Digibot.riv"
                ),
              ),
              TextButton(
                child: Text(
                  "${ref.watch(yeniMesajSayisiProvider)} yeni mesaj"
                ),
                onPressed: (){
                  _mesajlaraGit(context);
                },
              ),
              TextButton(
                child: Text(
                    "${ogrencilerRepository.ogrenciler.length} öğrenci"
                ),
                onPressed: (){
                  _ogrencilereGit(context);
                },
              ),
              TextButton(
                child: Hero(
                  tag: "ogretmen",
                  child: Material(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey.shade300,
                      child: Text(
                        "${ogretmenlerRepository.ogretmenler.length} öğretmen"
                      ),
                    ),
                  ),
                ),
                onPressed: (){
                  _ogretmenlereGit(context);
                },
              )
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserHeader(),
              ListTile(
                title: const Text(
                    "Öğrenciler"
                ),
                onTap: (){
                  _ogrencilereGit(context);
                },
              ),
              ListTile(
                title: const Text(
                    "Öğretmenler"
                ),
                onTap: (){
                  _ogretmenlereGit(context);
                },
              ),
              ListTile(
                title: const Text(
                    "Mesajlar"
                ),
                onTap: (){
                  _mesajlaraGit(context);
                },
              ),
              ListTile(
                title: const Text(
                    "Çıkış Yap"
                ),
                onTap: () async {
                  await signOutWithGoogle();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        )
    );
  }

  void _ogrencilereGit(context) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context){
            return const OgrencilerSayfasi();
          },
        )
    );
  }

  void _ogretmenlereGit(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context){
            return const OgretmenlerSayfasi();
          },
        )
    );
  }

  Future<void> _mesajlaraGit(context) async {
    await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context){
            return const MesajlarSayfasi();
          },
        )
    );
  }

}

class UserHeader extends StatefulWidget {
  const UserHeader({
    Key? key,
  }) : super(key: key);

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {

  Future<Uint8List?>? _ppicFuture;

  @override
  void initState(){
    super.initState();
    _ppicFuture = _ppicIndir();
  }

  Future<Uint8List?> _ppicIndir() async {
    // Resmi indirme kodu
    var uid = FirebaseAuth.instance.currentUser!.uid;
    final documentSnapshot = await FirebaseFirestore.instance.collection("kullanicilar").doc(uid).get();
    final userRecMap = documentSnapshot.data();
    if(userRecMap == null) return null;
    if(userRecMap.containsKey("ppicRef")){
      var ppicRef = userRecMap["ppicref"];
      Uint8List? uint8list = await FirebaseStorage.instance.ref(ppicRef).getData();
      return uint8list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(FirebaseAuth.instance.currentUser!.displayName!),
          Text(FirebaseAuth.instance.currentUser!.email!),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
              if (xFile == null) return;
              final imagePath = xFile.path;
              final uid = FirebaseAuth.instance.currentUser!.uid;
              final ppicRef = FirebaseStorage.instance.ref("ppics").child("$uid.jpg");
              await ppicRef.putFile(File(imagePath));
              await FirebaseFirestore.instance.collection("kullanicilar").doc(uid).update(
                  {"ppicref": ppicRef.fullPath});
              setState(() {
                _ppicFuture = _ppicIndir();
                print ("set state içindeyim !!!");
              });
            },
            child: FutureBuilder<Uint8List?>(
                future: _ppicFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null){
                    final picInMemory = snapshot.data!;
                    return MovingAvatar(picInMemory: picInMemory);
                  }
                  return const CircleAvatar(
                    child: Text("VB"),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('initState', initState));
  }
}

class MovingAvatar extends StatefulWidget {
  const MovingAvatar({
    Key? key,
    required this.picInMemory,
  }) : super(key: key);

  final Uint8List picInMemory;

  @override
  State<MovingAvatar> createState() => _MovingAvatarState();
}

class _MovingAvatarState extends State<MovingAvatar>
  with SingleTickerProviderStateMixin<MovingAvatar>{
  late Ticker _ticker;
  double yataydaKonum = 0.0;

  @override
  void initState(){
    super.initState();
    _ticker = createTicker((Duration elapsed){
      final aci = pi * elapsed.inMicroseconds / const Duration(seconds: 1).inMicroseconds;
      setState((){
        var yataydaKonum = sin(aci) * 30 + 30;
      });
    });
    _ticker.start();
  }

  @override
  void dispose(){
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: yataydaKonum),
      child: CircleAvatar(
        backgroundImage: MemoryImage(widget.picInMemory),
      ),
    );
  }
}