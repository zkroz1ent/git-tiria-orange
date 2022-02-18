import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:borneorange/globals.dart' as globals;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

import 'package:borneorange/components/globales.dart';

class Inscription extends StatefulWidget {
  const Inscription({
    Key? key,
    required int this.slotID,
    required Map<String, dynamic>? this.evtInfoCache,
    required this.callbackFunction
  }) : super(key: key);
  final int slotID;
  final Map<String, dynamic>? evtInfoCache;
  final Function(Map<String, dynamic> retourInscr) callbackFunction;

  @override
  State<Inscription> createState() => InscriptionState();
}

class InscriptionState extends State<Inscription> {
  final nom = TextEditingController();
  final prenom = TextEditingController();
  final mail = TextEditingController();
  final phone = TextEditingController();
  final fixe = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final cp = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool rgpdaccept = false;
  Map<String, dynamic>? slotInfoCache;
  bool validateStatus = true;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.dispose();
  }

  @override
  initState() {
    if (globals.userProfileCache != null) {
      Map<String, dynamic> upc = globals.userProfileCache!;
      nom.text = (upc["lastName"] != null) ? upc["lastName"] : "";
      prenom.text = (upc["firstName"] != null) ? upc["firstName"] : "";
      mail.text = (upc["email"] != null) ? upc["email"] : "";
      phone.text = (upc["phone"] != null) ? upc["phone"] : "";
      cp.text = (upc["postalCode"] != null) ? upc["postalCode"] : "";
      city.text = (upc["city"] != null) ? upc["city"] : "";
      address.text = (upc["address"] != null) ? upc["address"] : "";
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  /*late final Stream<KioskMode> _currentMode = watchKioskMode();*/

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Map<String, dynamic>>(
        future: getSlotInfo(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          List<Widget> children;
          List<Widget> listeInputs = <Widget>[];
          if (snapshot.hasData) {
            if (snapshot.data!["remaining_places"] != 0) {

              Map <String, dynamic> mapListInputs = Map<String, dynamic>.from(widget.evtInfoCache!)..removeWhere((k, v) => !k.startsWith("enable_registration"));
              Map <String, dynamic> mapListRequired = Map<String, dynamic>.from(widget.evtInfoCache!)..removeWhere((k, v) => !k.startsWith("required_registration"));

              print(mapListInputs);

              /*mapListInputs.forEach((k, v) {

                if (v) {
                  listeInputs.add(
                    Expanded(
                      flex: 5,
                      child: ListTile(
                        title: Text("Nom"),
                        subtitle: TextFormField(
                          controller: nom,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  );
                }

              });*/

              if (widget.evtInfoCache!["enable_registration_firstname"]) {
                listeInputs.add(
                  ListTile(
                      title: Text("Prenom", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      subtitle: TextFormField(
                        controller: prenom,
                        style: TextStyle(color: Colors.white70),
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
  if (widget.evtInfoCache!["required_registration_firstname"]) {
                          if (value == null || value.isEmpty) {
                            return 'Le prénom est requis.';
                          }}
                          return null;
                        },
                      ),
                    ),
                );
              }
              if (widget.evtInfoCache!["enable_registration_lastname"]) {
                listeInputs.add(
                  ListTile(
                      title: Text("Nom", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      subtitle: TextFormField(
                        controller: nom,
                        style: TextStyle(color: Colors.white70),
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
  if (widget.evtInfoCache!["required_registration_lastname"]) {
                          if (value == null || value.isEmpty) {
                            return 'Le nom est requis.';
                          }}
                          return null;
                        },
                      ),
                    ),
                );
              }
              if (widget.evtInfoCache!["enable_registration_email"]) {
                listeInputs.add(
                  ListTile(
                      title: Text("Adresse email", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      subtitle: TextFormField(
                        controller: mail,
                        style: TextStyle(color: Colors.white70),
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
  if (widget.evtInfoCache!["required_registration_email"]) {
                          if (value == null || value.isEmpty) {
                            return "L'adresse mail est requise.";
                          } else if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(value)) {
                            // Test si adresse mail incorrecte
                            return "L'adresse mail est incorrecte.";
                          }
  
                          }
                          return null;
                        },
                      ),
                    ),
                );
              }
              if (widget.evtInfoCache!["enable_registration_phone"]) {
                listeInputs.add(
                  ListTile(
                      title: Text("Téléphone", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      subtitle: TextFormField(
                        controller: phone,
                        style: TextStyle(color: Colors.white70),
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
  if (widget.evtInfoCache!["required_registration_phone"]) {
                          if (value == null || value.isEmpty) {
                            return 'Le numéro de téléphone est requis.';
                          } else if (value.length != 10 || int.tryParse(value) == null) {
                            // Test si incorrect
                            return "Le numéro de téléphone est invalide.";
                          }}
                          return null;
                        },
                      ),
                    ),
                );
              }
              if (widget.evtInfoCache!["enable_registration_fixe_phone"]) {
                listeInputs.add(
                  ListTile(
                      title: Text("Téléphone fixe", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      subtitle: TextFormField(
                        controller: fixe,
                        style: TextStyle(color: Colors.white70),
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
  if (widget.evtInfoCache!["required_registration_fixe_phone"]) {
                          if (value == null || value.isEmpty) {
                            return 'Le numéro de téléphone fixe est requis.';
                          } else if (value.length != 10 || int.tryParse(value) == null) {
                            // Test si incorrect
                            return "Le numéro de téléphone fixe est invalide.";
                          }}
                          return null;
                        },
                      ),
                    ),
                );
              }
              if (widget.evtInfoCache!["enable_registration_address"]) {
                listeInputs.add(
                  ListTile(
                      title: Text("Adresse", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      subtitle: TextFormField(
                        controller: address,
                        style: TextStyle(color: Colors.white70),
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {if (widget.evtInfoCache!["required_registration_address"]) {
                          if (value == null || value.isEmpty) {
                            return "L'adresse est requise.";
                          }}
                          return null;
                        },
                      ),
                    ),
                );
              }
              if (widget.evtInfoCache!["enable_registration_city"]) {
                listeInputs.add(
                  ListTile(
                      title: Text("Ville", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      subtitle: TextFormField(
                        controller: city,
                        style: TextStyle(color: Colors.white70),
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {if (widget.evtInfoCache!["required_registration_city"]) {
                          if (value == null || value.isEmpty) {
                            return 'La ville est requise.';
                          }}
                          return null;
                        },
                      ),
                    ),
                );
              }
              if (widget.evtInfoCache!["enable_registration_postal_code"]) {
                listeInputs.add(
                  ListTile(
                      title: Text("Code postal", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white)),
                      subtitle: TextFormField(
                        controller: cp,
                        style: TextStyle(color: Colors.white70),
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {if (widget.evtInfoCache!["required_registration_postal_code"]) {
                          if (value == null || value.isEmpty || int.tryParse(value) == null) {
                            return 'Le code postal est requis.';
                          } else if (int.tryParse(value) == null) {
                            return 'Merci de renseigner un code postal valide';
                          }}
                          return null;
                        },
                      ),
                    ),
                );
              }






            /*  Expanded(
                  flex: 5,
                  child:
              )*/












              children = <Widget>[
                Text("Renseigner vos coordonnées",style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.left),
                SizedBox(height: 16),
                Form(
                    key: _formKey,
                    child: Column( children: [
                        GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0,
                            shrinkWrap: true,
                            mainAxisSpacing: 0,
                            childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height/2),
                            children: listeInputs,
                        ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.white,
                        ),
                        child: CheckboxListTile(
                  title: Text(widget.evtInfoCache!["bu_gdpr_text"], style: TextStyle(color: Colors.white)),
                  subtitle: Text("Pour plus d’information, n’hésitez pas à consulter la politique de protection des données personnelles d’Orange. *", style: TextStyle(color: Colors.white)),
                  value: rgpdaccept,
                  onChanged: (bool? value) {
                    setState(() {
                      rgpdaccept = value!;
                    });
                  },
                  ),
                ), SizedBox(height: 12),
                  if (validateStatus) ElevatedButton(
                    onPressed: () {
                      if (rgpdaccept) {
                        if (_formKey.currentState!.validate()) {
                          validateInscr();
                        }
                      }
                    },
                    style: rgpdaccept==true ? ElevatedButton.styleFrom(primary: Color(0xffff7900), textStyle: TextStyle(fontSize: 26.0, color: Colors.black)) : ElevatedButton.styleFrom(primary: Colors.grey, textStyle: TextStyle(fontSize: 26.0, color: Colors.black)),
                    child: const Text('Valider', style: TextStyle(color: Colors.black)),
                  ),
                      if (!validateStatus) CircularProgressIndicator(),
                    ],),
                ),
              ];
            } else {
              children = <Widget>[
                ListTile(
                  leading: Icon(Icons.priority_high,size: 42.0),
                  title: Text("il n’y a plus de place disponible.",style: Theme.of(context).textTheme.headline3),
                  //subtitle: Text(""),
                ),
              ];
            }
          } else {
            children = <Widget>[
              CircularProgressIndicator(),
              Text("Vérification..."),
            ];
          }

          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
        },
      );
  Future<Map<String, dynamic>> getSlotInfo() async {
    final response = await http
        .get(Uri.parse(globals.apiURI + 'slot/' + widget.slotID.toString()));
    if (response.statusCode == 200) {
      //Events evts = Events.fromJson(jsonDecode(response.body));
      // build
      print(response.body);
      Map<String, dynamic> mappe = jsonDecode(response.body);
      slotInfoCache = mappe;
      return mappe;
    } else {
      print("exception");
      throw Exception('Failed to load album');
    }
  }

  void validateInscr() async {
    setState(() {
      validateStatus = false;
    });
    //{"firstName":"<string>","lastName":"<string>","email":"<string>","phone":"<string>","address":"<string>","postalCode":"<string>","city":"<string>","cgu":"<boolean>","required":"<string>"}
    print(nom.text);
    Map<String, dynamic> dataList = {
      'firstName': prenom.text,
    'lastName': nom.text,
    'email': mail.text,
    'phone': phone.text,
    'address': address.text,
    'postalCode': int.tryParse(cp.text),
    'city': city.text,
    'cgu': true,
      'required': "{}",
    };
    //dataList = Map<String, dynamic>.from(dataList)..removeWhere((k, v) => v == "");
    print(jsonEncode(dataList));
      final response = await http.post(
        Uri.parse(globals.apiURI + "slot/" + widget.slotID.toString()+ "/subscribe"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': '*/*',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'content-type': 'application/json'
        },
        body: jsonEncode(dataList),
      );
    print(response.body);
    Map<String, dynamic> r = jsonDecode(response.body);
    // future
    if (r["status"] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: Duration(seconds: 25), content: Text(r["message"]), action: SnackBarAction(label: "X", onPressed: () {},)),
      );
    } else {
      globals.userProfileCache = dataList;
      widget.callbackFunction(slotInfoCache!);
      // add function here
      /*Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => postInscr(retourInscr: slotInfoCache!,)),
      );*/
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Afficher ecran inscrit")),
      );*/
    }
    setState(() {
      validateStatus = true;
    });
  }


  bool checkEmailValid(mail) {

    return false;
  }

}

