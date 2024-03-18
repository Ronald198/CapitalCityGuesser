import 'package:capitalcityguesser/constants.dart';
import 'package:capitalcityguesser/databaseManager.dart';
import 'package:capitalcityguesser/pages/home_page.dart';
import 'package:capitalcityguesser/services/capitals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaticVariables {
  static int pageIndex = 0;
  static SharedPreferences? sharedPrefs;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StaticVariables.sharedPrefs = await SharedPreferences.getInstance();

  if (!StaticVariables.sharedPrefs!.containsKey("chosenPreset"))
  {
    await StaticVariables.sharedPrefs!.setString("chosenPreset", "worldwidePreset");
    CapitalCityApi.loadPreset(CapitalCityApi.allCountries);
  }
  else
  {
    String chosenPreset = StaticVariables.sharedPrefs!.getString("chosenPreset")!;

    switch (chosenPreset) {
      case "worldwidePreset":
        CapitalCityApi.loadPreset(CapitalCityApi.allCountries);
        break;
      case "europePreset":
        CapitalCityApi.loadPreset(CapitalCityApi.europePreset);
        break;
      case "asiaPreset":
        CapitalCityApi.loadPreset(CapitalCityApi.asiaPreset);     
        break;
      case "africaPreset":
        CapitalCityApi.loadPreset(CapitalCityApi.africaPreset);
        break;
      case "northAmericaPreset":
        CapitalCityApi.loadPreset(CapitalCityApi.northAmericaPreset);
        break;
      case "southAmericaPreset":
        CapitalCityApi.loadPreset(CapitalCityApi.southAmericaPreset);
        break;
      case "oceaniaPreset":
        CapitalCityApi.loadPreset(CapitalCityApi.oceaniaPreset);
        break;
      case "customPreset":
        CapitalPreset? customPreset = await DatabaseManager.instance.getCapitalsPresetById(1);
        CapitalCityApi.loadPreset(customPreset!.capitalCities);
        break;
    }
  }

  runApp(const CapitalCityGuesserMain());
}

class CapitalCityGuesserMain extends StatelessWidget {
  const CapitalCityGuesserMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capital City Guesser',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: CapitalCityGuesserPalette.mainColor,
          foregroundColor: Colors.white
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Color.fromARGB(255, 177, 175, 175)),
        scaffoldBackgroundColor: const Color.fromARGB(255, 218, 216, 216),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: CapitalCityGuesserPalette.mainColor,
          foregroundColor: Colors.white
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 112, 111, 111),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const HomePage(),
    );
  }
}