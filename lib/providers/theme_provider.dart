import 'package:flutter/material.dart';

import '../style.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider();

  void changeTheme(bool toDark) {
    toDark
        ? ScanEatAppStyle.currentTheme = ScanEatAppStyle.darkTheme
        : ScanEatAppStyle.currentTheme = ScanEatAppStyle.lightTheme;

    notifyListeners();
  }
}
