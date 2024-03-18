import 'dart:convert';
import 'dart:math';

import 'package:capitalcityguesser/databaseManager.dart';
import 'package:capitalcityguesser/pages/capitals_preset_page.dart';
import 'package:capitalcityguesser/widgets/drawer.dart';
import 'package:capitalcityguesser/widgets/square_button.dart';
import 'package:capitalcityguesser/services/capitals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class CapitalCitiesGuessingData {
  static int capitalCitiesFound = 0;
  static double capitalCitiesFoundPercentage = 0;
  static late int countryIndex;
  static late String countryName;
  static late String answer;

  static late List<String> countriesToFind;
  static List<String> countriesSkipped = [];
}

class _HomePageState extends State<HomePage> {
  TextEditingController countryNameTextField = TextEditingController();
  
  late FocusNode countryNameInputFocusNode;

  bool showAnswer = false;
  bool showTip = false;

  @override
  void initState() {
    super.initState();

    countryNameInputFocusNode = FocusNode();

    if(CapitalCitiesGuessingData.capitalCitiesFound == 0) {
      CapitalCitiesGuessingData.countriesToFind = CapitalCityApi.chosenPreset.toList();
      generateNextCity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getHeader(),
      drawer: getDrawer(context),
      body: getBody(),
    );
  }

