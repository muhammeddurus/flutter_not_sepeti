import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ogr_not_sepeti_app/kategori_islemleri.dart';
import 'package:ogr_not_sepeti_app/models/not.dart';
import 'package:ogr_not_sepeti_app/not_details.dart';
import 'package:ogr_not_sepeti_app/utils/database_helper.dart';

import 'models/kategori.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir();
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
      ),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatefulWidget {
  @override
  _NotListesiState createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    child: ListTile(
                  leading: Icon(Icons.category),
                  title: Text("Kategoriler"),
                  onTap: () {
                    Navigator.pop(context);
                    _kategorilerSayfasinaGit();
                  },
                )),
              ];
            },
          ),
        ],
        title: Center(
          child: Text("Not Sepeti"),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              kategoriEkleMethod(context);
            },
            heroTag: "KategoriEkle",
            tooltip: "Kategori Ekle",
            child: Icon(Icons.add_circle),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () => _detaySayfasinaGit(context),
            heroTag: "NotEkle",
            tooltip: "Not Ekle",
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleMethod(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String? yeniKategoriAdi;
    var snackBar = SnackBar(content: Text("Kategori Eklendi."));

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Kategori Ekle",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: [
            Form(
              key: formKey, // kaydetme işlemini yapmak için key atıyoruz.
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onSaved: (yeniDeger) {
                    yeniKategoriAdi = yeniDeger!;
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
                      databaseHelper
                          .kategoriEkle(Kategori(yeniKategoriAdi))
                          .then((kategoriID) {
                        if (kategoriID > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }

                        Navigator.pop(context);
                      });
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

  void _detaySayfasinaGit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                NotDetay(baslik: "Yeni Not"))).then((value) => setState(() {}));
  }

  _kategorilerSayfasinaGit() {
    Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => Kategoriler()))
        .then((value) => setState(() {}));
  }
}

class Notlar extends StatefulWidget {
  const Notlar({Key? key}) : super(key: key);

  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not>? tumNotlar;
  DatabaseHelper? databaseHelper;
  var snackBar2 = SnackBar(content: Text("Not Silindi."));

  @override
  void initState() {
    super.initState();
    tumNotlar = [];
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper!.notListesiniGetir(),
      builder: (context, AsyncSnapshot<List<Not>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          tumNotlar = snapshot.data;
          sleep(Duration(milliseconds: 500));
          return ListView.builder(
              itemCount: tumNotlar!.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _oncelikIconuAta(tumNotlar![index].notOncelik),
                  title: Text(tumNotlar![index].notBaslik.toString()),
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Kategori",
                                  style: TextStyle(color: Colors.purpleAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  tumNotlar![index].kategoriBaslik.toString(),
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Oluşturulma Tarihi",
                                  style: TextStyle(color: Colors.purpleAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  databaseHelper!.dateFormat(DateTime.parse(
                                      tumNotlar![index].notTarih.toString())),
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("İçerik :" +
                                tumNotlar![index].notIcerik.toString()),
                          ),
                          ButtonBar(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _notSil(tumNotlar![index].notID),
                                child: Text("Sil"),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _detaySayfasinaGit(
                                      context, tumNotlar![index]);
                                },
                                child: Text("Güncelle"),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        } else {
          return Center(child: Text("Yükleniyor..."));
        }
      },
    );
  }

  void _detaySayfasinaGit(BuildContext context, Not not) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    NotDetay(baslik: "Notu Düzenle", duzenlenecekNot: not)))
        .then((value) => setState(() {}));
  }

  _oncelikIconuAta(int? notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text(
            "AZ",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.purple.shade100,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text("ORTA", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.purple.shade200,
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text("ACİL", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.purple.shade700,
        );
        break;
        break;
    }
  }

  _notSil(int? notID) {
    databaseHelper!.notSil(notID!).then((silinenID) {
      if (silinenID != 0) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar2);
        setState(() {});
      }
    });
  }
}
