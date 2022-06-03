import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ogretmen.dart';
import '../repository/ogretmenler_repository.dart';
import 'ogretmen/ogretmen_form.dart';

class OgretmenlerSayfasi extends ConsumerWidget {
  const OgretmenlerSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ogretmenlerRepository = ref.watch(ogretmenlerProvider);
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              "Öğretmenler"
          )
      ),
      body: Column(
          children: [
            PhysicalModel(
              color: Colors.white,
              elevation: 10,
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 32,
                      ),
                      child: Hero(
                        tag: "ogretmen",
                        child: Material(
                          child: Container(
                            padding: const EdgeInsets.all(40.0),
                            color: Colors.grey.shade300,
                            child: Text(
                              "${ogretmenlerRepository.ogretmenler.length} Öğretmen"
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: OgretmenIndirmeButonu(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(ogretmenListesiProvider);
                },
                child: ref.watch(ogretmenListesiProvider).when(
                  data: (data) => ListView.separated(
                    itemBuilder: (context, index) => OgretmenSatiri(
                      data[index],
                    ),
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: data.length,
                  ),
                  error: (Object error, StackTrace? stackTrace) {
                    return const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Text("Error"),
                    );
                  },
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context){
                return const OgretmenForm();
              },
            )
          );
          if (created == true) {
            print("Öğretmenleri yenile !!!");
          }
        },
        child: const Icon(
          Icons.add
        ),
      ),
    );
  }
}

class OgretmenIndirmeButonu extends StatefulWidget {
  const OgretmenIndirmeButonu({
    Key? key,
  }) : super(key: key);

  @override
  State<OgretmenIndirmeButonu> createState() => _OgretmenIndirmeButonuState();
}

class _OgretmenIndirmeButonuState extends State<OgretmenIndirmeButonu> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return isLoading ? const CircularProgressIndicator() : IconButton(
          icon: const Icon(
              Icons.download
          ),
          onPressed: () async {
            // TODO loading
            // TODO error
            try{
              setState(() {
                isLoading = true;
              });
              await ref.read(ogretmenlerProvider).indir();
            } catch (e){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString()
                    ),
                  )
              );
            }
            finally {
              setState(() {
                isLoading = false;
              });
            }
          },
        );
      }
    );
  }
}

class OgretmenSatiri extends StatelessWidget {
  final Ogretmen ogretmen;
  const OgretmenSatiri(this.ogretmen,{
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "${ogretmen.ad} ${ogretmen.soyad}"
      ),
      leading: IntrinsicWidth(
        child: Center(
          child: Text(
            ogretmen.cinsiyet == "kadin" ? "🤵🏻‍♂" :"🤵🏻‍♀"
          ),
        ),
      ),
    );
  }
}