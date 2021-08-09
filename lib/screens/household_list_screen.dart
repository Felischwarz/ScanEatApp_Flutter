import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style.dart';
import '../providers/ean_items_provider.dart';
import '../widgets/household_list_item.dart';
import '../widgets/add_product_bottom_sheet/add_product_bottom_sheet.dart';
import '../providers/theme_provider.dart';

class HouseholdListScreen extends StatefulWidget {
  static const String pageRoute = "/householdList";

  @override
  _HouseholdListScreenState createState() => _HouseholdListScreenState();
}

class _HouseholdListScreenState extends State<HouseholdListScreen> {
  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);

    List<HouseholdListItem> householdListItems =
        Provider.of<EanItemsProvider>(context).getHouseholdListItems;

    bool allItemsloaded =
        Provider.of<EanItemsProvider>(context).allHouseholdListItemsloaded;

    return Scaffold(
      appBar: ScanEatAppStyle.createGradientAppBar(
        title: "Household List",
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      body: allItemsloaded
          ? ListView.builder(
              padding: EdgeInsets.only(
                top: 10,
              ),
              itemCount: householdListItems.length,
              itemBuilder: (ctx, index) {
                return householdListItems[index];
              },
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
            builder: (ctx) =>
                AddProductBottomSheet(eanProductPage.householdList)),
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
