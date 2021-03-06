import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';

import 'give.dart';
import 'giveqr.dart';
import 'take.dart';

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
        '/give': (BuildContext context) => Give(),
        '/giveqr': (BuildContext context) => GiveQr(),
        '/take': (BuildContext context) => Take(),
      },
    );
  }
}

class BuriBuri extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
                  <Widget>[],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/give');
              },
              tooltip: 'あげる？',
              child: Text('あげる？', style: TextStyle(fontSize: 32)),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
            FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/take');
              },
              tooltip: 'もらう？',
              child: Text('もらう？', style: TextStyle(fontSize: 32)),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          // color: Theme.of(context).primaryColor,
          // notchMargin: 6.0,
          shape: AutomaticNotchedShape(
            RoundedRectangleBorder(),
            StadiumBorder(
              side: BorderSide(),
            ),
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.history),
                tooltip: 'きろく',
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings),
                tooltip: 'せってい',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
