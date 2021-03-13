import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'payment.dart';

class Took extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Payment payment =
        ModalRoute.of(context)!.settings.arguments as Payment;

    print(json.encode(payment));

    var date = Text(
        DateFormat.yMMMMEEEEd('ja')
            .format(payment.date!)
            .replaceAllMapped(RegExp(r'(.)曜日'), (match) {
          return '(${match.group(1)})';
        }),
        style: TextStyle(fontSize: 24));

    var money =
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text(NumberFormat('#,##0').format(payment.money),
          style: TextStyle(fontSize: 24)),
      Container(width: 5),
      Text(
        'ブリ\nブリ',
        style: TextStyle(fontSize: 16),
      ),
    ]);

    final memo = Text(
      payment.memo!.replaceAll('\n', ' ').replaceAll(RegExp(r' +'), ' '),
      maxLines: 1,
      // textHeightBehavior: TextHeightBehavior(),
      style: TextStyle(fontSize: 24, height: 1),
      overflow: TextOverflow.ellipsis,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('もらった!'),
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
                money,
                Container(height: 10),
                memo,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
