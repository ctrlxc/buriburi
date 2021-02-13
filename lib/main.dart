import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/cupertino.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

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
          // const Locale('en'),
          const Locale('ja'),
        ],
        title: 'BuriBuri',
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "Azuki",
        ),
        // home: GestureDetector(
        //   onTap: () {
        //     final FocusScopeNode currentScope = FocusScope.of(context);
        //     if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        //       FocusManager.instance.primaryFocus.unfocus();
        //     }
        //   },
        //   child: BuriBuri(),
        // ),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => BuriBuri(),
          '/qrcode': (BuildContext context) => Qrcode(),
        });
  }
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

class BuriBuri extends StatefulWidget {
  BuriBuri({Key key}) : super(key: key);

  @override
  _BuriBuriState createState() => _BuriBuriState();
}

class _BuriBuriState extends State<BuriBuri> {
  final _form = GlobalKey<FormState>(); // 追加
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
    final memoNode = FocusNode();

    var dateWidget = FlatButton(
      child: Text(
          DateFormat.yMMMMEEEEd('ja')
              .format(payment.date)
              .replaceAllMapped(RegExp(r'(.)曜日'), (match) {
            return '(${match.group(1)})';
          }),
          style: TextStyle(fontSize: 32)),
      onPressed: () => selectDate(context),
    );

    var moneyWidget = Row(children: <Widget>[
      Flexible(
        child: TextFormField(
            decoration: InputDecoration(labelText: 'いくら？', hintText: '例 1,234'),
            style: TextStyle(fontSize: 30),
            // autofocus: false,
            textAlign: TextAlign.right,
            autofocus: false,
            maxLength: 8,
            // keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            keyboardType:
                TextInputType.numberWithOptions(signed: true, decimal: true),
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            onFieldSubmitted: (_) {
              memoNode.requestFocus();
            },
            onSaved: (String value) {
              payment.money = int.tryParse(value, radix: 10);
            }),
      ),
      Text(
        'ブリ\nブリ',
        style: TextStyle(fontSize: 24),
      ),
    ]);

    var memoWidget = TextFormField(
      decoration: InputDecoration(labelText: 'メモ', hintText: '例 ありがとう'),
      style: TextStyle(fontSize: 30),
      maxLength: 140,
      autofocus: false,
      keyboardType: TextInputType.multiline,
      // textInputAction: TextInputAction.done,
      maxLines: null,
      focusNode: memoNode,
      onSaved: (String value) {
        payment.memo = value;
      },
    );

    var giveWidget = RaisedButton(
        child: Text('あげる', style: TextStyle(fontSize: 80)),
        color: Colors.white,
        shape: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        onPressed: () {
          _form.currentState.save();
          Navigator.pushNamed(context, '/qrcode', arguments: payment);
        });

    KeyboardActionsConfig _buildConfig(BuildContext context) {
      return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: true,
        actions: [
          KeyboardActionsItem(
            focusNode: memoNode,
            toolbarButtons: [
              (node) {
                return GestureDetector(
                  onTap: () => node.unfocus(),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.close),
                  ),
                );
              },
            ],
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
          child: KeyboardActions(
              config: _buildConfig(context),
              child: CustomScrollView(slivers: <Widget>[
                SliverAppBar(
                    title: Image.asset('assets/title.png'),
                    backgroundColor: Color(0xffffffff),
                    elevation: 0, // hide shadow
                    toolbarHeight: 160),
                SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                  Form(
                      key: _form,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          dateWidget,
                          moneyWidget,
                          memoWidget,
                          giveWidget,
                        ],
                      ))
                ]))
              ]))),
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

class Qrcode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Payment payment = ModalRoute.of(context).settings.arguments;

    print(json.encode(payment));

    var date = Text(
        DateFormat.yMMMMEEEEd('ja')
            .format(payment.date)
            .replaceAllMapped(RegExp(r'(.)曜日'), (match) {
          return '(${match.group(1)})';
        }),
        style: TextStyle(fontSize: 24));

    var text =
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text(NumberFormat('#,##0').format(payment.money),
          style: TextStyle(fontSize: 24)),
      Container(width: 5),
      Text(
        'ブリ\nブリ',
        style: TextStyle(fontSize: 16),
      ),
    ]);

    final qr = QrImage(
      data: json.encode(payment),
      version: QrVersions.auto,
      // size: 320,
      // gapless: false,
      embeddedImage: AssetImage('assets/qricon.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: Size(50, 50),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("ブリブリ QRコード"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                date,
                Container(height: 10),
                text,
              ],
            ),
            qr,
          ],
        ),
      ),
    );
  }
}
