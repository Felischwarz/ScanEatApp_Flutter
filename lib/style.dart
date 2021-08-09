import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScanEatAppStyle {
  static Color get gradient1Start => Color.fromRGBO(18, 255, 247, 1.0);
  static Color get gradient1End => Color.fromRGBO(179, 255, 171, 1.0);

  static LinearGradient get gradient1 {
    return LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        gradient1Start,
        gradient1End,
      ],
    );
  }

  static Color get gradient2Start => Color.fromRGBO(11, 163, 96, 1.0);
  static Color get gradient2End => Color.fromRGBO(60, 186, 146, 1.0);

  static LinearGradient get gradient2 {
    return LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        gradient2Start,
        gradient2End,
      ],
    );
  }

  static ShaderMask createGradientShaderMask({
    @required Widget child,
    @required Gradient gradient,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: child,
    );
  }

  static AppBar createGradientAppBar({
    @required String title,
    Widget leading,
    List<Widget> actions,
    IconThemeData iconTheme,
  }) {
    return AppBar(
      centerTitle: true,
      leading: leading,
      title: ScanEatAppStyle.createGradientShaderMask(
        child: Text(title),
        gradient: currentThemeIsDarkTheme ? gradient1 : gradient2,
      ),
      actions: actions,
      iconTheme: iconTheme,
    );
  }

  // custom colors
  static Color get customDarkPrimaryColor => Color(0xff303033);
  static Color get customDarkDetailColor =>
      Color(0xff969696); //Color(0xff070707);
  static Color get customGreyDetailColor => Color(0xff5c5c5c);

  // error / status colors https://material-ui.com/customization/palette/
  static Color get danger =>
      currentThemeIsDarkTheme ? Color(0xffe57373) : Color(0xffd32f2f);
  static Color get warning =>
      currentThemeIsDarkTheme ? Color(0xffffb74d) : Color(0xfff57c00);

  static Color get grey =>
      currentThemeIsDarkTheme ? customDarkDetailColor : customGreyDetailColor;

  // current theme is also the startup default
  static ThemeData currentTheme = darkTheme;
  static bool get currentThemeIsDarkTheme {
    if (currentTheme == darkTheme) {
      return true;
    }
    return false;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light().copyWith(primary: customGreyDetailColor),
      primaryColor: Color(0xffffffff),
      primaryColorDark: customGreyDetailColor,
      canvasColor: Color(0xffffffff),
      iconTheme: IconThemeData(
        color: customGreyDetailColor,
      ),
      cardColor: Color(0xffe3e3e3),
      accentColor: gradient2Start,
      fontFamily: "Hind",
      textTheme: TextTheme(
        bodyText1: TextStyle(
          color: Color(0xff000000),
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodyText2: TextStyle(
          color: Color(0xff000000),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        subtitle1: TextStyle(
          color: customGreyDetailColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.light().copyWith(primary: customDarkPrimaryColor),
      primaryColor: customDarkPrimaryColor,
      primaryColorDark: customDarkDetailColor,
      canvasColor: Color(0xff363639),
      iconTheme: IconThemeData(
        color: customDarkDetailColor,
      ),
      cardColor: customDarkPrimaryColor,
      accentColor: gradient1Start,
      fontFamily: "Hind",
      textTheme: TextTheme(
        bodyText1: TextStyle(
          color: Color(0xffffffff),
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodyText2: TextStyle(
          color: Color(0xff000000),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        subtitle1: TextStyle(
          color: Color(0xff919191),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      
    );
  }

  static RaisedButton createRaisedButton({Function onPressed, Widget child}) {
    return RaisedButton(
      onPressed: onPressed,
      child: child,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10),
      ),
      color: currentTheme.cardColor,
    );
  }
}
