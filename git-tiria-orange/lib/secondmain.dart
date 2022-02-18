import 'dart:convert';
import 'dart:io';
//import 'dart:ffi';

/*import 'package:flutter/cupertino.dart';*/
import 'package:borneorange/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'main.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart' as globals;
import 'package:borneorange/hello.dart';
import 'package:borneorange/components/details.dart';
import 'package:borneorange/components/detailsphysique.dart';
import 'package:borneorange/components/globales.dart';
import 'package:path_provider/path_provider.dart';
import 'package:borneorange/settings.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          /*appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text('Ateliers numriques'),
      ),*/
          body: Center(child: Hello()),
        ),
        theme: ThemeData(
          primaryColor: Color(0xffff7900),
          colorScheme: ColorScheme.light(primary: Color(0xffff7900)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                primary: Color(0xffff7900),
                textStyle: TextStyle(fontSize: 26.0, color: Colors.black),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0)),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                primary: Color(0xffff7900),
                textStyle: TextStyle(fontSize: 25.0)),
          ),
          textTheme: const TextTheme(
            headline1: TextStyle(
                fontSize: 40.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            headline2: TextStyle(
                fontSize: 30.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            headline3: TextStyle(
                fontSize: 34.0,
                color: Color(0xffff7900),
                fontWeight: FontWeight.bold),
            headline4: TextStyle(
                fontSize: 22.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 48.0, color: Colors.black),
            bodyText1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),

          // Define the default font family.
          //fontFamily: 'Georgia',
        ),

        /*initialRoute: '/',*/
        routes: <String, WidgetBuilder>{
          '/main': (BuildContext context) => Home(),
          //'/b': (BuildContext context) => Details(evtSlug: context),
          '/hello': (BuildContext context) => Hello(),
        },
      );
}

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  late final Stream<KioskMode> _currentMode = watchKioskMode();
  Events? listEvt;
  PhysicalEvents? listEvtPhys;
  bool filterOnline = true;
  int _etat = 1;
  bool filterphysical = true;
  KioskMode mode = KioskMode.enabled;
  String _code = '';
  String _kioskeEtat = '';
  //final Future<Map<String, dynamic>> retourApi = Future<Map<String, dynamic>>.value(() => getEventsList());

  @override
  initState() {
    super.initState();
    //getApiStartup();
    read_code();
    read_Kioskemode();
    if (globals.isSwitched == true) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<bool> backPress() async {
    print("hellp");
    return false;
  }

  getsKioske() async {
    mode = await getKioskMode();
    print(mode);
    return mode;
  }

  startKiosk() async {
    return await startKioskMode();
  }

  stopKiosk() async {
    return await stopKioskMode();
  }

  Future<Map<String, dynamic>> getEventsList() async {
    final response = await http.get(
      Uri.parse(globals.apiURI + 'events/' + globals.slug),
    );
    if (response.statusCode == 200) {
      //Navigator.pushNamed(context, '/main');
      Map<String, dynamic> mappe = jsonDecode(response.body);
      return mappe;
    } else {
      print("exception");
      throw Exception('Failed to load events');
    }
  }

  disconnect() {
    if (globals.isSwitched == false) {
      writecode();
      return IconButton(
        color: Color.fromARGB(255, 255, 255, 255),
        icon: Icon(Icons.power_settings_new_sharp),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => MyApp(),
              transitionDuration: Duration.zero,
            ),
          );
        },
      );
    } 
    return  Container();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get setting async {
    final path = await _localPath;
    return File('$path/settings.txt');
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/code.txt');
  }
Future<File> writecode() async {
  String code='';
    final file = await _localFile;

    // Write the file
    return file.writeAsString(code);
  }
  read_code() async {
    final file = await _localFile;

    // Read the file
    String code = await file.readAsString();

    setState(() {
      _code = code;
    });
  }

  read_Kioskemode() async {
    final file = await setting;

    // Read the file
    String kioske = await file.readAsString();

    setState(() {
      _kioskeEtat = kioske;
    });
  }

  final codeKiosk = TextEditingController();
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
        future: getEventsList(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          //List<Widget> children;

          Widget filterButtons = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                width: 60,
                child: Text("Filtrer : "),
              ),
              Container(
                width: 250,
                child: SwitchListTile(
                  title: const Text('Ateliers en ligne'),
                  value: filterOnline,
                  onChanged: (bool value) {
                    setState(() {
                      filterOnline = value;
                    });
                  },
                ),
              ),
              Container(
                width: 270,
                child: SwitchListTile(
                  title: const Text('Ateliers en physique'),
                  value: filterphysical,
                  onChanged: (bool value) {
                    setState(() {
                      filterphysical = value;
                    });
                  },
                ),
              ),
              Spacer(),
            ],
          );
          if (snapshot.hasData) {
            List<dynamic> onlineW = snapshot.data!['onlineWorkshop'];
            List<dynamic> physicalW = snapshot.data!['physicalWorkshop'];
            return Scaffold(
              appBar: PreferredSize(
                child: AppBar(
                    automaticallyImplyLeading: false, // hides leading widget
                    flexibleSpace: Container(
                      margin: EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Image(
                            image: AssetImage('lib/assets/logo-orange.jpg'),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            'Ateliers numériques',
                            style:
                                TextStyle(fontSize: 30.0, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    elevation: 0.0,
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                    actions: <Widget>[
                      disconnect(),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  Home(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                      IconButton(
                          icon: Icon(Icons.lock),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                              return Settings();
                            }), (Route<dynamic> route) => false);
                          })
                    ]),
                preferredSize: Size.fromHeight(90.0),
              ),
              body: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        // display these more correctly
                        filterButtons,
                        if (filterOnline) SizedBox(height: 12),
                        if (filterOnline)
                          OnlineWorkshop(listeAteliers: onlineW),
                        if (filterphysical) SizedBox(height: 12),
                        if (filterphysical)
                          PhysicalWorkshop(listeAteliers: physicalW),
                      ],
                    )),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                  child: Center(
                      child: Text("Aucun atelier disponible",
                          style: Theme.of(context).textTheme.headline4))),
            );
          } else {
            return Scaffold(
              /*appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text('Ateliers numriques'),
      ),*/
              body: Container(
                padding: const EdgeInsets.all(60.0),
                child: Column(
                  children: [
                    filterButtons,
                    CircularProgressIndicator(),
                    Text("Chargement..."),
                  ],
                ),
              ),
            );
          }
        },
      );

  String fromHtml(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

/*

Text(
                  snapshot.data![1]["name"],
                  style: Theme.of(context).textTheme.headline5,
                ),


List.generate(retourApi.length, (index) {
        return Center(
          child: Text(
            'Item $index',
            style: Theme.of(context).textTheme.headline5,
          ),
        );
      }),


@override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(retourApi),
      MaterialButton(
        onPressed: getFromApi,
        child: Text('get from api'),
      ),
      if (Platform.isAndroid) ...[
        MaterialButton(
          onPressed: startKiosk,
          child: Text('Start Kiosk Mode'),
        ),
        const MaterialButton(
          onPressed: stopKioskMode,
          child: Text('Stop Kiosk Mode'),
        ),
      ],
      MaterialButton(
        onPressed: () => getKioskMode().then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kiosk mode: $value')),),
        ),
        child: const Text('Check mode'),
      ),
      if (Platform.isIOS)
        StreamBuilder<KioskMode>(
          stream: _currentMode,
          builder: (context, snapshot) => Text(
            'Current mode: ${snapshot.data}',
          ),
        ),

    ],
  );*/
}

