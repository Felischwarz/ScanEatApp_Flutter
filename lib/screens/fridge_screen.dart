import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/add_product_bottom_sheet/add_product_bottom_sheet.dart';
import '../providers/ean_items_provider.dart';
import '../style.dart';
import '../widgets/fridge_item.dart';

class FridgeScreen extends StatefulWidget {
  @override
  _FridgeScreenState createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  @override
  Widget build(BuildContext context) {
    List<FridgeItem> fridgeItems =
        Provider.of<EanItemsProvider>(context).getFridgeItems;

    Provider.of<ThemeProvider>(context);

    Function refresh =
        Provider.of<EanItemsProvider>(context).refreshFridgeItems;

    fridgeItems.sort((a, b) => a.productTimeStep.compareTo(b.productTimeStep));
    bool allItemsloaded =
        Provider.of<EanItemsProvider>(context).allFridgeItemsloaded;

    return Scaffold(
      body: allItemsloaded
          ? RefreshIndicator(
              onRefresh: refresh,
              displacement: 80,
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: 10,
                ),
                itemCount: fridgeItems.length,
                itemBuilder: (ctx, index) {
                  return fridgeItems[index];
                },
              ),
            )
          : Center(
              child: ScanEatAppStyle.createGradientShaderMask(
                child: CircularProgressIndicator(),
                gradient: ScanEatAppStyle.currentThemeIsDarkTheme
                    ? ScanEatAppStyle.gradient1
                    : ScanEatAppStyle.gradient2,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
            context: context,
            builder: (ctx) => AddProductBottomSheet(eanProductPage.fridge)),
        child: ScanEatAppStyle.createGradientShaderMask(
          child: Icon(Icons.add),
          gradient: ScanEatAppStyle.currentThemeIsDarkTheme
              ? ScanEatAppStyle.gradient1
              : ScanEatAppStyle.gradient2,
        ),
        backgroundColor: ScanEatAppStyle.currentTheme.canvasColor,
      ),
    );
  }
}
