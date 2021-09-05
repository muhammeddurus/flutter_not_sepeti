import 'package:flutter/material.dart';
import 'package:ogr_not_sepeti_app/models/kategori.dart';
import 'package:ogr_not_sepeti_app/models/not.dart';
import 'package:ogr_not_sepeti_app/utils/database_helper.dart';

class NotDetay extends StatefulWidget {
  String? baslik;
  Not? duzenlenecekNot;
  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori>? tumKategoriler;
  DatabaseHelper? databaseHelper;
  int? kategoriID;
  int? secilenOncelik;
  String? notBaslik, notIcerik;

  static var _oncelik = ["Düşük", "Orta", "Acil"];

  @override
  void initState() {
    super.initState();
    tumKategoriler = [];
    databaseHelper = DatabaseHelper();
    databaseHelper!.kategorileriGetir().then((kategorileriIcerenMapListesi) {
      for (Map<String, dynamic> okunanMap in kategorileriIcerenMapListesi) {
        tumKategoriler!.add(Kategori.fromMap(okunanMap));
      }
      if (widget.duzenlenecekNot != null) {
        kategoriID = widget.duzenlenecekNot!.kategoriID;
        secilenOncelik = widget.duzenlenecekNot!.notOncelik;
      } else {
        kategoriID = 1;
        secilenOncelik = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          widget.baslik.toString(),
        ),
      ),
      body: tumKategoriler!.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Kategori : ",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.purpleAccent, width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: kategoriItemleriOlustur(),
                              value: kategoriID,
                              onChanged: (int? secilenKatID) {
                                setState(() {
                                  kategoriID = secilenKatID;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.duzenlenecekNot != null
                            ? widget.duzenlenecekNot!.notBaslik
                            : "",
                        validator: (text) {
                          if (text!.length < 3) {
                            return "En az 3 karakter olmalı.";
                          }
                        },
                        onSaved: (text) {
                          notBaslik = text;
                        },
                        decoration: InputDecoration(
                          hintText: "Not başlığını giriniz",
                          labelText: "Başlık",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.duzenlenecekNot != null
                            ? widget.duzenlenecekNot!.notIcerik
                            : "",
                        onSaved: (text) {
                          notIcerik = text;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Not içeriğini giriniz",
                          labelText: "İçerik",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Öncelik : ",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.purpleAccent, width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              items: _oncelik.map((oncelik) {
                                return DropdownMenuItem<int>(
                                  child: Text(
                                    oncelik.toString(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: _oncelik.indexOf(oncelik),
                                );
                              }).toList(),
                              value: secilenOncelik,
                              onChanged: (int? secilenOncelikID) {
                                setState(() {
                                  secilenOncelik = secilenOncelikID;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Vazgeç"),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.pink),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();

                              var suan = DateTime.now();
                              if (widget.duzenlenecekNot == null) {
                                databaseHelper!
                                    .notEkle(Not(
                                        kategoriID,
                                        notBaslik,
                                        notIcerik,
                                        suan.toString(),
                                        secilenOncelik))
                                    .then((kaydedilenNotId) {
                                  if (kaydedilenNotId != 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              } else {
                                databaseHelper!
                                    .notGuncelle(Not.withID(
                                        widget.duzenlenecekNot!.notID,
                                        kategoriID,
                                        notBaslik,
                                        notIcerik,
                                        suan.toString(),
                                        secilenOncelik))
                                    .then((guncellenenId) {
                                  if (guncellenenId != 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            }
                          },
                          child: Text(
                            "Kaydet",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.purpleAccent),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    return tumKategoriler!
        .map(
          (kategori) => DropdownMenuItem<int>(
            value: kategori.kategoriID,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                kategori.kategoriBaslik.toString(),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        )
        .toList();
  }
}

/*Form(
        key: formKey,
        child: Column(
          children: [
            Center(
              child: Container(
                child: DropdownButtonHideUnderline(
                  child: tumKategoriler!.length <= 0
                      ? CircularProgressIndicator()
                      : DropdownButton<int>(
                          value: kategoriID,
                          items: kategoriItemleriOlustur(),
                          onChanged: (secilenKategoriId) {
                            setState(() {
                              kategoriID = secilenKategoriId!;
                            });
                          },
                        ),
                ),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
 */
