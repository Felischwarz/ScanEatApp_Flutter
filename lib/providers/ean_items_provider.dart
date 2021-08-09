import 'package:ScanEatApp/widgets/household_list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:convert';

import '../utils.dart';
import '../widgets/shopping_list_item.dart';
import '../models/ean_product.dart';
import '../models/custom_ean_product.dart';
import '../widgets/fridge_item.dart';
import '../config.dart' as config;

//indices are used, so new entries need to be added to the end
enum eanProductPage {
  fridge,
  shoppingList,
  householdList,
}

class EanItemsProvider with ChangeNotifier {
  //stores all products with ean data on the my fridge page
  List<EanProduct> fridgeProducts = [];
  //stores all manually created products on the my fridge page
  List<CustomEanProduct> customProducts = [];

  List<EanProduct> shoppingListProducts = [];
  List<EanProduct> householdListProducts = [];

  static final DateFormat dbTimeStampFormat =
      DateFormat("yyyy-MM-dd H-m-s SSS");

  EanItemsProvider() {
    //clearEanProductCache();
    downloadFridgeEans().then((products) {
      return addAndLoadProducts(products, eanProductPage.fridge);
    }).then(
      (_) => loadcustomProducts().then(
        (_) => loadShoppingListProducts().then(
          (_) => loadHouseholdListProducts().then((_) {
            /*
            fridgeProducts.forEach((element) {
              log("fridgeProduct: " +
                  element.name +
                  " " +
                  element.ean.toString());
            });
            shoppingListProducts.forEach((element) {
              log("shoppingListProduct: " +
                  element.name +
                  " " +
                  element.ean.toString());
            });
            householdListProducts.forEach((element) {
              log("householdListProduct: " +
                  element.name +
                  " " +
                  element.ean.toString());
            }); 
            customProducts.forEach((element) {
              log("customProduct: " +
                  element.name +
                  " " +
                  element.ean.toString() +
                  " " +
                  element.page.toString());
            });
            */
          }),
        ),
      ),
    );
  }

