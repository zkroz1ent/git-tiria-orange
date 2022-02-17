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
import'package:borneorange/settings.dart';

// permet de definir la tree map de l'application
void main() {
  runApp(
    MaterialApp(
      title: 'Named Routes Demo',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const MyCustomForm(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => const App(),
        '/settings':(context)=> const Setting(),
      },
    ),
  );
}

//page de login

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
//constructeur de la page
  @override
  Widget build(BuildContext context) {
    {
      return const MaterialApp(
        title: 'entrez votre code pour Activer l"application',
        home: MyCustomForm(),
      );
    }
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
//permet a l initialisation de l application de lancer ci dessous fonction

  @override
  void initState() {
    isSwitched=true;
    if (isSwitched == true) {
     startKioskMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
   
    super.initState();
    print(initPlatformState());
    checkGps();
    print(_info_local);
    writeModekioske();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
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
   Future<File> get setting async {
    final path = await _localPath;
    return File('$path/settings.txt');
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
 Future<File> writeModekioske() async {
    final file = await setting;

    // Write the file
    return file.writeAsString('1');
  }
//READ ID ANDROID
  readid_android() async {
    final file = await _localFile;
    final file1 = await _localFile1;
    // Read the file
    String code = await file.readAsString();
    String id_android = await file1.readAsString();

    Map<String, String> device = {
      "device_uuid": await id_android,
      "code_activation": await code,
      "webapp_id": await webappsID,
      "localisation": await '(long:' + long + ',lat:' + lat + ')',
      "num_rue": await _info_local['num_rue']??'',
      "rue": await _info_local['rue']??'',
      "ville": await _info_local['ville']??'',
      "departement": await _info_local['departement']??''
    };

    api(device, code, id_android);
  }

//READ ID ANDROID 1 time
  readid_android1(Map<String, String> device) async {
    final file = await _localFile;
    final file1 = await _localFile1;
    // Read the file
    String code = '';
    String id_android = '';

    api(device, code, id_android);
  }

  //partie api
  api(Map<String, String> device, String code, String id_android) async {
    String? device_uuid = device['device_uuid'];
    writeid_android(device_uuid!);
//try catch pour savoir si on est bien connecté a internet
    try {
      if (code == '') {
        //api envoie recois
        var jsonenvoie = convert.jsonEncode(device);
        print(jsonenvoie);
        var url = api_url1 + jsonenvoie;
        // Await the http get response, then decode the json-formatted response.
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          var jsonResponse = convert.jsonDecode(response.body);
          print(jsonResponse);

//retour
          if (jsonResponse['msg'] == 'VALIDATE') {
//se connecter directement a la deuxieme page
            writecode('${device["code_activation"]}');
             return {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  App(),
                              transitionDuration: Duration.zero,
                            ),
                          ),
                        };
          } else if (jsonResponse['msg'] == 'ERROR INVALID CODE') {
            var url = api_url2 + jsonenvoie;
            // Await the http get response, then decode the json-formatted response.
            var response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              var jsonResponse = convert.jsonDecode(response.body);
              print(jsonResponse);
              if (jsonResponse['msg'] == 'VALIDATE') {
//se connecter directement a la deuxieme page
                writecode('${device["code_activation"]}');

                return {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  App(),
                              transitionDuration: Duration.zero,
                            ),
                          ),
                        };
              }
              //sinon envoie une pop-up
              if (jsonResponse['msg'] == 'ERROR INVALID CODE') {
                myController1.text =
                    "Veuillez saisir un code d'activation valide";

                return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      // Retrieve the text the that user has entered by using the
                      // TextEditingController.
                      content: Text(myController1.text),
                    );
                  },
                );
              }
//permet de soir si campagne active
              if (jsonResponse['TIME_END'] != '') {
                myController1.text =
                    "Votre code d'activation n'est plus valide depuis " +
                        jsonResponse['TIME_END'] +
                        " j";
                return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      // Retrieve the text the that user has entered by using the
                      // TextEditingController.
                      content: Text(myController1.text),
                    );
                  },
                );
              }
