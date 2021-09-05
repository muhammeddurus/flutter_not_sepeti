import 'package:flutter/material.dart';
import 'package:ogr_not_sepeti_app/utils/database_helper.dart';

import 'models/kategori.dart';

class Kategoriler extends StatefulWidget {
  const Kategoriler({Key? key}) : super(key: key);

  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori>? tumKategoriler;
  DatabaseHelper? databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriler == null) {
      tumKategoriler = [];
      kategoriListesiniGuncelle();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Kategoriler"),
        ),
        body: ListView.builder(
            itemCount: tumKategoriler!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(tumKategoriler![index].kategoriBaslik.toString()),
                trailing: GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () => _kategoriSil(tumKategoriler![index].kategoriID),
                ),
                leading: Icon(Icons.category),
                onTap: () => _kategoriGuncelle(tumKategoriler![index]),
              );
            }));
  }

  void kategoriListesiniGuncelle() {
    databaseHelper!.kategoriListesiniGetir().then((kategorilerIcerenListe) {
      setState(() {
        tumKategoriler = kategorilerIcerenListe;
      });
    });
  }

  _kategoriSil(int? kategoriID) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Kategori Sil"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Bu kategoriyi sildiğinizde bununla ilgili tüm notlarda silinecektir. Emin misiniz ?"),
                ButtonBar(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Vazgeç"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        databaseHelper!
                            .kategoriSil(kategoriID!)
                            .then((silinenKategori) {
                          if (silinenKategori != 0) {
                            setState(() {
                              kategoriListesiniGuncelle();
                              Navigator.pop(context);
                            });
                          }
                        });
                      },
                      child: Text("Kategoriyi Sil"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  _kategoriGuncelle(Kategori guncellenecekKategori) {
    kategoriGuncelleMethod(context, guncellenecekKategori);
  }

  void kategoriGuncelleMethod(
      BuildContext context, Kategori guncellenecekKategori) {
    var formKey = GlobalKey<FormState>();
    String? guncellenecekKategoriAdi;
    var snackBar = SnackBar(content: Text("Kategori Güncellendi."));

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Kategori Güncelle",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: [
            Form(
              key: formKey, // kaydetme işlemini yapmak için key atıyoruz.
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: guncellenecekKategori.kategoriBaslik,
                  onSaved: (yeniDeger) {
                    guncellenecekKategoriAdi = yeniDeger!;
                  },
                  decoration: InputDecoration(
                    labelText: "Kategori Adı",
                    border: OutlineInputBorder(),
                  ),
                  validator: (girilenKategoriAdi) {
                    if (girilenKategoriAdi!.length < 3) {
                      return "En az 3 karakter giriniz.";
                    }
                  },
                ),
              ),
            ),
            ButtonBar(
              children: [
                ElevatedButton(
                  child: Text(
                    "Vazgeç",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.orangeAccent),
                  ),
                ),
                ElevatedButton(
                  child: Text(
                    "Kaydet",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      databaseHelper!
                          .kategoriGuncelle(Kategori.withID(
                              guncellenecekKategori.kategoriID,
                              guncellenecekKategoriAdi))
                          .then((katId) {
                        if (katId != 0) {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          kategoriListesiniGuncelle();
                          Navigator.pop(context);
                        }
                      });
                      /*databaseHelper!
                          .kategoriEkle(Kategori(guncellenecekKategoriAdi))
                          .then((kategoriID) {
                        if (kategoriID > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }

                        Navigator.pop(context);
                      });*/
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.redAccent),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
