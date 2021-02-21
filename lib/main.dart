import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import 'give.dart';
import 'giveqr.dart';

void main() {
  runApp(BuriBuriApp());
}

class BuriBuriApp extends StatelessWidget {
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
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => BuriBuri(),
          '/giveqr': (BuildContext context) => GiveQr(),
        });
  }
}

class BuriBuri extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                  title: Image.asset('assets/title.png'),
                  backgroundColor: Color(0xffffffff),
                  elevation: 0, // hide shadow
                  toolbarHeight: 180),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    Give(),
                  ],
                ),
              ),
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
      ),
    );
  }
}
