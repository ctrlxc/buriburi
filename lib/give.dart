import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'payment.dart';

class Give extends StatefulWidget {
  Give({Key? key}) : super(key: key);

  @override
  _GiveState createState() => _GiveState();
}

class _GiveState extends State<Give> {
  final _formKey = GlobalKey<FormState>();
  var payment = Payment(DateTime.now(), null, null);

  @override
  Widget build(BuildContext context) {
    final moneyNode = FocusNode();
    final memoNode = FocusNode();

    final moneyWidget = Row(
      children: <Widget>[
        Flexible(
          child: TextFormField(
            focusNode: moneyNode,
            decoration: InputDecoration(
              labelText: 'いくら？',
              hintText: '123',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            style: TextStyle(fontSize: 30),
            // autofocus: false,
            textAlign: TextAlign.right,
            autofocus: true,
            maxLength: 8,
            // keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            keyboardType:
                TextInputType.numberWithOptions(signed: true, decimal: true),
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            onChanged: (_) {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }
            },
            onFieldSubmitted: (_) {
              // memoNode.requestFocus();
            },
            onSaved: (String? value) {
              payment.money = int.tryParse(value ?? '', radix: 10);
            },
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !new RegExp(r'^[0-9]{1,8}$').hasMatch(value)) {
                moneyNode.requestFocus();
                return 'すうじをいれてね';
              }
              return null;
            },
          ),
        ),
        Text(
          'ブリ\nブリ',
          style: TextStyle(fontSize: 24),
        ),
      ],
    );

    final memoWidget = TextFormField(
      decoration: InputDecoration(
        labelText: 'メモ',
        hintText: 'いつもありがとう',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      style: TextStyle(fontSize: 30),
      maxLength: 140,
      autofocus: false,
      keyboardType: TextInputType.multiline,
      // textInputAction: TextInputAction.done,
      maxLines: 3,
      focusNode: memoNode,
      onSaved: (String? value) {
        payment.memo = value;
      },
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('あげる？'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                moneyWidget,
                memoWidget,
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              FocusScope.of(context).unfocus();
              _formKey.currentState!.save();
              Navigator.of(context)
                  .pushReplacementNamed('/giveqr', arguments: payment);
            }
          },
          tooltip: 'あげる',
          child: Text('あげる', style: TextStyle(fontSize: 80)),
        ),
      ),
    );
  }
}
