import 'dart:async';
import 'dart:convert';
//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

import 'package:borneorange/secondmain.dart';

import 'globals.dart' as globals;

// Utilisé pour l'écran du "hello"

class Hello extends StatefulWidget {
  Hello({
    Key? key,
  }) : super(key: key);


  @override
  State<Hello> createState() => HelloState();
}

class HelloState extends State<Hello> {

  Future<Map<String, dynamic>> getAutorisation() async {
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Home(),
          transitionDuration: Duration.zero,
        ),
      );
    });

    return {};
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: getAutorisation(),
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
      return(Scaffold(
        /*appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text('Ateliers numriques'),
      ),*/
        body: Center(child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text("Verifications..."),
            ],
          ),
        )),
      ));
      }
  );

}
// Hello hello