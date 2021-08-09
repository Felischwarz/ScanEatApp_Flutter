import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/household_list_screen.dart';
import './screens/tabs_screen.dart';
import './screens/settings_screen.dart';
import './screens/product_detail_screen.dart';
import './style.dart';
import './providers/ean_items_provider.dart';
import './providers/theme_provider.dart';

void main() => runApp(ScanEatApp());

class ScanEatApp extends StatefulWidget {
  @override
  _ScanEatAppState createState() => _ScanEatAppState();
}

class _ScanEatAppState extends State<ScanEatApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => EanItemsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ThemeProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          context.watch<ThemeProvider>();
          return MaterialApp(
              title: "ScanEatApp",
              theme: ScanEatAppStyle.currentTheme,
              debugShowCheckedModeBanner: false,
              routes: {
                "/": (ctx) => TabsScreen(),
                SettingsScreen.pageRoute: (ctx) => SettingsScreen(),
                ProductDetailScreen.pageRoute: (ctx) => ProductDetailScreen(),
                HouseholdListScreen.pageRoute: (ctx) => HouseholdListScreen(),
              });
        },
      ),
    );
  }
}
