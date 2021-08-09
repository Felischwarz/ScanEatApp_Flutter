import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils.dart';
import '../config.dart' as config;

class EanProduct {
  static const String userid = "400000000";
  static int _lastId = 0;

  int _id; //only exsists for instances of EanProduct. Not in safed data
  int get id => _id;

  //is null if it's a manual product
  int ean;

  String name;
  String detailname;
  String vendor;
  String maincat;
  String subcat;
  int contents; //Flags
  int pack; //Flags
  String descr;
  String origin;
  String validated;
  int estimatedShelfLifeDays; //only estimated!

  DateTime trueBestBeforeDate; //the real best Before Date

  List<String> contentProperties;
  List<String> packProperties;

  Map get contentsValues {
    return {
      1: "laktosefrei",
      2: "koffeeinfrei",
      4: "diätetisches Lebensmittel",
      8: "glutenfrei",
      16: "fruktosefrei",
      32: "BIO-Lebensmittel nach EU-Ökoverordnung",
      64: "fair gehandeltes Produkt nach FAIRTRADE™-Standard",
      128: "vegetarisch",
      256: "vegan",
      512: "Warnung vor Mikroplastik",
      1024: "Warnung vor Mineralöl",
      2048: "Warnung vor Nikotin"
    };
  }

  Map get packValues {
    return {
      1: "die Verpackung besteht überwiegend aus Plastik",
      2: "die Verpackung besteht überwiegend aus Verbundmaterial",
      4: "die Verpackung besteht überwiegend aus Papier/Pappe",
      8: "die Verpackung besteht überwiegend aus Glas/Keramik/Ton",
      16: "die Verpackung besteht überwiegend aus Metall",
      32: "ist unverpackt",
      64: "die Verpackung ist komplett frei von Plastik",
      128: "Artikel ist übertrieben stark verpackt",
      256: "Artikel ist angemessen sparsam verpackt",
      512: "Pfandsystem / Mehrwegverpackung",
    };
  }

  DateTime _timeStamp;
  DateTime get timeStamp => _timeStamp;

  bool _loadingData = false;
  bool get loadingData {
    return _loadingData;
  }

  EanProduct.manually({
    @required this.name,
    this.detailname,
    this.vendor,
    this.maincat,
    this.subcat,
    this.descr,
    this.origin,
    this.validated,
    this.estimatedShelfLifeDays,
    this.contentProperties,
    this.packProperties,
    this.trueBestBeforeDate,
    newTimeStamp,
  }) {
    _createId();

    if (contents != null) {
      contentProperties = _getContentProperties(contents);
    }
    if (pack != null) {
      packProperties = _getPackProperties(pack);
    }

    newTimeStamp == null
        ? _timeStamp = DateTime.now()
        : _timeStamp = newTimeStamp;
  }

  EanProduct.cached(dynamic jsonProd, DateTime timeStamp) {
    _createId();

    try {
      ean = int.parse(jsonProd["ean"]);
      name = jsonProd["name"];
      detailname = jsonProd["detailname"];
      vendor = jsonProd["vendor"];
      maincat = jsonProd["maincat"];
      subcat = jsonProd["subcat"];
      descr = jsonProd["descr"];
      origin = jsonProd["origin"];
      validated = jsonProd["validated"];
      estimatedShelfLifeDays = jsonProd["estimatedShelfLifeDays"];
      contentProperties = jsonProd["contentProperties"]?.cast<String>();
      packProperties = jsonProd["packProperties"]?.cast<String>();
      trueBestBeforeDate = jsonProd["trueBestBeforeDate"]?.cast<String>();
      _timeStamp = timeStamp;
    } on Exception catch (e) {
      print("Error: Bad json data provided for EanProduct. Full exception: " +
          e.toString());
    }
  }

  EanProduct.copy(EanProduct prod) {
    _createId();

    try {
      ean = prod.ean;
      name = prod.name;
      detailname = prod.detailname;
      vendor = prod.vendor;
      maincat = prod.maincat;
      subcat = prod.subcat;
      descr = prod.descr;
      origin = prod.origin;
      validated = prod.validated;
      estimatedShelfLifeDays = prod.estimatedShelfLifeDays;
      contentProperties = prod.contentProperties;
      packProperties = prod.packProperties;

      _timeStamp = DateTime.now();
    } on Exception catch (e) {
      print("Error: could not create copy of ean product (id: " +
          prod.id.toString() +
          ")" +
          e.toString());
    }
  }

