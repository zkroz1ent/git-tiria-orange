import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
import 'package:borneorange/globals.dart' as globals;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';
import 'package:borneorange/components/inscription.dart';

late StreamSubscription<bool> keyboardSubscription;

class Details extends StatefulWidget {
  const Details({
    Key? key,
    required String this.evtSlug,
    Map<String, dynamic>? this.date,
    String? this.address
  }) : super(key: key);
  final String evtSlug;
  final Map<String, dynamic>? date;
  final String? address;


  @override
  State<Details> createState() => DetailState();
}

class DetailState extends State<Details> {
  final _scrollController = ScrollController();
  int _selectedEvtDate = -1;
  int _selectedEvtTime = 0;
  int _step = 0;
  List<Widget> dates=[];
  Map<String, dynamic>? evtInfoCache;
  Widget slotsSpace = Container();
  Widget formSpace = Container(color: Colors.black,
    child: CircularProgressIndicator(),
  );
  Widget registeredSpace = Container(color: Colors.black,
    child: CircularProgressIndicator(),
  );
  /*late final Stream<KioskMode> _currentMode = watchKioskMode();*/



  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    print('Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // Subscribe
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: getEventInfo(),
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
      List<Widget> children;
      if (snapshot.hasData) {
            //Map<String, dynamic> dt=snapshot.data!["dates"] is Map<String, dynamic> ? snapshot.data!["dates"] : <String, dynamic>{};

            //if (snapshot.data!["dates"]is Map<String, dynamic>) snapshot.data!["dates"] = snapshot.data!["dates"].removeWhere((k, v)=>v.containsKey("slots") == false);
            if (snapshot.data!["dates"]is Map<String, dynamic>){
              //Map<String, dynamic> dt=snapshot.data!["dates"];
              SplayTreeMap dt=new SplayTreeMap.from(snapshot.data!["dates"]);
              dates=<Widget>[
                const SizedBox(height: 14),
                Text("Inscrivez-vous à l'atelier",style: Theme.of(context).textTheme.headline3),
                const SizedBox(height: 16),
                Container(
                    height: 660,
                    child: Theme(
                        data: ThemeData(canvasColor: Colors.black, primaryColor: Color(0xffff7900), colorScheme: ColorScheme.light(
                            primary: Color(0xffff7900)
                        ),),
                        child: Stepper(
                          type: StepperType.horizontal,
                          currentStep: _step,
                          controlsBuilder: (BuildContext context, ControlsDetails details) {
                            return Row(
                              children: <Widget>[],
                            );
                          },
                          onStepCancel: () {
                            if (_step > 0) {
                              setState(() {
                                _step -= 1;
                              });
                            }
                          },
                          onStepContinue: () {
                            if (_step <= 1) {
                              setState(() {
                                _step += 1;
                              });
                            }
                          },
                          onStepTapped: (int index) {
                            /*setState(() {
                          _step = index;
                        });*/
                          },
                          steps: <Step>[
                            Step(
                              isActive: _step >= 0,
                              state: _step == 0 ? StepState.editing : StepState.complete,
                              title: const Text('Date et horaire', style: TextStyle(color: Colors.white)),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (widget.address != null) Text(widget.address!, style: TextStyle(color: Colors.white, fontSize: 20.0),),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: dt.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.all(20.0),
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              title: Text(getExactDate(dt.values.elementAt(index)["date"]), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white)),
                                              /*value: index,
                                    groupValue: _selectedEvtDate,
                                    onChanged: (value) {
                                      selectEvt(index);
                                    },*/
                                            ),
                                            /*Map<String, dynamic> slot = evtInfoCache!["dates"].values.elementAt(index);
                                  slot = slot.values.elementAt(1);*/
                                            if (dt.values.elementAt(index)["slots"] != null) ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: dt.values.elementAt(index).values.elementAt(1).length,
                                              physics: NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.all(20.0),
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (context, index2) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 1.5, color: Color(0xFFFFFFFF)),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Text("de "+getTimeFromSeconds(dt.values.elementAt(index).values.elementAt(1).values.elementAt(index2)["start_time"]) + " à " + getTimeFromSeconds(dt.values.elementAt(index).values.elementAt(1).values.elementAt(index2)["end_time"]), style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal, color: Colors.white)),
                                                        subtitle: Text("places restantes : "+dt.values.elementAt(index).values.elementAt(1).values.elementAt(index2)["place_left"].toString(), style: TextStyle(color: Colors.white, fontSize: 16.0),),
                                                        //value: dt.values.elementAt(index).values.elementAt(1).values.elementAt(index2)["id"],
                                                        //groupValue: _selectedEvtTime,
                                                        onTap: () {
                                                          globals.userInter();
                                                          selectTime(dt.values.elementAt(index).values.elementAt(1).values.elementAt(index2)["id"], index2);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Step(
                              isActive: _step >= 1,
                              state: _step == 1 ? StepState.editing : _step >= 1 ? StepState.complete : StepState.indexed,
                              title: Text((globals.userProfileCache != null) ? 'Vérifier Profil' : 'Profil', style: TextStyle(color: Colors.white)),
                              content: formSpace,
                            ),
                            Step(
                              isActive: _step >= 2,
                              state: _step == 2 ? StepState.complete : StepState.indexed,
                              title: Text('Récap', style: TextStyle(color: Colors.white)),
                              content: registeredSpace,
                            ),
                          ],
                        ),
                    ),

                    /*
                      */
                  ),
                //slotsSpace,

                _step == 2 ? Container()/*Center(
      child: Row(
      children: [
      Spacer(),
      TextButton(onPressed: () {
      globals.userProfileCache = null;
      Navigator.of(context).popUntil((route) => route.isFirst);

      }, child: Text("Terminer")),
      ElevatedButton(onPressed: () {
      globals.autoDstr();
      Navigator.of(context).popUntil((route) => route.isFirst);

      }, child: Text("s'inscrire à un autre atelier")),
      Spacer(),
      ],
      ),
      )*/ : ElevatedButton(
                  child: const Text('Retour', style: TextStyle(fontSize: 26.0, color: Colors.black)),
                  onPressed: () {
                    globals.userInter();
                    if (_step != 0){
                      setState(() {
                        if (_step == 1) formSpace = Container(color: Colors.black, child: CircularProgressIndicator(),);
                        _step--;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0)),
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
                          const SizedBox(height: 12),
                          /*TextButton(
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
      if (widget.date != null) {
          mappe["dates"] = widget.date!;
          print(mappe["dates"]);
      }
      evtInfoCache = mappe;
      return mappe;
    } else {
      print("exception");
      throw Exception('Failed to load album');
    }
  }

  void selectEvt(int elem) async {
    List<Widget> dispHoraires = [];
    Map<String, dynamic> slot = evtInfoCache!["dates"].values.elementAt(elem);
    slot = slot.values.elementAt(1);
    //slot = slot.values.elementAt(0);
    //print(slot);
    //slot["place_left"] as String

    dispHoraires = [

      ListView.builder(
        shrinkWrap: true,
        itemCount: slot.length,
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.0),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Column(
            children: [
              RadioListTile<int>(
                title: Text("de "+getTimeFromSeconds(slot.values.elementAt(index)["start_time"]) + " à " + getTimeFromSeconds(slot.values.elementAt(index)["end_time"]), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                subtitle: Text("places restantes : "+slot.values.elementAt(index)["place_left"].toString(), style: TextStyle(color: Colors.white),),
                value: index,
                groupValue: _selectedEvtTime,
                onChanged: (value) {
                  selectTime(slot.values.elementAt(index)["id"], index);
                },
              ),
            ],
          );
        },
      ),

    ];
    print(" t select : " + _selectedEvtDate.toString());
    print(" t select : " + elem.toString());

    setState(() {
      _selectedEvtDate = elem;
      slotsSpace = Flex(
          direction: Axis.vertical,
          children: dispHoraires
        );
    });
  }


  void selectTime(int id, int index) async {
    print(" t select : " + _selectedEvtTime.toString());
    print(" t select : " + index.toString());
    setState(() {
      _step = _step+1;
      _selectedEvtTime = index;
      formSpace = Container(color: Colors.black, width: MediaQuery.of(context).size.width/2,
        child: Inscription(slotID: id, evtInfoCache: evtInfoCache, callbackFunction: _postInscrCallback,)
      );
    });
  }

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

  void _postInscrCallback(Map<String, dynamic> retourInscr) {
      print("dshkfsiud");
      globals.stopTimer();

      setState(() {
        registeredSpace = postInscr(retourInscr: retourInscr);
        _step = _step+1;
      });
  }

}



/*
class ListeDates extends StatelessWidget {
  ListeDates({Key? key, required Map<String, dynamic> this.infoDates}) : super(key: key);
  final Map<String, dynamic> infoDates;


  @override
  Widget build(BuildContext context) {

    if (infoDates.data!["dates"]is Map<String, dynamic>){
      Map<String, dynamic> dt=infoDates.data!["dates"];
      dates=<Widget>[
        Text("Inscrivez-vous à l'atelier",style: Theme.of(context).textTheme.headline3),
        SingleChildScrollView(
          child: Container(
            height: 600,
            child:
            ListView.builder(
              shrinkWrap: true,
              itemCount: dt.length,
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20.0),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    RadioListTile<int>(
                      title: Text(getExactDate(dt.values.elementAt(index)["date"]), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      value: index,
                      groupValue: _selectedEvtDate,
                      onChanged: (value) {
                        selectEvt(index);
                      },
                    ),
                    /*ListTile(
                                title: Text(getExactDate(dt.values.elementAt(index)["date"])),
                                subtitle: Text("On afficheras les heures"),
                              ),*/
                    /*TextButton(
                                child: const Text('Je m\'inscrit'),
                                onPressed: () {selectEvt(index);},
                              ),*/
                  ],
                );
              },
            ),
          ),
        ),
        slotsSpace,

        TextButton(
          child: const Text('Retour'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        /**/
      ];
    } else {
      dates=<Widget>[
        ListTile(
          leading: Icon(Icons.priority_high,size: 52.0),
          title: Text("il n’y a plus de place disponible.",style: Theme.of(context).textTheme.headline3),
          subtitle: Text(""),
        ),
        TextButton(
          child: const Text('Retour'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ];
    }


    return dates;
  }
}*/