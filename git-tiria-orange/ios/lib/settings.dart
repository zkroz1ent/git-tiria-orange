// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:borneorange/secondmain.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'globals.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_switch/flutter_switch.dart';

// permet de definir la tree map de l'application
void main() {
  runApp(
    MaterialApp(
      title: 'Named Routes Demo',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/seconde',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/second': (context) => const App(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/settings': (context) => const Setting(),
      },
    ),
  );
}

//page de login

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    {
      return const MaterialApp(
        title: 'settings',
        home: Setting(),
      );
    }
  }
}

// Define a custom Form widget.
class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _SettingState extends State<Setting> {
//permet a l initialisation de l application de lancer ci dessous fonction

  Future<bool> onbackpress() async {
    return true;
  }

  @override
  void initState() {
    read_Kioskemode();

    Future.delayed(Duration(seconds: 10))
        .then((value) => SystemChrome.setEnabledSystemUIOverlays([]));

    super.initState();
    read_code();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    super.dispose();
  }

  Future<File> get setting async {
    final path = await _localPath;
    return File('$path/settings.txt');
  }

  Future<File> writeModekioske(String etat) async {
    final file = await setting;

    // Write the file
    return file.writeAsString(etat);
  }

  bar() {
    Future.delayed(Duration(seconds: 2))
        .then((value) => SystemChrome.setEnabledSystemUIOverlays([]));
  }

  read_Kioskemode() async {
    final file = await setting;

    // Read the file
    String kioske = await file.readAsString();

    setState(() {
      _kioskeEtat = kioske;
    });
  }

  read_code() async {
    final file = await _localFile;

    // Read the file
    String code = await file.readAsString();

    setState(() {
      _code = code;
    });
  }

//retourn le repertoire app
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

//permet de recuperer repertoire app plus le nom du fichier
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/code.txt');
  }

//permet de recuperer repertoire app plus le nom du fichier
  Future<File> get _localFile1 async {
    final path = await _localPath;
    return File('$path/idandroid.txt');
  }

//permet de d'ecrire
  Future<File> writeid_android(String device) async {
    final file = await _localFile1;

    // Write the file
    return file.writeAsString(device);
  }

//permet de d'ecrire
  Future<File> writecode(String code) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(code);
  }

//READ ID ANDROID
  readid_android() async {
    final file = await _localFile;
    final file1 = await _localFile1;
    // Read the file
    String code = await file.readAsString();
    String id_android = await file1.readAsString();
  }

//READ ID ANDROID 1 time
  readid_android1(Map<String, String> device) async {
    final file = await _localFile;
    final file1 = await _localFile1;
    // Read the file
    String code = '';
    String id_android = '';
  }

  couleur() {
    if (isSwitched == true) {
      return Colors.white;
    } else if (isSwitched == false) {
      return Color.fromRGBO(255, 120, 0, 1);
    }
  }
  //partie api

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  final codeKiosk = TextEditingController();
  int _etat = 1;
  String _code = '';
  String _kioskeEtat = '0';

//permet de creer la page puis de faire appelle a l'api
  @override
  Widget build(BuildContext context) {
    home:
    Scaffold(
        /*appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text('Ateliers numriques'),
      ),*/

        );

    if (_kioskeEtat == '1') {
      bool isSwitched = true;
    } else if (_kioskeEtat == '0') {
      bool isSwitched = false;
    }

    return Scaffold(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        body: Column(children: <Widget>[
          Container(
            color: Colors.black,
            child: AppBar(
              automaticallyImplyLeading: false, // hides leading widget
              flexibleSpace: Container(
                margin: EdgeInsets.all(20.0),
                child: Container(
                    child: Row(children: <Widget>[
                  Image(
                    alignment: AlignmentDirectional.center,
                    image: AssetImage('lib/assets/logo-orange.jpg'),
                  ),
                  Container(
                    margin: EdgeInsets.all(20.0),
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      "Paramètres",
                      style: TextStyle(fontSize: 30.0, color: Colors.white),
                    ),
                  ),
                ])),
              ),

              elevation: 0.0,
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          Column(children: <Widget>[
            Container(
              height: 200,
            ),
            Text(
              "Désactiver blocage appareil",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            Container(height: 20),
            Container(
              child: FlutterSwitch(
                activeColor: Color.fromRGBO(255, 120, 0, 1),
                activeTextColor: Colors.white,
                inactiveColor: Colors.white,
                inactiveTextColor: Color.fromRGBO(255, 120, 0, 1),
                width: 125.0,
                height: 55.0,
                valueFontSize: 25.0,
                toggleSize: 45.0,
                value: isSwitched,
                borderRadius: 30.0,
                padding: 8.0,
                showOnOff: true,
                toggleColor: couleur(),
                onToggle: (val) {
                  setState(() {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Color.fromARGB(250, 0, 0, 1),
                            title: Text(
                              'Desactiver avec code Kioske',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                            content: TextField(
                              controller: codeKiosk,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Saisir code',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.immersiveSticky);
                              },
                              toolbarOptions: bar(),
                              onTap: bar(),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                color: Color.fromRGBO(255, 120, 0, 1),
                                textColor: Colors.white,
                                child: Text('CANCEL'),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              FlatButton(
                                color: Color.fromRGBO(255, 120, 0, 1),
                                textColor: Colors.white,
                                child: Text('OK'),
                                onPressed: () {
                                  String etat = '1';
                                  if (codeKiosk.text == _code) {
                                    codeKiosk.text = '';
                                    print(_kioskeEtat);
                                    if (_kioskeEtat == '1') {
                                      etat = '0';
                                      writeModekioske(etat);
                                      read_Kioskemode();
                                      isSwitched = false;
                                      stopKioskMode();
                                      Navigator.pop(context, false);
                                      bar();
                                    } else if (_kioskeEtat == '0') {
                                      SystemChrome.setEnabledSystemUIMode(
                                          SystemUiMode.immersiveSticky);
                                      startKioskMode();
                                      etat = '1';
                                      writeModekioske(etat);
                                      read_Kioskemode();
                                      isSwitched = true;
                                      Navigator.pop(context, false);
                                    }
                                    bar();
                                  } else if (codeKiosk.text != '' &&
                                      codeKiosk.text != _code) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          // Retrieve the text the that user has entered by using the
                                          // TextEditingController.
                                          content: Text('Error Code'),
                                        );
                                      },
                                    );
                                    bar();
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          // Retrieve the text the that user has entered by using the
                                          // TextEditingController.
                                          content: Text('Veuillez saisir code'),
                                        );
                                        print('oui');
                                      },
                                    );
                                    bar();
                                  }

                                  bar();
                                },
                              ),
                            ],
                          );
                          print('oui');
                        });
                    bar();
                    if (_kioskeEtat == '1') {
                      isSwitched = true;
                      val = isSwitched;
                    } else if (_kioskeEtat == '0') {
                      isSwitched = false;
                      val = isSwitched;
                    }
                    child:
                    SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky);
                  });
                  child:
                  SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.immersiveSticky);
                  print('oui');
                },
              ),
            ),
          ]),
          Container(
              height: 300,
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                child: const Text('retour',
                    style: TextStyle(fontSize: 26.0, color: Colors.white)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => App(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(255, 120, 0, 1),
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0)),
              )),
        ]));
  }
}
//Deuxieme page secondaire pour faire des testes


            

         