import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'payment.dart';

class Give extends StatefulWidget {
  Give({Key key}) : super(key: key);

  @override
  _GiveState createState() => _GiveState();
}

class _GiveState extends State<Give> {
  final _form = GlobalKey<FormState>();
  var payment = Payment(DateTime.now(), null, null, null);

  @override
  Widget build(BuildContext context) {
    final memoNode = FocusNode();

    var moneyWidget = Row(
      children: <Widget>[
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
            },
            validator: (value) {
              if (value.isEmpty) {
                return '数値を入力してください';
              }
            },
          ),
        ),
        Text(
          'ブリ\nブリ',
          style: TextStyle(fontSize: 24),
        ),
      ],
    );

    var memoWidget = TextFormField(
      decoration: InputDecoration(labelText: 'メモ', hintText: '例 ありがとう'),
      style: TextStyle(fontSize: 30),
      maxLength: 140,
      autofocus: false,
      keyboardType: TextInputType.multiline,
      // textInputAction: TextInputAction.done,
      maxLines: 2,
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
        if (_form.currentState.validate()) {
          _form.currentState.save();
          Navigator.pushNamed(context, '/giveqr', arguments: payment);
        }
      },
    );

    return Form(
      key: _form,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          moneyWidget,
          memoWidget,
          giveWidget,
        ],
      ),
    );
  }
}
