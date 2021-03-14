import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audio_cache.dart';

import 'payment.dart';

class Took extends StatefulWidget {
  const Took({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TookState();
}

class _TookState extends State<Took> {
  ConfettiController? _confetti;
  AudioCache? _audio;

  @override
  void initState() {
    super.initState();
    _initializeConfetti();
    _initializeAudio();
  }

  Future<void> _initializeConfetti() async {
    _confetti = ConfettiController(duration: const Duration(seconds: 10));
    _confetti!.play();
  }

  Future<void> _initializeAudio() async {
    _audio = AudioCache();

    if (Platform.isIOS) {
      if (_audio!.fixedPlayer != null) {
        _audio!.fixedPlayer.startHeadlessService();
      }
    }

    _audio!.play('buriburi.m4a');
  }

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
        title: Text("やったね! 🎉 "),
      ),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              maxBlastForce: 3, // set a lower max blast force
              minBlastForce: 1, // set a lower min blast force
              emissionFrequency: 0.05,
              // numberOfParticles: 50, // a lot of particles at once
              gravity: 0,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confetti?.dispose();
    super.dispose();
  }
}
