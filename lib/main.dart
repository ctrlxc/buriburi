import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'main.g.dart';

void main() {
  runApp(BuriBuriApp());
}

class BuriBuriApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('ja'),
      ],
      title: 'BuriBuri',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: "Azuki",
      ),
      home: BuriBuri(),
    );
  }
}

class BuriBuri extends StatefulWidget {
  BuriBuri({Key key}) : super(key: key);

  @override
  _BuriBuriState createState() => _BuriBuriState();
}

@JsonSerializable(explicitToJson: true)
class Payment {
  DateTime date;
  int money;
  String reason;
  String memo;

  Payment(this.date, this.money, this.reason, this.memo);

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}

class _BuriBuriState extends State<BuriBuri> {
  var payment = Payment(DateTime.now(), null, null, null);

  Future<void> selectDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      locale: const Locale('ja'),
    );

    if (selected != null) {
      setState(() {
        payment.date = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/title.png'),
        backgroundColor: Color(0xffffffff),
        elevation: 0, // hide shadow
        toolbarHeight: 200,
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text(
                  DateFormat.yMMMMEEEEd('ja')
                      .format(payment.date)
                      .replaceAllMapped(RegExp(r'(.)曜日'), (match) {
                    return '(${match.group(1)})';
                  }),
                  style: TextStyle(fontSize: 38)),
              onPressed: () => selectDate(context),
            ),
            Container(
                child: TextField(
              decoration:
                  InputDecoration(labelText: 'いくら？', hintText: '例 1,234'),
              style: TextStyle(fontSize: 30),
              // autofocus: false,
              textAlign: TextAlign.right,
              maxLength: 8,
              // keyboardType: TextInputType.number,
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              onSubmitted: (String value) {
                setState(() {
                  payment.money = int.tryParse(value, radix: 10);
                });
              },
            )),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                'なんで？',
                style: TextStyle(
                    fontSize: 20, color: Color.fromRGBO(100, 100, 100, 1.0)),
                textAlign: TextAlign.left,
              ),
            ),
            DropdownButton<String>(
              // icon: Icon(Icons.arrow_downward),
              value: payment.reason,
              isExpanded: true,
              items: <String>['', 'おこずかい', 'おてつだい'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 30)),
                );
              }).toList(),
              onChanged: (String value) {
                setState(() {
                  payment.reason = value;
                });
              },
            ),
            Container(
                child: TextField(
              decoration: InputDecoration(labelText: 'メモ', hintText: '例 ありがとう'),
              style: TextStyle(fontSize: 30),
              maxLength: 140,
              // keyboardType: TextInputType.multiline,
              // maxLines: null,
              onSubmitted: (String value) {
                setState(() {
                  payment.memo = value;
                });
              },
            )),
            RaisedButton(
                child: Text('あげる', style: TextStyle(fontSize: 98)),
                color: Colors.white,
                shape: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                onPressed: () {
                  print(json.encode(payment));
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          content: Container(
                              width: 320,
                              height: 320,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  QrImage(
                                    data: json.encode(payment),
                                    version: QrVersions.auto,
                                    size: 320,
                                    embeddedImage:
                                        AssetImage('assets/qricon.png'),
                                    embeddedImageStyle: QrEmbeddedImageStyle(
                                      size: Size(50, 50),
                                    ),
                                  ),
                                ],
                              )),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("閉じる"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      });
                }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.history), title: Text('きろく')),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text('せってい')),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
