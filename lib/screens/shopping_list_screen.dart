import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style.dart';
import '../providers/ean_items_provider.dart';
import '../widgets/shopping_list_item.dart';
import '../widgets/add_product_bottom_sheet/add_product_bottom_sheet.dart';
import '../providers/theme_provider.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);

    List<ShoppingListItem> shoppingListItems =
        Provider.of<EanItemsProvider>(context).getShoppingListItems;
    bool allItemsloaded =
        Provider.of<EanItemsProvider>(context).allShoppingListItemsloaded;

    return Scaffold(
      body: allItemsloaded
          ? ListView.builder(
              padding: EdgeInsets.only(
                top: 10,
              ),
              itemCount: shoppingListItems.length,
              itemBuilder: (ctx, index) {
                return shoppingListItems[index];
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
            builder: (ctx) => AddProductBottomSheet(eanProductPage.shoppingList)),
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
