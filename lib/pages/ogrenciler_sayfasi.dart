import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_ogrenciapp_03/repository/ogrenciler_repository.dart';
import '../models/ogrenci.dart';

class OgrencilerSayfasi extends ConsumerWidget {
  const OgrencilerSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ogrencilerRepository = ref.watch(ogrencilerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Öğrenciler"
          )
        ),
        body: Column(
          children: [
            PhysicalModel(
              color: Colors.white,
              elevation: 10,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 32,
                  ),
                  child: Text(
                    "${ogrencilerRepository.ogrenciler.length} Öğrenci"
                    ),
                  ),
              ),
            ),

            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => OgrenciSatiri(
                  ogrencilerRepository.ogrenciler[index],
                ),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: ogrencilerRepository.ogrenciler.length,
              ),
            ),
          ]
        ),
      );
  }
}

class OgrenciSatiri extends ConsumerWidget {
  final Ogrenci ogrenci;
  const OgrenciSatiri(this.ogrenci, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool seviyorMuyum = ref.watch(ogrencilerProvider).seviyorMuyum(ogrenci);
    return ListTile(
      title: AnimatedPadding(
        duration: const Duration(seconds: 3),
        padding: seviyorMuyum ? const EdgeInsets.only(left: 30) : const EdgeInsets.only(),
        curve: Curves.bounceInOut,
        child: Text(
          ogrenci.ad + " " + ogrenci.soyad
        ),
      ),
      leading: IntrinsicWidth(
        child: Center(
          child: Text(
            ogrenci.cinsiyet == "kadin" ? "🤵🏻‍♂" :"🤵🏻‍♀️"
          ),
        ),
      ),
      trailing: IconButton(
        onPressed: (){
          ref.read(ogrencilerProvider).sev(ogrenci, !seviyorMuyum);
        },
        icon: AnimatedCrossFade(
          firstChild: const Icon(Icons.favorite),
          secondChild: const Icon(Icons.favorite_border),
          crossFadeState: seviyorMuyum ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(seconds: 2),
        ),
      ),
    );
  }
}