  Future<File> get getLocalEanCacheFile async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File("$path/ean_cache.json");
    return file;
  }

  Future<String> get getAppDir async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  //local safe file for storing products of the shoppinglist page
  Future<File> get getshoppingListProductsFile async {
    return getAppDir.then((path) {
      return File("$path/shopping_list_products.json");
    });
  }

  Future<Map<String, String>> get getSavedShoppingListEans async {
    Future<Map<String, String>> eansFuture =
        getshoppingListProductsFile.then((file) {
      return file.readAsString();
    }).then((fileText) {
      Map<String, String> eans;
      try {
        eans = Map<String, String>.from(jsonDecode(fileText));
      } on FormatException catch (_) {
        eans = {};
      }

      return eans;
    });

    return eansFuture;
  }

  Future<void> saveShoppingListEans() async {
    if (shoppingListProducts == null) {
      print("Trying to save shoppingList products but null check failed");
      return;
    }

    Map<String, String> eans = {};
    shoppingListProducts.forEach((prod) {
      eans[dbTimeStampFormat.format(prod.timeStamp)] = prod.ean.toString();
    });

    return getshoppingListProductsFile.then((file) {
      file.writeAsStringSync(jsonEncode(eans));
    });
  }

  Future<void> loadShoppingListProducts() async {
    return getSavedShoppingListEans.then((products) {
      //takes time and ean
      return addAndLoadProducts(products, eanProductPage.shoppingList);
    });
  }

  //local safe file for storing products of the householdList page
  Future<File> get getHouseholdListProductsFile async {
    return getAppDir.then((path) {
      return File("$path/household_list_products.json");
    });
  }

  Future<Map<String, String>> get getSavedHouseholdListEans async {
    Future<Map<String, String>> eansFuture =
        getHouseholdListProductsFile.then((file) {
      return file.readAsString();
    }).then((fileText) {
      Map<String, String> eans;
      try {
        eans = Map<String, String>.from(jsonDecode(fileText));
      } on FormatException catch (_) {
        eans = {};
      }

      return eans;
    });

    return eansFuture;
  }

  Future<void> saveHouseholdListEans() async {
    if (householdListProducts == null) {
      print("Trying to save household products but null check failed");
      return;
    }

    Map<String, String> eans = {};
    householdListProducts.forEach((prod) {
      eans[dbTimeStampFormat.format(prod.timeStamp)] = prod.ean.toString();
    });

    return getHouseholdListProductsFile.then((file) {
      file.writeAsStringSync(jsonEncode(eans));
    });
  }

  Future<void> loadHouseholdListProducts() async {
    return getSavedHouseholdListEans.then((products) {
      return addAndLoadProducts(products, eanProductPage.householdList);
    });
  }

  //local safe file for storing manually added products.
  //The stored json objects contain the eanProductPage, where the product lives in.
  Future<File> get getcustomProductsFile async {
    return getAppDir.then((path) {
      return File("$path/custom_products.json");
    });
  }

  Future<dynamic> get getSavedCustomProducts async {
    Future<dynamic> productsFuture = getcustomProductsFile.then((file) {
      return file.readAsString();
    }).then((fileText) {
      List<dynamic> products;
      try {
        products = jsonDecode(fileText);
      } on FormatException catch (_) {
        products = [];
      }

      return products;
    });

    return productsFuture;
  }

  Future<void> saveCustomProducts() async {
    if (customProducts == null) {
      print("Trying to save household products but null check failed");
      return;
    }

    List<Map<String, dynamic>> products = [];
    customProducts.forEach((prod) {
      final jsonProduct = prod.toJson();
      products.add(jsonProduct);
    });

    return getcustomProductsFile.then((file) {
      file.writeAsStringSync(jsonEncode(products));
    });
  }

  Future<void> loadcustomProducts() async {
    return getSavedCustomProducts.then((products) {
      products.forEach((prod) {
        CustomEanProduct customProd = CustomEanProduct.fromJson(prod);

        addNewProductToPage(customProd, customProd.page);
      });
    });
  }

  Future<dynamic> get getCachedEanProducts async {
    Future<dynamic> productsFuture = getLocalEanCacheFile.then((file) {
      return file.readAsString();
    }).then((fileText) {
      List<dynamic> products;
      try {
        products = jsonDecode(fileText);
      } on FormatException catch (_) {
        products = [];
      }

      return products;
    });

    return productsFuture;
  }

  Future<void> saveEanProductToCache(EanProduct eanProduct) async {
    if (eanProduct.ean != null) {
      final jsonProduct = eanProduct.toJson();

      return getLocalEanCacheFile.then((file) {
        return getCachedEanProducts.then((products) {
          products.add(jsonProduct);
          file.writeAsStringSync(jsonEncode(products));
        });
      });
    }
  }

  Future<void> clearEanProductCache() async {
    await getLocalEanCacheFile.then((file) {
      return file.writeAsStringSync("");
    });
  }

  Future<Map<String, String>> downloadFridgeEans() {
    Future<http.Response> resp =
        http.get(config.user_data_url + config.user_id.toString() + ".json");
    return resp.then((response) {
      Map<String, String> products = {};
      try {
        Map json = jsonDecode(response.body.toString());
        if (json != null) {
          json.forEach((key, value) {
            products[key.toString()] = value.toString();
          });
        } else {
          json = {};
        }
      } on Exception {
        print("ERROR: Could not convert DB Response to Fridge Products.");
      }

      return products;
    });
  }

  Future<void> refreshFridgeItems() {
    fridgeProducts = [];
    return downloadFridgeEans().then((products) {
      return addAndLoadProducts(products, eanProductPage.fridge);
    }).then((_) => notifyListeners());
  }

  Future<http.Response> syncFridgeEansWithDB() {
    Map products = {};

    fridgeProducts.forEach((e) {
      //don't add manual products
      if (e.ean != null) {
        String formattedTimeStamp = dbTimeStampFormat.format(e.timeStamp);
        products[formattedTimeStamp] = e.ean;
      }
    });

    var data = jsonEncode(products);

    return http.put(
      config.user_data_url + config.user_id.toString() + ".json",
      body: data,
    );
  }

  bool allFridgeItemsloaded = true;
  bool allShoppingListItemsloaded = true;
  bool allHouseholdListItemsloaded = true;

  bool itemsOfPageCurrentlyLoading(eanProductPage page) {
    // if no items are currently loading, some of them may be don't have started yet
    bool loading = false;
    if (page == eanProductPage.fridge) {
      fridgeProducts.forEach((prod) {
        try {
          if (prod.ean != null && prod.loadingData) {
            loading = true;
          }
        } on NoSuchMethodError {
          //prod == null
          print("ERROR: $page contains null EanProduct");
        }
      });
    } else if (page == eanProductPage.shoppingList) {
      shoppingListProducts.forEach((prod) {
        try {
          if (prod.ean != null && prod.loadingData) {
            print(prod.id);
            loading = true;
          }
        } on NoSuchMethodError {
          //prod == null
          print("ERROR: $page contains null EanProduct");
        }
      });
    } else if (page == eanProductPage.householdList) {
      householdListProducts.forEach((prod) {
        try {
          if (prod.ean != null && prod.loadingData) {
            loading = true;
          }
        } on NoSuchMethodError {
          //prod == null
          print("ERROR: $page contains null EanProduct");
        }
      });
    } else {
      print("ERROR: Unhandled eanProductPage selected.");
    }

    return loading;
  }

  // mainly used for actionbuttons on the detailpage
  void addProductCopyToPage(int id, eanProductPage page) {
    final prod = getEanProductById(id);
    if (prod is CustomEanProduct) {
      CustomEanProduct newProd = CustomEanProduct.copy(prod);
      newProd.page = page;
      customProducts.add(newProd);
      saveCustomProducts();
      notifyListeners();
    } else if (prod is EanProduct) {
      EanProduct prod = EanProduct.copy(getEanProductById(id));

      if (page == eanProductPage.fridge) {
        fridgeProducts.add(prod);
        syncFridgeEansWithDB(); // also update the DB
      } else if (page == eanProductPage.shoppingList) {
        shoppingListProducts.add(prod);
        saveShoppingListEans();
      } else if (page == eanProductPage.householdList) {
        householdListProducts.add(prod);
        saveHouseholdListEans();
      } else {
        print("ERROR: Unhandled eanProductPage selected.");
      }

      notifyListeners();
    } else {
      print("ERROR: prod is neither CustomEanProduct nor EanProduct");
    }
  }

  // mainly used for adding custom products
  void addNewProductToPage(Object prod, eanProductPage page) {
    if (prod is CustomEanProduct) {
      customProducts.add(prod);
      saveCustomProducts();
      notifyListeners();
    } else if (prod is EanProduct) {
      if (page == eanProductPage.fridge) {
        fridgeProducts.add(prod);
        syncFridgeEansWithDB(); // also update the DB

      } else if (page == eanProductPage.shoppingList) {
        shoppingListProducts.add(prod);
        saveShoppingListEans();
      } else if (page == eanProductPage.householdList) {
        householdListProducts.add(prod);
        saveHouseholdListEans();
      } else {
        print("ERROR: Unhandled eanProductPage selected.");
      }

      notifyListeners();
    } else {
      print("ERROR: prod is neither CustomEanProduct nor EanProduct");
    }
  }

  void deleteListProductOfPage(int id, eanProductPage page) {
    customProducts.removeWhere(
      (prod) => prod.id == id,
    );
    saveCustomProducts();

    if (page == eanProductPage.fridge) {
      fridgeProducts.removeWhere(
        (prod) => prod.id == id,
      );
      syncFridgeEansWithDB(); // also update the DB

    } else if (page == eanProductPage.shoppingList) {
      shoppingListProducts.removeWhere(
        (prod) => prod.id == id,
      );
      saveShoppingListEans();
    } else if (page == eanProductPage.householdList) {
      householdListProducts.removeWhere(
        (prod) => prod.id == id,
      );
      saveHouseholdListEans();
    } else {
      print("ERROR: Unhandled eanProductPage selected.");
    }

    notifyListeners();
  }

  /* 
  used to load multiple ean items for a page and show a loading icon while loading.
  call the function just once for muliple to avoid multiple reloads on the page. 
  Also this function should only be could sequentially and in the function, every product should be added sequentially as well.
  Use it only for real ean products, not for custom ones.
   */
  Future<void> addAndLoadProducts(
      Map<String, String> products, eanProductPage page) async {
    List<EanProduct> pageProducts() {
      if (page == eanProductPage.fridge) {
        return fridgeProducts;
      } else if (page == eanProductPage.shoppingList) {
        return shoppingListProducts;
      } else if (page == eanProductPage.householdList) {
        return householdListProducts;
      } else {
        print("ERROR: Unhandled eanProductPage selected.");
        return [];
      }
    }

    void itemsLoaded(bool value) {
      if (page == eanProductPage.fridge) {
        allFridgeItemsloaded = value;
      } else if (page == eanProductPage.shoppingList) {
        allShoppingListItemsloaded = value;
      } else if (page == eanProductPage.householdList) {
        allHouseholdListItemsloaded = value;
      } else {
        print("ERROR: Unhandled eanProductPage selected.");
      }
    }

    products.length != 0 ? itemsLoaded(false) : itemsLoaded(true);
    notifyListeners();

    int loadedCount = 0;
    void progress() {
      loadedCount += 1;

      if (loadedCount >= products.length &&
          !itemsOfPageCurrentlyLoading(page)) {
        itemsLoaded(true);
        notifyListeners();
      }
    }

    for (MapEntry<String, String> product in products.entries) {
      String timeStamp = product.key;
      String ean = product.value;

      EanProduct prod;
      DateTime time;

      try {
        time = dbTimeStampFormat.parse(timeStamp);
      } on Exception {
        print(
            "ERROR: Could not convert DB TimeStamp ($timeStamp) of ean $ean to DateTime.");
        time = DateTime.now();
      }

      if (!Utils.isNumeric(ean)) {
        print("WARNING: Ean ($ean) is not numeric.");
        //Add the product as ERROR prod
        prod = EanProduct(ean, time);
        pageProducts().add(prod);
        progress();
      } else {
        //check if a cashed version exsists
        bool foundCached = false;
        await getCachedEanProducts.then((products) {
          products.forEach((product) {
            if (int.parse(product["ean"]) == int.parse(ean)) {
              prod = EanProduct.cached(product, time);
              pageProducts().add(prod);
              foundCached = true;
              progress();
              return;
            }
          });

          if (!foundCached) {
            prod = EanProduct(ean, time);

            pageProducts().add(prod);
            return prod.loadEanData(ean).then((success) async {
              if (success) {
                await saveEanProductToCache(prod).then(
                    (_) => print("safed product with ean ($ean) to cache."));
              } else {
                print("Loading of EanProduct (ean: " + ean + ") failed.");
              }
              progress();
              return;
            });
          }
        });
      }
    }
    return;
  }

  List<FridgeItem> get getFridgeItems {
    List<FridgeItem> fridgeitems = [];
    fridgeProducts.forEach((prod) {
      fridgeitems.add(FridgeItem(
          prod.id,
          prod.name,
          prod.estimatedShelfLifeDays,
          prod.trueBestBeforeDate,
          prod.timeStamp));
    });
    customProducts.forEach((prod) {
      if (prod.page == eanProductPage.fridge) {
        fridgeitems.add(FridgeItem(
            prod.id,
            prod.name,
            prod.estimatedShelfLifeDays,
            prod.trueBestBeforeDate,
            prod.timeStamp));
      }
    });

    return fridgeitems;
  }

  List<ShoppingListItem> get getShoppingListItems {
    List<ShoppingListItem> shoppingListItems = [];
    shoppingListProducts.forEach((prod) {
      shoppingListItems
          .add(ShoppingListItem(prod.id, prod.name, prod.timeStamp));
    });

    customProducts.forEach((prod) {
      if (prod.page == eanProductPage.shoppingList) {
        shoppingListItems
            .add(ShoppingListItem(prod.id, prod.name, prod.timeStamp));
      }
    });
    return shoppingListItems;
  }

  List<HouseholdListItem> get getHouseholdListItems {
    List<HouseholdListItem> householdListItems = [];
    householdListProducts.forEach((prod) {
      bool existingInFridge;
      if (prod.ean != null) {
        existingInFridge =
            fridgeProducts.any((element) => element.ean == prod.ean);
      } else {
        print("ERROR: Trying to load housholdlist item but ean is null");
      }

      householdListItems.add(HouseholdListItem(
        prod.id,
        prod.name,
        prod.timeStamp,
        existingInFridge,
      ));
    });

    customProducts.forEach((prod) {
      if (prod.page == eanProductPage.householdList) {
        bool existingInFridge;
        if (prod.ean == null) {
          existingInFridge = customProducts.any((element) =>
              element.page == eanProductPage.fridge &&
              element.name.replaceAll(" ", "") ==
                  prod.name.replaceAll(" ", ""));
        } else {
          print(
              "ERROR: Trying to load housholdlist item but ean is not null for a custom product");
        }

        householdListItems.add(HouseholdListItem(
          prod.id,
          prod.name,
          prod.timeStamp,
          existingInFridge,
        ));
      }
    });

    return householdListItems;
  }

  dynamic getEanProductById(int id) {
    dynamic item;
    fridgeProducts.forEach((prod) {
      if (prod.id == id) {
        item = prod;
      }
    });
    shoppingListProducts.forEach((prod) {
      if (prod.id == id) {
        item = prod;
      }
    });
    householdListProducts.forEach((prod) {
      if (prod.id == id) {
        item = prod;
      }
    });
    customProducts.forEach((prod) {
      if (prod.id == id) {
        item = prod;
      }
    });

    return item;
  }
}
