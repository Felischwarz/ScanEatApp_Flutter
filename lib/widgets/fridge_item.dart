import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../screens/product_detail_screen.dart';
import '../providers/ean_items_provider.dart';
import './list_item.dart';
import '../config.dart';
import '../style.dart';

class FridgeItem extends StatelessWidget {
  final int productId;
  final String productName;
  final int productEstimatedShelfLifeDays;
  final DateTime productTrueBestBeforeDate;
  final DateTime productTimeStep;

  FridgeItem(
      this.productId,
      this.productName,
      this.productEstimatedShelfLifeDays,
      this.productTrueBestBeforeDate,
      this.productTimeStep);

  Text createSubtitle(BuildContext ctx) {
    int deltaDays = DateTime.now().difference(productTimeStep).inDays;
    TextStyle subtitleStyle;
    int daysUntilExpiration;
    if (productTrueBestBeforeDate != null) {
      daysUntilExpiration =
          productTimeStep.difference(productTrueBestBeforeDate).inDays.abs();
    } else if (productEstimatedShelfLifeDays != null) {
      daysUntilExpiration = productEstimatedShelfLifeDays;
    } else {
      daysUntilExpiration = defaultDeltaDaysDanger;
    }

    if (deltaDays >= daysUntilExpiration) {
      subtitleStyle = Theme.of(ctx)
          .textTheme
          .subtitle1
          .apply(color: ScanEatAppStyle.danger);
    } else if (deltaDays >=
        daysUntilExpiration - warningDaysBeforeProductExpiration) {
      subtitleStyle = Theme.of(ctx)
          .textTheme
          .subtitle1
          .apply(color: ScanEatAppStyle.warning);
    } else {
      subtitleStyle = Theme.of(ctx).textTheme.subtitle1;
    }

    return Text(
      DateFormat("dd.MM.yyyy").format(productTimeStep),
      style: subtitleStyle, //TextStyle(color: ScanEatAppStyle.redDate)
    );
  }

  @override
  Widget build(BuildContext context) {
    final Function onDismissed =
        Provider.of<EanItemsProvider>(context).deleteListProductOfPage;

    final Function addProductCopyToPage =
        Provider.of<EanItemsProvider>(context).addProductCopyToPage;

    return ListItem(
      key: UniqueKey(),
      onTap: () {
        Navigator.pushNamed(context, ProductDetailScreen.pageRoute,
            arguments:
                ProductDetailScreenArgs(productId, eanProductPage.fridge));
      },
      onDismissed: (direction) {
        onDismissed(productId, eanProductPage.fridge);
      },
      title: productName,
      subtitle: createSubtitle(context),
      trailing: IconButton(
        onPressed: () {
          Scaffold.of(context).showSnackBar(SnackBar(
            margin: EdgeInsets.all(40),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).primaryColor,
            content: Text('added "$productName" to shopping list',
                style: TextStyle(fontSize: 15)),
          ));

          addProductCopyToPage(productId, eanProductPage.shoppingList);
        },
        icon: Icon(
          Icons.add_shopping_cart,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
