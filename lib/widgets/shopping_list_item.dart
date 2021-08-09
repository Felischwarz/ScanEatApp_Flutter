import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ean_items_provider.dart';

import '../screens/product_detail_screen.dart';
import './list_item.dart';

class ShoppingListItem extends StatelessWidget {
  final int productId;
  final String productName;
  final DateTime timeStep;

  ShoppingListItem(this.productId, this.productName, this.timeStep);

  @override
  Widget build(BuildContext context) {
    final Function onDismissed =
        Provider.of<EanItemsProvider>(context).deleteListProductOfPage;

    return ListItem(
      key: UniqueKey(),
      onTap: () {
        Navigator.pushNamed(context, ProductDetailScreen.pageRoute,
            arguments: ProductDetailScreenArgs(productId, eanProductPage.shoppingList));
      },
      onDismissed: (direction) {
        onDismissed(productId, eanProductPage.shoppingList);
        
      },
      title: productName,
    );
  }
}