  EanProduct(String ean, DateTime timeStamp) {
    _createId();
    _timeStamp = timeStamp;

    if (!Utils.isNumeric(ean)) {
      print("ERROR: EAN is not numeric");
      name = "ERROR";
      detailname = 'EAN: "$ean" is not numeric';
      return;
    }

    this.ean = int.parse(ean);
    name = "loading " + ean + "... ";
  }

  Future<bool> loadEanData(String ean) async {
    name = ean;
    print("loading data for ean($ean)...");

    if (!Utils.isNumeric(ean)) {
      print("ERROR: EAN is not numeric");
      name = "ERROR";
      detailname = 'EAN: "$ean" is not numeric';
      return false;
    }

    this.ean = int.parse(ean);
    bool foundError = false;
    _loadingData = true;

    final url =
        "http://opengtindb.org/?ean=" + ean + "&cmd=query&queryid=" + userid;
    await http.get(url).then((response) {
      //Checking for network errors
      if (response.statusCode != 200) {
        print("Response code: " +
            response.statusCode.toString() +
            ". Stopped creating a product...");

        name = "ERROR";
        detailname =
            "EAN: $ean, Response code: " + response.statusCode.toString();
        _loadingData = false;
        foundError = true;
        return;
      }

      List<String> responsLines = response.body.split("\n");

      //Checking for EAN errors
      List<String> lineValues = responsLines[1].split("=");
      if (lineValues.length < 2) {
        print("No Ean errorcode found! Stopped creating a product...");
        _loadingData = false;
        foundError = true;
        return;
      }

      if (!Utils.isNumeric(lineValues[1])) {
        print("No valid Ean errorcode found! Stopped creating a product...");
        _loadingData = false;
        foundError = true;
        return;
      }

      int eanErrorCode = int.parse(lineValues[1]);
      if (eanErrorCode != 0) {
        print("EAN ERROR: " +
            eanErrorCode.toString() +
            ". Stopped creating a product...");

        name = "ERROR";
        detailname = "EAN: $ean, API Response code: $eanErrorCode";
        _loadingData = false;
        foundError = true;
        return;
      }

      //Creating EanProduct
      responsLines.forEach((line) {
        List<String> fields = line.split("=");

        //skip if there is no field
        if (fields.length < 2) {
          return;
        }

        String value = fields[1];
        value = value.replaceAll("\\n", "\n");

        if (value == "") {
          return;
        }

        switch (fields[0]) {
          case "name":
            name = value;
            break;

          case "detailname":
            detailname = value;
            break;

          case "vendor":
            vendor = value;
            break;

          case "maincat":
            maincat = value;
            if (estimatedShelfLifeDays == null) {
              estimatedShelfLifeDays =
                  _getEstimatedShelfLifeDaysForMaincat(maincat);
            }

            break;

          case "subcat":
            subcat = value;
            if (estimatedShelfLifeDays == null) {
              estimatedShelfLifeDays =
                  _getEstimatedShelfLifeDaysForSubcat(subcat);
            }
            break;

          case "contents":
            if (Utils.isNumeric(value)) {
              contents = int.parse(value);
            }
            break;

          case "pack":
            if (Utils.isNumeric(value)) {
              pack = int.parse(value);
            }
            break;

          case "descr":
            descr = value;
            break;

          case "origin":
            origin = value;
            break;

          case "validated":
            validated = value;
            break;
        }
      });

      contentProperties = _getContentProperties(contents);
      packProperties = _getPackProperties(pack);

      _loadingData = false;
    });
    if (foundError) {
      return false;
    } else {
      return true;
    }
  }

  List<String> _getContentProperties(dynamic contents) {
    List<String> properties = [];
    if (contents == null) {
      return [];
    }

    List<int> flags = _getFlags(contents);
    flags.forEach((flag) {
      properties.add(contentsValues[flag]);
    });

    return properties;
  }

