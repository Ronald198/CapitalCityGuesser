import 'package:capitalcityguesser/constants.dart';
import 'package:capitalcityguesser/services/capitals.dart';
import 'package:capitalcityguesser/widgets/drawer.dart';
import 'package:flutter/material.dart';

class CapitalCitiesCatalog extends StatefulWidget {
  const CapitalCitiesCatalog({super.key});

  @override
  State<CapitalCitiesCatalog> createState() => _CapitalCitiesCatalogState();
}

class _CapitalCitiesCatalogState extends State<CapitalCitiesCatalog> {
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
      title: const Text("Capital Cities Catalog"),
    );
  }

  Widget getBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: RawScrollbar(
        thumbColor: CapitalCityGuesserPalette.mainColor,
        thickness: 8,
        radius: const Radius.circular(30),
        crossAxisMargin: 2,
        child: ListView(
          children: [
            for (int i = 0; i < CapitalCityApi.allCountries.length; i++) ...[
              capitalCityTile(CapitalCityApi.allCountries[i])
            ],
          ],
        ),
      ),
    );
  }

  Widget capitalCityTile(String countryName) {
    String capitalCity = CapitalCityApi.getCapitalFromName(countryName)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: ListTile(
        tileColor: const Color.fromARGB(255, 186, 186, 187),
        leading: Text(countryName, style: const TextStyle(fontSize: 16),),
        trailing: Text(capitalCity, style: const TextStyle(fontSize: 16),),
      ),
    );
  }
}