  PreferredSizeWidget getHeader() {
    return AppBar(
      title: const Text("Capital Cities Guesser", style: TextStyle(fontSize: 16),),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text("${CapitalCitiesGuessingData.capitalCitiesFound} / ${CapitalCityApi.chosenPresetLength} | ${CapitalCitiesGuessingData.capitalCitiesFoundPercentage.toStringAsFixed(2)}%"),
        )
      ],
    );
  }

  Widget getBody() {    
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 90, bottom: 30),
            child: Column(
              children: [
                // Image.asset(CapitalCitiesGuessingData.answer, height: 150,),
                Text(
                  CapitalCitiesGuessingData.countryName,
                  style: const TextStyle(fontSize: 32,),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Visibility(
                    visible: showAnswer || showTip,
                    child: Text(CapitalCitiesGuessingData.answer, style: const TextStyle(fontSize: 16),)
                  ),
                ), 
              ],
            ),
          ),
          Padding(
            padding: showAnswer || showTip
            ? 
              const EdgeInsets.only(left: 15, right: 15)
            :
              const EdgeInsets.only(left: 15, right: 15, top: 25),
            child: TextField(
              controller: countryNameTextField,
              focusNode: countryNameInputFocusNode,
              onChanged: (value) {
                checkIfFound(value);
              },
              onSubmitted: (value) {
                if (value == "") {
                  skipCity();
                }
              },
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        showTip = !showTip;
                        
                        setState(() { });
                      },
                      icon: showTip 
                      ?
                        const Icon(Icons.lightbulb_outline)
                      :
                        const Icon(Icons.lightbulb),
                    ),
                    IconButton(
                      onPressed: () {
                        countryNameTextField.clear();
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
                  ],
                )
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              skipCity();
            },
            child: const Text("Next"),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 75),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container( // Toggle Answer visibilty
                      color: Colors.blue.shade800,
                      height: 100,
                      width: 100,
                      child: InkWell(
                        splashColor: Colors.blue.shade900, 
                        onTap: () {
                          showAnswer = !showAnswer;
                    
                          setState(() { });
                        }, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            showAnswer
                            ?
                              const Icon(Icons.visibility_off, color: Colors.white, size: 36,)
                            :
                              const Icon(Icons.visibility, color: Colors.white, size: 36,),
                            Text(
                              showAnswer ? "Hide\nanswers" : "Show\nanswers", 
                              style: const TextStyle(color: Colors.white, fontSize: 14), 
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    ),
                    SquareButton( //Restart
                      onPress: () {   
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirm"),
                              content: const Text("Are you sure you want to restart?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    restartGame();
                
                                    Navigator.pop(context);
                                    setState(() { });
                                  },
                                  child: const Text("Yes"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("No"),
                                ),
                              ],
                            );
                          },
                        );         
                      }, 
                      text: "Restart",
                      iconData: Icons.refresh,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SquareButton(
                        onPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text("This will override the current custom preset. Are you sure you want to continue?"),
                                actions: [
                                  TextButton(
                                    onPressed: () async {   
                                      List<String> customPreset = [];
                                      customPreset = CapitalCitiesGuessingData.countriesSkipped.toList();
                                      customPreset += CapitalCitiesGuessingData.countriesToFind.toList();

                                      String capitals = json.encode(customPreset);

                                      int res = await DatabaseManager.instance.updateCustomPreset(capitals, 1);

                                      if (res != 0)
                                      {
                                        Fluttertoast.showToast(msg: "Saved to custom preset!");
                                      }
                                      else
                                      {
                                        Fluttertoast.showToast(msg: "Error while saving to preset!");
                                      }

                                      if (context.mounted)
                                      {
                                        Navigator.pop(context);
                                      }
                                    }, 
                                    child: const Text("Yes"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    
                                      return;
                                    },
                                    child: const Text("No"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        text: "Save rest to custom",
                        iconData: Icons.save,
                      ),
                      SquareButton(
                        onPress: () {   
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => 
                              CapitalCitiesPresetPage(refreshHomePageCallback: refreshPage)
                            )
                          );
                        }, 
                        text: "Change preset",
                        iconData: Icons.location_city,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Checks if the user has given the correct answer and generates a answer if yes.
  void checkIfFound(String value) {
    if (value.toLowerCase() == CapitalCitiesGuessingData.answer.toLowerCase()) {
      countryNameTextField.clear();

      CapitalCitiesGuessingData.countriesToFind.removeAt(CapitalCitiesGuessingData.countryIndex);
      CapitalCitiesGuessingData.capitalCitiesFound++;
      generateNextCity();
      
      HapticFeedback.lightImpact();
    }
  }

  /// Skips city and calls a new one to be generated.
  void skipCity() {
    countryNameTextField.clear();
    countryNameInputFocusNode.requestFocus();

    CapitalCitiesGuessingData.countriesSkipped.add(CapitalCitiesGuessingData.countryName);
    CapitalCitiesGuessingData.countriesToFind.removeAt(CapitalCitiesGuessingData.countryIndex);

    generateNextCity();
  }

  /// Restart game data and calls a new one to be generated.
  void restartGame() {
    CapitalCitiesGuessingData.countriesToFind = CapitalCityApi.chosenPreset.toList();
    CapitalCitiesGuessingData.capitalCitiesFound = 0;
    generateNextCity();
  }

  void refreshPage() {
    setState(() {});
  }

  /// Generates a random city and its data.
  void generateNextCity() {
    CapitalCitiesGuessingData.capitalCitiesFoundPercentage = CapitalCitiesGuessingData.capitalCitiesFound / CapitalCityApi.chosenPresetLength * 100;

    if(CapitalCitiesGuessingData.capitalCitiesFound != CapitalCityApi.chosenPresetLength)
    {
      if (CapitalCitiesGuessingData.countriesToFind.isEmpty) // every country was seen once, restore list to see all again
      {
        CapitalCitiesGuessingData.countriesToFind = CapitalCitiesGuessingData.countriesSkipped.toList();
        CapitalCitiesGuessingData.countriesSkipped = [];
      }

      CapitalCitiesGuessingData.countryIndex = Random().nextInt(CapitalCityApi.chosenPresetLength - CapitalCitiesGuessingData.capitalCitiesFound - CapitalCitiesGuessingData.countriesSkipped.length);
      CapitalCitiesGuessingData.countryName = CapitalCitiesGuessingData.countriesToFind[CapitalCitiesGuessingData.countryIndex];
      CapitalCitiesGuessingData.answer = CapitalCityApi.getCapitalFromName(CapitalCitiesGuessingData.countryName)!;
    }
    else // You won
    {
      CapitalCitiesGuessingData.capitalCitiesFoundPercentage = 100.0;
    }

    if (showTip)
    {
      showTip = false;
    }
    
    setState(() { });
  }

  @override
  void dispose() {
    countryNameInputFocusNode.dispose();

    super.dispose();
  }
}