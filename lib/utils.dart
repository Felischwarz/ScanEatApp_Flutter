class Utils {
  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  static String daysToDuration(int days) {
    String res;
    int length;
    String intervalName;
    
    if (days.abs() >= 365) {
      length = days ~/ 365;
      intervalName = "year";
    }
    else if(days.abs() >= 30) {
      length = days ~/ 30;
      intervalName = "month";
    }
    else if(days.abs() >= 7) {
      length = days ~/ 7;
      intervalName = "week";
    }
    else {
      length = days;
      intervalName = "day";
    }
    

    if(length.abs() == 1)
    {
      res = length.toString() + " " + intervalName;
    }
    else if(length.abs() > 1)
    {
      res = length.toString() + " " + intervalName + "s";
    }

    return res;
  }
}
