import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ean_items_provider.dart';

import '../screens/product_detail_screen.dart';
import './list_item.dart';
import '../style.dart';

class HouseholdListItem extends StatelessWidget {
  final int productId;
  final String productName;
  final DateTime timeStep;
  final bool existingInFridge;

  HouseholdListItem(
      this.productId, this.productName, this.timeStep, this.existingInFridge);

  Widget _createTrailing() {
    return existingInFridge
        ? ScanEatAppStyle.createGradientShaderMask(
            child: Icon(
              Icons.check,
            ),
            gradient: ScanEatAppStyle.currentThemeIsDarkTheme
                ? ScanEatAppStyle.gradient1
                : ScanEatAppStyle.gradient2,
          )
        : Icon(
            Icons.clear,
            color: ScanEatAppStyle.danger,
          );
  }

  @override
  Widget build(BuildContext context) {
    final Function onDismissed =
        Provider.of<EanItemsProvider>(context).deleteListProductOfPage;

    return ListItem(
      key: UniqueKey(),
      onTap: () {
        Navigator.pushNamed(context, ProductDetailScreen.pageRoute,
            arguments: ProductDetailScreenArgs(
                productId, eanProductPage.householdList));
      },
      onDismissed: (direction) {
        onDismissed(productId, eanProductPage.householdList);
      },
      title: productName,
      trailing: _createTrailing(),
    );
  }
}
