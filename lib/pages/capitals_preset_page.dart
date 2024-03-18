import 'dart:convert';
import 'dart:math';

import 'package:capitalcityguesser/constants.dart';
import 'package:capitalcityguesser/databaseManager.dart';
import 'package:capitalcityguesser/main.dart';
import 'package:capitalcityguesser/pages/home_page.dart';
import 'package:capitalcityguesser/services/capitals.dart';
import 'package:capitalcityguesser/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CapitalCitiesPresetPage extends StatefulWidget {
  final Function refreshHomePageCallback;

  const CapitalCitiesPresetPage({super.key, required this.refreshHomePageCallback });

  @override
  State<CapitalCitiesPresetPage> createState() => _CapitalCitiesPresetPageState();
}

class _CapitalCitiesPresetPageState extends State<CapitalCitiesPresetPage> {
  late String chosenPreset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getHeader(),
      body: getBody(),
    );
  }

  @override
  void initState() {
    super.initState();

    chosenPreset = StaticVariables.sharedPrefs!.getString("chosenPreset")!;
  }

  PreferredSizeWidget getHeader() {
    return AppBar(
      title: const Text("Presets"),
      actions: [
        Text("${CapitalCityApi.chosenPresetLength} / ${CapitalCityApi.allCountries.length}"),
        IconButton(
          onPressed: () {
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
                        customPreset = CapitalCityApi.chosenPreset.toList();

                        String flags = json.encode(customPreset);
                        int res = await DatabaseManager.instance.updateCustomPreset(flags, 1);

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

                        return;
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
          icon: const Icon(Icons.save),
        ),
      ],
    );
  }

  Widget getBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: RawScrollbar(
        thumbColor: CapitalCityGuesserPalette.mainColor,
        thickness: 8,
        radius: const Radius.circular(36),
        crossAxisMargin: 2,
        child: ListView(
          children: [
            Column( // presets
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SquareButton(
                        onPress: () async {
                          loadPreset(CapitalCityApi.europePreset);
                          await StaticVariables.sharedPrefs!.setString("chosenPreset", "europePreset");
                        },
                        text: "Europe\npreset",
                        iconData: Icons.data_array
                      ),
                      SquareButton(
                        onPress: () async {
                          loadPreset(CapitalCityApi.africaPreset);
                          await StaticVariables.sharedPrefs!.setString("chosenPreset", "africaPreset");
                        },
                        text: "Africa\npreset",
                        iconData: Icons.data_array
                      ),
                      SquareButton(
                        onPress: () async {
                          loadPreset(CapitalCityApi.asiaPreset);
                          await StaticVariables.sharedPrefs!.setString("chosenPreset", "asiaPreset");
                        },
                        text: "Asia\npreset",
                        iconData: Icons.data_array
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SquareButton(
                        onPress: () async {
                          loadPreset(CapitalCityApi.northAmericaPreset);
                          await StaticVariables.sharedPrefs!.setString("chosenPreset", "northAmericaPreset");
                        },
                        text: "N America preset",
                        iconData: Icons.data_array
                      ),
                      SquareButton(
                        onPress: () async {
                          loadPreset(CapitalCityApi.southAmericaPreset);
                          await StaticVariables.sharedPrefs!.setString("chosenPreset", "southAmericaPreset");
                        },
                        text: "S America\npreset",
                        iconData: Icons.data_array
                      ),
                      SquareButton(
                        onPress: () async {
                          loadPreset(CapitalCityApi.oceaniaPreset);
                          await StaticVariables.sharedPrefs!.setString("chosenPreset", "oceaniaPreset");
                        },
                        text: "Oceania\npreset",
                        iconData: Icons.data_array
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: SquareButton(
                          onPress: () async {
                            CapitalPreset? customPreset = await DatabaseManager.instance.getCapitalsPresetById(1);
                        
                            if (customPreset != null)
                            {
                              loadPreset(customPreset.capitalCities);
                              await StaticVariables.sharedPrefs!.setString("chosenPreset", "customPreset");
                            }
                            else
                            {
                              Fluttertoast.showToast(msg: "This preset is empty!");
                            }
                          },
                          text: "Custom preset",
                          iconData: Icons.data_array
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: SquareButton(
                          onPress: () async {
                            loadPreset(CapitalCityApi.allCountries);
                            await StaticVariables.sharedPrefs!.setString("chosenPreset", "worldwidePreset");
                          },
                          text: "Worldwide preset",
                          iconData: Icons.data_array
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                for (int i = 0; i < CapitalCityApi.allCountries.length; i++) ...[
                  capitalCityTile(CapitalCityApi.allCountries[i])
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget capitalCityTile(String countryName) {
    bool isContained = false;
    String capitalCity = CapitalCityApi.getCapitalFromName(countryName)!;

    if (CapitalCityApi.chosenPreset.contains(countryName))
    {
      isContained = true;
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ListTile(
            onTap: () {
              if (CapitalCitiesGuessingData.capitalCitiesFound != 0) // ongoing game
              {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text("Changing the preset restarts the current game. Are you sure you want to continue?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (isContained) {
                              removeCityFromPreset(countryName);
                              isContained = false;
                            }
                            else {
                              addCityToPreset(countryName);
                              isContained = true;
                            }
    
                            generateCity();
    
                            Navigator.pop(context);
    
                            return;
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
              }
              else
              {
                if (isContained) {
                  removeCityFromPreset(countryName);
                  isContained = false;
                }
                else {
                  addCityToPreset(countryName);
                  isContained = true;
                }
              }
            },
            tileColor: const Color.fromARGB(255, 186, 186, 187),
            leading: Text(countryName, style: const TextStyle(fontSize: 16),),
            trailing: Text(capitalCity, style: const TextStyle(fontSize: 16),),
          ),
        ),
        if (isContained) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 2),
            child: Container(
              width: 420,
              height: 65,
              decoration: BoxDecoration(
                color: const Color.fromARGB(158, 255, 255, 255),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green.shade900, size: 18,),
        ],
      ],
    );
  }

  /// Removes city to preset
  void removeCityFromPreset(String countryKey) {
    CapitalCityApi.chosenPreset.remove(countryKey);
    CapitalCityApi.chosenPresetLength--;

    if (CapitalCitiesGuessingData.countryName == countryKey)
    {
      generateCity();
    }

    widget.refreshHomePageCallback();
    setState(() { });
  }

  /// Adds city to preset
  void addCityToPreset(String countryKey) {
    CapitalCityApi.chosenPreset.add(countryKey);
    CapitalCityApi.chosenPresetLength++;

    widget.refreshHomePageCallback();
    setState(() { });
  }

  /// Sets the chosen preset
  void loadPreset(List<String> presetChosen) {
    if (CapitalCitiesGuessingData.capitalCitiesFound != 0) // ongoing game
    {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Confirm"),
            content: const Text("Changing the preset restarts the current game. Are you sure you want to continue?"),
            actions: [
              TextButton(
                onPressed: () {
                  CapitalCityApi.chosenPreset = presetChosen.toList();
                  CapitalCityApi.chosenPresetLength = presetChosen.length;
                  
                  generateCity();
                  Fluttertoast.showToast(msg: "Loaded preset!");
                  return;
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
    }
    else
    {
      CapitalCityApi.chosenPreset = presetChosen.toList();
      CapitalCityApi.chosenPresetLength = presetChosen.length;
      
      generateCity();
      Fluttertoast.showToast(msg: "Loaded preset!");
    }
  }

  /// Generates city to start game
  void generateCity() {
    CapitalCitiesGuessingData.countriesToFind = CapitalCityApi.chosenPreset.toList();
    CapitalCitiesGuessingData.capitalCitiesFound = 0;
    CapitalCitiesGuessingData.capitalCitiesFoundPercentage = 0;
    CapitalCitiesGuessingData.countryIndex = Random().nextInt(CapitalCityApi.chosenPresetLength);
    CapitalCitiesGuessingData.countryName = CapitalCitiesGuessingData.countriesToFind[CapitalCitiesGuessingData.countryIndex];
    CapitalCitiesGuessingData.answer = CapitalCityApi.getCapitalFromName(CapitalCitiesGuessingData.countryName)!;

    widget.refreshHomePageCallback();
    setState(() { });
  }
}