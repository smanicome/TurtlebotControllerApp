import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:turtlebot_controller/ControllerPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController firstController = TextEditingController(text: '192');
  TextEditingController secondController = TextEditingController(text: '168');
  TextEditingController thirdController = TextEditingController(text: '43');
  TextEditingController fourthController = TextEditingController(text: '179');

  FocusNode firstNode = FocusNode();
  FocusNode secondNode = FocusNode();
  FocusNode thirdNode = FocusNode();
  FocusNode fourthNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  Future<void> connect() async {
    var values = [
      firstController.text,
      secondController.text,
      thirdController.text,
      fourthController.text
    ];
    var ipAddress = values.join('.');

    ProgressHUD.of(context)?.show();

    var cameraStreamSocket =
        await Socket.connect(InternetAddress(ipAddress), 3698);
    var inputControlSocket =
        await Socket.connect(InternetAddress(ipAddress), 3699);

    ProgressHUD.of(context)?.dismiss();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ControllerPage(
            cameraStreamSocket: cameraStreamSocket,
            inputControlSocket: inputControlSocket,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  child: TextField(
                    autofocus: true,
                    textAlign: TextAlign.center,
                    focusNode: firstNode,
                    controller: firstController,
                    textInputAction: TextInputAction.next,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onChanged: (value) {
                      if (value.length == 3) {
                        secondNode.requestFocus();
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: Text(
                    '.',
                    textScaleFactor: 2,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    focusNode: secondNode,
                    textAlign: TextAlign.center,
                    controller: secondController,
                    textInputAction: TextInputAction.next,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onChanged: (value) {
                      if (value.length == 3) {
                        thirdNode.requestFocus();
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: Text(
                    '.',
                    textScaleFactor: 2,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    focusNode: thirdNode,
                    textAlign: TextAlign.center,
                    controller: thirdController,
                    textInputAction: TextInputAction.next,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onChanged: (value) {
                      if (value.length == 3) {
                        fourthNode.requestFocus();
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: Text(
                    '.',
                    textScaleFactor: 2,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    focusNode: fourthNode,
                    textAlign: TextAlign.center,
                    controller: fourthController,
                    textInputAction: TextInputAction.done,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onSubmitted: (text) => connect(),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: connect,
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
