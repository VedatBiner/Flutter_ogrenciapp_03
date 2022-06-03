import "package:flutter_test/flutter_test.dart";
import 'package:flutter_ogrenciapp_03/models/ogrenci.dart';
import 'package:flutter_ogrenciapp_03/repository/ogrenciler_repository.dart';

void main() {
  group("Öğrenci sevme", () {
    test("Sevdiğim öğrenci sevilmiş olarak görünüyor mu?", (){
      final ogrencilerRepository = OgrencilerRepository();
      final yeniOgrenci = Ogrenci("test ad", "test soyad", 33, "Kadın");

      ogrencilerRepository.ogrenciler.add(yeniOgrenci);
      // kontrolü expect ile yapıyoruz (ilk testimiz)
      expect(ogrencilerRepository.seviyorMuyum(yeniOgrenci), false);

      // seviyor mu test?
      ogrencilerRepository.sev(yeniOgrenci, true);
      expect(ogrencilerRepository.seviyorMuyum(yeniOgrenci), true);

      // sevmiyor mu test?
      ogrencilerRepository.sev(yeniOgrenci, false);
      expect(ogrencilerRepository.seviyorMuyum(yeniOgrenci), false);

      ogrencilerRepository.ogrenciler.remove(yeniOgrenci);
      expect(ogrencilerRepository.seviyorMuyum(yeniOgrenci), false);
    });
  });
  test("Bilinmeyen öğrenci sevilmiyor.", (){
    final ogrencilerRepository = OgrencilerRepository();
    final yeniOgrenci = Ogrenci("test ad", "test soyad", 33, "Kadın");

    expect(ogrencilerRepository.seviyorMuyum(yeniOgrenci), false);
  });

}