  List<String> _getPackProperties(dynamic pack) {
    List<String> properties = [];
    if (pack == null) {
      return [];
    }

    List<int> flags = _getFlags(pack);
    flags.forEach((flag) {
      if (flag == 32) {
        //ist unverpackt (immer zusammen mit 64, nie zusammen mit 128 und 256)
        bool found_64 = false;
        flags.forEach((flag2) {
          if (flag2 == 128 || flag2 == 256) {
            flags.remove(flag2);
          }

          if (flag2 == 64) {
            found_64 = true;
          }
        });

        if (!found_64) {
          properties.add(packValues[64]);
        }
      }

      if (flag == 64) {
        //die Verpackung ist komplett frei von Plastik (nie zusammen mit 1 oder 2)
        flags.forEach((flag2) {
          if (flag2 == 1 || flag2 == 2) {
            flags.remove(flag2);
          }
        });
      }

      if (flag == 128) {
        //Artikel ist übertrieben stark verpackt (nie zusammen mit 32)
        flags.forEach((flag2) {
          if (flag2 == 32) {
            flags.remove(flag2);
          }
        });
      }

      properties.add(packValues[flag]);
    });

    return properties;
  }

  List<int> _getFlags(int value) {
    List<int> flags = [];

    while (value > 0) {
      int res;
      if (value == 1) {
        res = 1;
      } else {
        int exp = 0;
        res = 0;
        while ((pow(2, exp).toInt()) <= value) {
          res = pow(2, exp).toInt();
          exp++;
        }
      }
      flags.add(res);
      value -= res;
    }
    return flags;
  }

  /*
  Gets the estimated shelf live days for the main category, which are provided in the config.dart.
  If found it returns the days, else null.
  */
  dynamic _getEstimatedShelfLifeDaysForMaincat(String maincat) {
    int days;
    config.estimatedMaincatShelfLifeDays.forEach((key, value) {
      if (maincat.toLowerCase() == key.toLowerCase()) {
        days = value;
      }
    });
    return days;
  }

  /*
  Gets the estimated shelf live days for the sub category, which are provided in the config.dart.
  If found it returns the days, else null.
  */
  dynamic _getEstimatedShelfLifeDaysForSubcat(String subcat) {
    int days;
    config.estimatedSubcatShelfLifeDays.forEach((key, value) {
      if (subcat.toLowerCase() == key.toLowerCase()) {
        days = value;
      }
    });
    return days;
  }

  /*
  Calculates the estimated best before date based on the time, when the product was added to the fridge.
  */
  DateTime calculateEstimatedBestBeforeDate() {
    if (timeStamp == null || estimatedShelfLifeDays == null) {
      print(
          "ERROR: Trying to caluclate best before date for ean product (id: $id) but either timeStamp or estimatedShelfLifeDays is null!");
      return null;
    }

    DateTime date = timeStamp;
    date = date.add(new Duration(days: estimatedShelfLifeDays));
    return date;
  }

  _createId() {
    _lastId++;
    _id = _lastId;
  }

  void logData() {
    print("ean: " +
        ean.toString() +
        "\n" +
        "name: " +
        name.toString() +
        "\n" +
        "detailname: " +
        detailname.toString() +
        "\n" +
        "vendor: " +
        vendor.toString() +
        "\n" +
        "maincat: " +
        maincat.toString() +
        "\n" +
        "subcat: " +
        subcat.toString() +
        "\n" +
        "contents: " +
        contents.toString() +
        "\n" +
        "pack: " +
        pack.toString() +
        "\n" +
        "descr: " +
        descr.toString() +
        "\n" +
        "origin: " +
        origin.toString() +
        "\n" +
        "validated: " +
        validated.toString() +
        "\n" +
        "estimatedShelfLifeDays: " +
        estimatedShelfLifeDays.toString() +
        "trueBestBeforeDate: " +
        trueBestBeforeDate.toString() +
        "\n" +
        "timeStemp: " +
        timeStamp.toString() +
        "\n");
  }

  Map<String, dynamic> toJson() => {
        "ean": this.ean.toString(),
        "name": this.name,
        "detailname": this.detailname,
        "vendor": this.vendor,
        "maincat": this.maincat,
        "subcat": this.subcat,
        "descr": this.descr,
        "origin": this.origin,
        "validated": this.validated,
        "estimatedShelfLifeDays": this.estimatedShelfLifeDays,
        "trueBestBeforeDate": this.trueBestBeforeDate,
        "contentProperties": this.contentProperties,
        "packProperties": this.packProperties,
      };
}