class Events {
  final List<dynamic> elist;

  Events({
    required this.elist,
  });

  factory Events.fromJson(Map<String, dynamic> json) {
    List<dynamic> specif = json['onlineWorkshop'];
    return Events(
      elist: specif,
    );
  }

  List<dynamic> getEvents() {
    return elist;
  }

  @override
  String toString() {
    return elist as String;
  }
}

class PhysicalEvents {
  final List<dynamic> elist;

  PhysicalEvents({
    required this.elist,
  });

  factory PhysicalEvents.fromJson(Map<String, dynamic> json) {
    List<dynamic> specif = json['physicalWorkshop'];
    return PhysicalEvents(
      elist: specif,
    );
  }

  List<dynamic> getEvents() {
    return elist;
  }

  @override
  String toString() {
    return elist as String;
  }
}

abstract class Workshops extends StatelessWidget {
  Workshops(
      {Key? key,
      required List<dynamic> this.listeAteliers,
      required String this.texteTitre,
      required String this.texteSsTitre})
      : super(key: key);
  final List<dynamic> listeAteliers;
  final String texteTitre;
  final String texteSsTitre;

  @override
  Widget build(BuildContext context) {
    List<Widget> ateliers;

    ateliers = <Widget>[
      Text(texteTitre,
          style: Theme.of(context).textTheme.headline1,
          textAlign: TextAlign.left),
      Text(texteSsTitre, style: Theme.of(context).textTheme.headline2),
      const SizedBox(height: 16),
      GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        shrinkWrap: true,
        crossAxisSpacing: 10,
        mainAxisSpacing: 30,
        //childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height*2.16),
        childAspectRatio: (MediaQuery.of(context).size.height * 0.00091),
        // Generate list of cards with online activities
        children: List.generate(listeAteliers.length, (index) {
          return Center(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.network(
                    globals.imageURI + listeAteliers[index]["img"],
                    fit: BoxFit.fitWidth,
                    height: 200,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(listeAteliers[index]["title"],
                        style: Theme.of(context).textTheme.headline4),
                    subtitle: Text(
                        fromHtml(listeAteliers[index]["short_description"]),
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 16),
                      ElevatedButton(
                          child: const Text('Découvrir & s\'inscrire',
                              style: TextStyle(
                                  fontSize: 26.0, color: Colors.black)),
                          onPressed: () => openDetails(context, index)),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        }),
      ),
    ];

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: ateliers);
  }

  void openDetails(context, index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Details(evtSlug: listeAteliers[index]["slug"])),
    );
  }

  String fromHtml(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}

class OnlineWorkshop extends Workshops {
  OnlineWorkshop({Key? key, required List<dynamic> this.listeAteliers})
      : super(
            key: key,
            listeAteliers: listeAteliers,
            texteTitre: "Nos ateliers en ligne",
            texteSsTitre:
                "Accessibles à distance depuis votre téléphone et un écran connecté à internet.");
  final List<dynamic> listeAteliers;

  @override
  void openDetails(context, index) {
    globals.userInter();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Details(evtSlug: listeAteliers[index]["slug"])),
    );
  }

  String fromHtml(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}

class PhysicalWorkshop extends Workshops {
  PhysicalWorkshop({Key? key, required List<dynamic> this.listeAteliers})
      : super(
            key: key,
            listeAteliers: listeAteliers,
            texteTitre: "Nos ateliers en physique",
            texteSsTitre:
                "Accessibles en boutique Orange et dans des tiers-lieux (collectivités, associations...).");
  final List<dynamic> listeAteliers;

  @override
  void openDetails(context, index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              DetailsPhysique(evtSlug: listeAteliers[index]["slug"])),
    );
  }

  String fromHtml(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}

bool _allow = true;

@override
Widget build(BuildContext context) {
  return WillPopScope(
    child: Scaffold(appBar: AppBar(title: Text("Back"))),
    onWillPop: () {
      return Future.value(_allow);
      // if true allow back else block it
    },
  );
}
