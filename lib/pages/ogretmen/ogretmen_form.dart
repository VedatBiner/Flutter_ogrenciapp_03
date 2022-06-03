import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_ogrenciapp_03/services/data_service.dart';
import '../../models/ogretmen.dart';

class OgretmenForm extends ConsumerStatefulWidget {
  const OgretmenForm({Key? key}) : super(key: key);

  @override
  _OgretmenFormState createState() => _OgretmenFormState();
}

class _OgretmenFormState extends ConsumerState<OgretmenForm>
// animation controller yaratalım
    with
        SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this);

  final alignmentTween = Tween<AlignmentGeometry>(
      begin: Alignment.centerLeft, end: Alignment.centerRight);

  final Map<String, dynamic> girilen = {};
  final _formKey = GlobalKey<FormState>();

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: const Text("Yeni Öğretmen"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScaleTransition(
                  scale: controller,
                  child: const Icon(
                    Icons.person,
                    size: 150,
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Ad"),
                  ),
                  validator: (value) {
                    if (value?.isNotEmpty != true) {
                      return "Ad girmeniz gerekli";
                    }
                  },
                  onSaved: (newValue) {
                    girilen["ad"] = newValue;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Soyad"),
                  ),
                  validator: (value) {
                    if (value?.isNotEmpty != true) {
                      return "Soyad girmeniz gerekli";
                    }
                  },
                  onSaved: (newValue) {
                    girilen["soyad"] = newValue;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Yaş"),
                  ),
                  validator: (value) {
                    if (value == null || value.isNotEmpty != true) {
                      return "Yaş girmeniz gerekli";
                    }
                    if (int.tryParse(value) == null) {
                      return "Rakamlarla yaş girmeniz gerekli !!!";
                    }
                    return null; // burası olacak mı ?
                  },
                  keyboardType: TextInputType.number,
                  onSaved: (newValue) {
                    girilen["yas"] = int.parse(newValue!);
                  },
                  onChanged: (value) {
                    final v = double.parse(value);
                    controller.animateTo(
                      v / 100,
                      duration: const Duration(seconds: 1),
                    );
                  },
                ),
                DropdownButtonFormField(
                  items: const [
                    DropdownMenuItem(
                      value: "Erkek",
                      child: Text("Erkek"),
                    ),
                    DropdownMenuItem(
                      value: "Kadın",
                      child: Text("Kadın"),
                    )
                  ],
                  value: girilen["cinsiyet"],
                  onChanged: (value) {
                    setState(() {
                      girilen["cinsiyet"] = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return " Lütfen cinsiyet seçiniz";
                    }
                    return null; // Burası olmalı mı ?
                  },
                ),
                isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : AlignTransition(
                        alignment: alignmentTween.animate(controller),
                        child: ElevatedButton(
                            onPressed: () {
                              final formState = _formKey.currentState;
                              if (formState == null) return;
                              if (formState.validate() == true) {
                                formState.save();
                                print(girilen);
                              }
                              _kaydet();
                            },
                            child: const Text("Kaydet")),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _kaydet() async {
    bool bitti = false;
    while (!bitti) {
      try {
        setState(() {
          isSaving = true;
        });
        // Kaydetme işini yapan satır
        await gercektenKaydet();
        bitti = true;
        Navigator.of(context).pop(true);
      } catch (e) {
        final snackBar = ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        // snackbar mesajı kapanana kadar bekler
        await snackBar.closed;
      } finally {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> gercektenKaydet() async {
    await ref.read(dataServiceProvider).ogretmenEkle(Ogretmen.fromMap(girilen));
  }
}
