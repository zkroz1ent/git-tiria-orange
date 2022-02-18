library borneorange.globals;

import 'dart:ffi';

import 'package:async/async.dart';
import 'package:flutter/material.dart';


final  version ='1.0';
var device_uuid='';
final api_url1 ='http://192.168.0.159/cpanel.mycombox.fr/api/device_orange_api.php?insert_get=';
final api_url2 ='http://192.168.0.159/cpanel.mycombox.fr/api/device_orange_api.php?verify_get=';
final webappsID ='19';


late bool isSwitched ;




String apiURI = "https://inscription.orange.fr/backend/api/";
String imageURI = "https://inscription.orange.fr/backend/uploads/images/";
/*
String apiURI = "https://preprod-inscription-orange.as44099.com/backend/api/";
String imageURI = "https://preprod-inscription-orange.as44099.com/backend/uploads/images/";*/
String slug = "ateliersnumeriques";

Map<String, dynamic>? userProfileCache;

class RIKeys {
 dynamic  navKey ='';
   
}
 
RestartableTimer? _timer;

void autoDstr() async {
  print("started user data timer");
  _timer = new RestartableTimer(Duration(seconds: 20), () {
      print("destroyed user data");

      var navKey1;
      showDialog<void>(
        context: navKey1.currentContext!,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Toujours là ?"),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('(a voir pour le texte)'),
                  Text('Etes-vous la meme personne ?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('oui'),
                onPressed: () {
                  _timer!.reset();
                  //userProfileCache = null;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('non'),
                onPressed: () {
                  userProfileCache = null;
                  //Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          );
        },
      );



  });

  print(_timer.toString());
}

// TODO: detect tap on screen
void userInter() async {
  if (_timer != null && _timer!.isActive) {
    _timer!.reset();
    print("reset timer");
    print(_timer.toString());
  }
}

void stopTimer() async {
  if (_timer != null && _timer!.isActive) {
    _timer!.cancel();
    print("stop timer");
    print(_timer.toString());
  }
}