class postInscr extends StatelessWidget {
  postInscr({Key? key, required Map<String, dynamic> this.retourInscr}) : super(key: key);
  final Map<String, dynamic> retourInscr;

  // Fields in a Widget subclass are always marked "final".


  @override
  Widget build(BuildContext context) {
    //final Globales inheritedWidget = Globales.of(context);
    return Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(),
          ),
          Expanded(
            flex: 8,
            child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Text("Merci ! Votre inscription a été prise en compte.",style: Theme.of(context).textTheme.headline3),
                    Text("Vous avez choisi :",style: Theme.of(context).textTheme.headline5!.merge(TextStyle(color: Colors.white))),
                    Text(retourInscr["name"],style: Theme.of(context).textTheme.headline5!.merge(TextStyle(color: Color(0xffff7900)))),
                    Text(""),
                    Text("Nous vous attendons le",style: Theme.of(context).textTheme.headline5!.merge(TextStyle(color: Colors.white))),
                    Text(retourInscr["virtual_phone"] != null ? getExactDate(retourInscr["start_time"]) + " de " + getExactTime(retourInscr["start_time"]) + " à " + getExactTime(retourInscr["end_time"]) : getExactDate(retourInscr["start_time"]) + " de " + getExactTime(retourInscr["start_time"]) + " à " + getExactTime(retourInscr["end_time"]) + " à cette adresse :",style: Theme.of(context).textTheme.headline5!.copyWith(color: Color(0xffff7900),)),
                    Text(getLocationInfoText(),style: Theme.of(context).textTheme.headline5!.merge(TextStyle(color: Colors.white))),
                    Text(""),
                    Text("Un mail de confirmation vous a été envoyé avec toutes les infos. Si besoin, vous pourrez vous désinscrire depuis cet e-mail.",style: Theme.of(context).textTheme.headline5!.merge(TextStyle(color: Colors.white))),
                    SizedBox(height: 12.0,),
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton(onPressed: () {
                            globals.userProfileCache = null;
                            Navigator.of(context).popUntil((route) => route.isFirst);

                          }, child: Text("Terminer", style: TextStyle(fontSize: 26.0, color: Colors.black)),
                            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0)),),
                          SizedBox(height: 12.0,),
                          ElevatedButton(onPressed: () {
                            globals.autoDstr();
                            Navigator.of(context).popUntil((route) => route.isFirst);

                          }, child: Text("S'inscrire à un autre atelier", style: TextStyle(fontSize: 26.0, color: Colors.black)),
                          style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0)),),
                        ],
                      ),
                    )
                  ],
                )
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      );
  }

  String getLocationInfoText() {
    if (retourInscr["virtual_phone"] != null) {
      return "Rejoignez-nous au "+retourInscr["virtual_phone"]+" depuis votre téléphone fixe ou mobile";
    } else {
      return retourInscr["place_name"] + ", " + retourInscr["place_address"] + ", " + retourInscr["place_address_complement"] + ", " + retourInscr["place_postal_code"] + " " + retourInscr["city_name"];
    }
  }

  String getExactDate(int timest) {
    initializeDateFormatting('fr_FR', null);
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(timest * 1000000);
    return DateFormat.yMMMMEEEEd('fr').format(date);
    //return "";
  }
  String getExactTime(int timest) {
    initializeDateFormatting('fr_FR', null);
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(timest * 1000000);
    return DateFormat.Hm('fr').format(date);
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
}