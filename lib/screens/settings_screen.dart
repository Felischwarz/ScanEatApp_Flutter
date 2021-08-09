import 'package:ScanEatApp/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style.dart';

class SettingsScreen extends StatefulWidget {
  static const pageRoute = "/settings";

  //final Function changeTheme;

  SettingsScreen();

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    Function changeTheme =
        Provider.of<ThemeProvider>(context).changeTheme;
    return Scaffold(
      appBar: ScanEatAppStyle.createGradientAppBar(
        title: "Settings",
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              "Dark Theme",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            subtitle: Text(
              "Change the App appearance",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            trailing: Switch(
              value: ScanEatAppStyle.currentThemeIsDarkTheme,
              onChanged: (newValue) {
                setState(() {
                  newValue ? changeTheme(true) : changeTheme(false);
                });
              },
              activeTrackColor: ScanEatAppStyle.gradient1Start,
              activeColor: ScanEatAppStyle.gradient1End,
            ),
          ),
        ],
      ),
    );
  }
}