//permet de soir si campagne active
              if (jsonResponse['TIME_START'] != '') {
                myController1.text =
                    "Votre code d'activation sera valide dans j- " +
                        jsonResponse['START'];

                return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      // Retrieve the text the that user has entered by using the
                      // TextEditingController.
                      content: Text(myController1.text),
                    );
                  },
                );
              }

              return jsonResponse;
            } else {
              print('ERROR');
            }
          }
        }
      } else if (code != '') {
        device["code_activation"] = code;
        device["device_uuid"] = device_uuid;
        var jsonenvoie = convert.jsonEncode(device);
        print(jsonenvoie);
        var url = api_url1 + jsonenvoie;
        // Await the http get response, then decode the json-formatted response.
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          var jsonResponse = convert.jsonDecode(response.body);
          print(jsonResponse);

          if (jsonResponse['msg'] == 'VALIDATE') {
//se connecter directement a la deuxieme page

            return    Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => App(),
                      transitionDuration: Duration.zero,
                    ),
                  );
          } else if (jsonResponse['msg'] == 'ERROR INVALID CODE') {
            var url = api_url2 + jsonenvoie;
            // Await the http get response, then decode the json-formatted response.
            var response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              var jsonResponse = convert.jsonDecode(response.body);
              print(jsonResponse);
              if (jsonResponse['msg'] == 'VALIDATE') {
//se connecter directement a la deuxieme page

                return    Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => App(),
                      transitionDuration: Duration.zero,
                    ),
                  );
              }

              if (jsonResponse['msg'] == 'ERROR INVALID CODE') {
                myController1.text =
                    'Veuillez saisir un code d"activation valide';

                return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      // Retrieve the text the that user has entered by using the
                      // TextEditingController.
                      content: Text(myController1.text),
                    );
                  },
                );
              }

              if (jsonResponse['msg'] == 'Campaign_Stat') {
                if (jsonResponse['TIME_END'] != '') {
                  myController1.text =
                      "Votre code d'activation n'est plus valide depuis " +
                          jsonResponse['TIME_END'] +
                          " j";
                  return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        // Retrieve the text the that user has entered by using the
                        // TextEditingController.
                        content: Text(myController1.text),
                      );
                    },
                  );
                } else if (jsonResponse['TIME_START'] != '') {
                  myController1.text =
                      "Votre code d'activation sera valide dans j- " +
                          jsonResponse['START'];
                  return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        // Retrieve the text the that user has entered by using the
                        // TextEditingController.
                        content: Text(myController1.text),
                      );
                    },
                  );
                }
              }
              return jsonResponse;
            } else {
              print('ERROR');
            }
          }
        }
      }
    } on SocketException catch (_) {
      myController1.text = 'Veullez-vous connecter à Internet';

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // Retrieve the text the that user has entered by using the
            // TextEditingController.
            content: Text(myController1.text),
          );
        },
      );
    }
  }

//permet de determiner la position actuelle

//permet de recuperer les variables saisient dans l app de les associer
  final myController = TextEditingController();
  final myController1 = TextEditingController();
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  Map<String, dynamic> _info_local = <String, dynamic>{};
  Map<String, dynamic> _info = <String, dynamic>{};
  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
//prends toutes les caracteristiques de l'appereil
    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          deviceData =
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        } else if (Platform.isLinux) {
          deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        } else if (Platform.isWindows) {
          deviceData =
              _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

//prend caracterique de l'appareil
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

//prend caracterique de l'appareil
  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

//prend caracterique de l'appareil
  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

//prend caracterique de l'appareil
  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': describeEnum(data.browserName),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

//prend caracterique de l'appareil
  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

//prend caracterique de l'appareil
  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    };
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        long = position.longitude.toString();
        lat = position.latitude.toString();

        LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high, //accuracy of the location data
          distanceFilter: 100, //minimum distance (measured in meters) a
          //device must move horizontally before an update event is generated;
        );

        StreamSubscription<Position> positionStream =
            Geolocator.getPositionStream(locationSettings: locationSettings)
                .listen((Position position) {
          long = position.longitude.toString();
          lat = position.latitude.toString();
        });

        double lat1;
        double long1;
        lat1 = double.parse(lat);
        long1 = double.parse(long);

        _getPlace(long1, lat1);
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }
  }

//permets de connaitre une adresse precise

  _getPlace(double long, double lat) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    print(placemarks[0]);
    Map<String, dynamic> info() {
      return <String, dynamic>{
        'num_rue': placemarks[0].name,
        'rue': placemarks[0].thoroughfare,
        'ville': placemarks[0].locality,
        'departement': placemarks[0].subAdministrativeArea
      };
    }

    setState(() {
      _info_local = info();
    });
  }

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

//permet de creer la page puis de faire appelle a l'api
  @override
  Widget build(BuildContext context) {
    readid_android();

    // readid_android(device);
    return Scaffold(
      body: Column(children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 250.0),
        ),
        Container(
          child: Image.asset(
            'lib/assets/logoOrange500.png' ,
            width: 100,
            height: 100,
          ),
          color: Colors.black,
          alignment: Alignment.topCenter,
        ),
        Container(
          alignment: Alignment.bottomCenter,
          color: Colors.black,
          child: Text(
            "Entrez votre code pour Activer l'application",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          height: 110,
        ),
        Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 250.0),
          child: TextField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Saisir code',
              border: InputBorder.none,
            ),
            cursorColor: Colors.white,
            controller: myController,
            style: TextStyle(color: Colors.black),
          ),
        ),
        SizedBox(
          width: 200.0,
          height: 200.0,
          child: FittedBox(
            child: FloatingActionButton(
              // When the user presses the button, show an alert dialog containing
              // the text that the user has entered into the text field.

              onPressed: () {
                //  readid_android();
                Map<String, String> device = {
                  "device_uuid": _deviceData['androidId']??'',
                  "code_activation": myController.text,
                  "localisation": '(long:' + long + ',lat:' + lat + ')',
                  'webapp_id': webappsID,
                  "num_rue": _info_local['num_rue']??'',
                  'rue': _info_local['rue']??'',
                  'ville': _info_local['ville']??'',
                  'departement': _info_local['departement']??''
                };

                writecode(myController.text);
                readid_android1(device);
                print(_info_local);
              },

              backgroundColor: Color.fromRGBO(255, 120, 0, 1),

              child: Text("Valider".toUpperCase(),
                  style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),
        ),

        //permet d'afficher version en cours et le num de l'appareil
        Container(
          color: Colors.black,
          child: Text("Version:$version device:${_deviceData['androidId']}",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 13, color: Colors.white)),
          alignment: Alignment.bottomLeft,
          height: 154,
        ),
      ]),
      backgroundColor: Colors.black,
    );
  }
}

//Deuxieme page secondaire pour faire des testes


