import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:borneorange/globals.dart' as globals;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';
import 'package:borneorange/components/inscription.dart';
import 'package:borneorange/components/details.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class DetailsPhysique extends StatefulWidget {
  const DetailsPhysique({
    Key? key,
    required String this.evtSlug
  }) : super(key: key);
  final String evtSlug;

  @override
  State<DetailsPhysique> createState() => DetailPhysiqueState();
}

class DetailPhysiqueState extends State<DetailsPhysique> {
  final _scrollController = ScrollController();
  int _selectedRegion = -1;
  int _selectedCity = -1;
  int _selectedLocation = -1;
  late List<Widget> dates = <Widget>[];
  Map<String, dynamic>? evtInfoCache;
  Widget slotsSpace = Container();
  MapController mapController = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: 46.522674, longitude: 3.242666),
    areaLimit: BoundingBox( east: 10.4922941, north: 47.8084648, south: 45.817995, west: 5.9559113,),
  );
  /*late final Stream<KioskMode> _currentMode = watchKioskMode();*/

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: getEventInfo(),
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
      List<Widget> children;
      if (snapshot.hasData) {

        if (snapshot.data!["regions"]is Map<String, dynamic>) {
          Map<String, dynamic> dt=snapshot.data!["regions"];
          String selection = "";
          String topText = "";
          String? locName;
          String? cityName;
          String? regName;
          String? complement;
          if (_selectedLocation != -1) {
            locName = dt.values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity)["places"].values.elementAt(_selectedLocation)["name"];
            cityName = dt.values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity)["name"];
            regName = dt.values.elementAt(_selectedRegion)["name"];
            dt = dt.values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity)["places"];
            complement = dt.values.elementAt(_selectedLocation)["address_complement"] != null ? dt.values.elementAt(_selectedLocation)["address_complement"] + " " : "";
            selection = "reviewselection";
            topText = "Vous avez choisi :";
          } else if (_selectedCity != -1) {
            cityName = dt.values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity)["name"];
            regName = dt.values.elementAt(_selectedRegion)["name"];
            dt = dt.values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity)["places"];
            selection = "location";
            topText = "Choisissez votre lieu";
          } else if (_selectedRegion != -1) {
            regName = dt.values.elementAt(_selectedRegion)["name"];
            selection = "city";
            topText = "Choisissez votre ville";
            dt = dt.values.elementAt(_selectedRegion)["cities"];
          } else {
            selection = "region";
            topText = "Choisissez votre région";
              //do nothing
          }
          print(selection);
          dates=<Widget>[
            Text("$topText",style: Theme.of(context).textTheme.headline3),
            if (selection != "reviewselection") Container(
              height: 350,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_selectedRegion != -1) Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
                            dense:true,
                            title: Text(regName!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedCity != -1) Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
                            dense:true,
                            title: Text(cityName!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: dt.length,
                      //controller: _scrollController,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(20.0),
                      //itemExtent: 57,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 3.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1.5, color: Color(0xFFFFFFFF)),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                                dense:true,
                                title: Text(dt.values.elementAt(index)["name"], style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.white)),
                                onTap: () {
                                  selectEvt(selection, index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

              ),
            ),

            if (selection == "reviewselection") Container(
              height: 350,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
                          dense:true,
                          title: Text(regName!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
                          dense:true,
                          title: Text(cityName!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
                          dense:true,
                          title: Text(locName!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Text("Adresse : " + dt.values.elementAt(_selectedLocation)["address"] +" "+ complement! + dt.values.elementAt(_selectedLocation)["postal_code"] +" "+ dt.values.elementAt(_selectedLocation)["city_name"], style: Theme.of(context).textTheme.headline5!.merge(TextStyle(color: Colors.white)),),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),

            // TODO: Intergration OpenStreetMap (ongoing)

            Container(
              height: 300,
              child: OSMFlutter(
                controller: mapController,
                trackMyPosition: false,
                initZoom: 5.1,
                minZoomLevel: 5,
                maxZoomLevel: 18,
                stepZoom: 1.0,
                userLocationMarker: UserLocationMaker(
                  personMarker: MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: MarkerIcon(
                    icon: Icon(
                      Icons.double_arrow,
                      size: 48,
                    ),
                  ),
                ),
                /*road: Road(
                  startIcon: MarkerIcon(
                    icon: Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.brown,
                    ),
                  ),
                  roadColor: Colors.yellowAccent,
                ),*/
                markerOption: MarkerOption(
                    defaultMarker: MarkerIcon(
                      icon: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 56,
                      ),
                    )
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Flex(
            direction: Axis.horizontal,
            children: [
              Spacer(),
              ElevatedButton(
              child: const Text('Annuler', style: TextStyle(fontSize: 26.0, color: Colors.black)),
              onPressed: () {
                deselectEvt(selection);
              },
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0)),
            ),
              if (selection == "reviewselection") SizedBox(
                width: 16.0,
              ),
              if (selection == "reviewselection") ElevatedButton(
                child: const Text('Valider', style: TextStyle(fontSize: 26.0, color: Colors.black)),
                onPressed: () {
                  selectEvt(selection, _selectedLocation);
                },
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0)),
              ),
              Spacer(),
            ]
            ),

            /**/
          ];
        } else {
            dates=<Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    margin: EdgeInsets.symmetric(horizontal: 32.0),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.5, color: Colors.yellow),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.priority_high,size: 42.0, color: Color(0xffff7900)),
                          title: Text("Malheureusement il n’y a plus de place disponible. Si aucune date n’apparait ci-dessous c’est que nous sommes complets pour cet atelier.",style: Theme.of(context).textTheme.headline4!.merge(TextStyle(color: Colors.white)),),
                          //subtitle: Text(""),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextButton(
                    child: const Text('Retour'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ];
          }







        children=<Widget>[
          Row(
            children: [
              Container(height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width/2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.network(globals.imageURI + snapshot.data!["image"],
                        fit: BoxFit.fitWidth,
                        height: 323,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: ListTile(
                          title: Text(snapshot.data!["name"],style: Theme.of(context).textTheme.headline2),
                          subtitle: Text(fromHtml(snapshot.data!["description"]),style: Theme.of(context).textTheme.bodyText1),
                        ),
                      ),
                      const SizedBox(height: 12),/*
                      TextButton(
                        child: const Text('Retour'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),*/
                    ],
                  ),
                ),

              ),
              Container(color: Colors.black,height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width/2,
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center, children: dates),
              ),
            ],
          ),
        ];
      } else if (snapshot.hasError) {
        return Center(child: Text("Erreur chargmt"));
      }
      else {
        children=<Widget> [
          CircularProgressIndicator(),
          Text("Chargement..."),
        ];
      }

      return Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children
          ),
        ),
      );
    },
  );


  Future<Map<String, dynamic>> getEventInfo() async {
    final response = await http
        .get(Uri.parse(globals.apiURI + 'event/' + widget.evtSlug));
    if (response.statusCode == 200) {
      //Events evts = Events.fromJson(jsonDecode(response.body));
      // build
      //print(response.body);
      Map<String, dynamic> mappe = jsonDecode(response.body);
      evtInfoCache = mappe;
      return mappe;
    } else {
      print("exception");
      throw Exception('Failed to load album');
    }
  }


  void deselectEvt(String selector) async {
    globals.userInter();
    // assume we step forward
    switch(selector) {
      case "region":
        Navigator.pop(context);
        break;
      case "city":
        setState(() {
          _selectedRegion=-1;
        });
        setMap(<String, double>{'lat':46.522674, 'long':3.242666}, 5.1);

        break;
      case "reviewselection":
        setState(() {
          _selectedLocation=-1;
        });
        setMap(evtInfoCache!["regions"].values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity), 12.8);

        break;

      case "location":

        setState(() {
          _selectedCity=-1;
        });
        setMap(evtInfoCache!["regions"].values.elementAt(_selectedRegion), 7.1);

        break;
    }

    //setState(() { });

  }

  void setMap(Map<String, double?> geolist, double zoomLV) async {
    //geolist = geolist.values.elementAt(0);
    //print(geolist);
    await mapController.setZoom(zoomLevel: zoomLV);

if (geolist["lat"] != null && geolist["long"] != null) {
    await mapController.goToLocation(GeoPoint(latitude: geolist["lat"]!, longitude: geolist["long"]!));
  }
  }
  void selectEvt(String selector, int elem) async {
    globals.userInter();
    // assume we step forward
    switch(selector) {
      case "region":
        setState(() {
          _selectedRegion=elem;
        });
        setMap(evtInfoCache!["regions"].values.elementAt(_selectedRegion), 7.1);
        break;
      case "city":
        setState(() {
          _selectedCity=elem;
        });
        setMap(evtInfoCache!["regions"].values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity), 12.8);

        break;
      case "location":
        setState(() {
          _selectedLocation=elem;
        });
        setMap(evtInfoCache!["regions"].values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity)["places"].values.elementAt(_selectedLocation), 17.0);
        /*Map<String, dynamic> dt = evtInfoCache!["regions"].values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity)["places"].values.elementAt(elem)["dates"];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Details(evtSlug: evtInfoCache!["slug"], date: dt)),
        );*/

        break;
      case "reviewselection":
        Map<String, dynamic> dt = evtInfoCache!["regions"].values.elementAt(_selectedRegion)["cities"].values.elementAt(_selectedCity)["places"].values.elementAt(elem);
        //print(dt);
        String complement = dt["address_complement"] != null ? dt["address_complement"] + " " : "";
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Details(evtSlug: evtInfoCache!["slug"], date: dt["dates"], address: "Adresse : " + dt["address"] +" "+ complement + dt["postal_code"] +" "+ dt["city_name"],)),
        );

        break;
    }

    //setState(() { });

  }
  /*Widget build(BuildContext context) => Scaffold(
      body:
          Center(
              child: Wrap(children: [
                  ListTile(
                      title: Text(widget.atelierInfo["title"]),
                      subtitle: Text(removeAllHtmlTags(widget.atelierInfo["description"])),
                  ),
                  TextButton(
                    child: const Text('Retour'),
                    onPressed: () {
                      Navigator.pop(context);
                      },
                  ),
              ],
              ),
          ),
      );*/

  String fromHtml(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );
    return htmlText.replaceAll(exp, '');
  }

  String getExactDate(int timest) {
    initializeDateFormatting('fr_FR', null);
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(timest * 1000000);
    return DateFormat.yMMMMEEEEd('fr').format(date);
    //return "";
  }

  String getTimeFromSeconds(int seconds) {
    initializeDateFormatting('fr_FR', null);
    int h, m, s;

    h = seconds ~/ 3600;
    m = ((seconds - h * 3600)) ~/ 60;
    String hour = (h+1).toString();
    //h.toString().length < 2 ? "0" + h.toString() : h.toString();

    String minute = m.toString() == "0" ? "" : m.toString();

    String result = "$hour"+"h"+"$minute";
    return result;
    //DateTime date = DateTime(seconds);
    //return DateFormat.Hm().format(date);
    //return "";
  }







  List<Widget> getRightScreenInfo() {












    return <Widget>[];
  }
}
