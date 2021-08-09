import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/ean_items_provider.dart';
import "../style.dart";
import '../models/ean_product.dart';
import '../utils.dart';
import '../config.dart' as config;

class ProductDetailScreenArgs {
  final int productId;
  final eanProductPage eanPage;

  ProductDetailScreenArgs(this.productId, this.eanPage);
}

class ProductDetailScreen extends StatelessWidget {
  static const pageRoute = "/product_detail_screen";

  @override
  Widget build(BuildContext context) {
    final ProductDetailScreenArgs args =
        ModalRoute.of(context).settings.arguments;
    final int id = args.productId;
    final eanProductPage eanPage = args.eanPage;
    final EanProduct product =
        Provider.of<EanItemsProvider>(context, listen: false)
            .getEanProductById(id);
    final Function addProductCopyToPage =
        Provider.of<EanItemsProvider>(context, listen: false)
            .addProductCopyToPage;
    final Function deleteListProductOfPage =
        Provider.of<EanItemsProvider>(context, listen: false)
            .deleteListProductOfPage;
    Widget _createAttribute(String attributeTitle, Object attribute) {
      return Column(children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            attributeTitle,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          subtitle: Text(
            attribute.toString(),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        Divider()
      ]);
    }

    Widget _createAttributeWithCustomSubtitle(
        String attributeTitle, Widget customSubtitle) {
      return Column(children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            attributeTitle,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          subtitle: customSubtitle,
        ),
        Divider()
      ]);
    }

    Widget _createAttributeList(
        String attributeTitle, List<String> attributeList, IconData leadingIcon,
        {Color iconColor, LinearGradient iconGradient}) {
      WidgetSpan iconWidgetSpan;
      if (iconGradient != null) {
        iconWidgetSpan = WidgetSpan(
          child: ScanEatAppStyle.createGradientShaderMask(
              child: Icon(
                leadingIcon,
                size: Theme.of(context).textTheme.bodyText1.fontSize,
              ),
              gradient: iconGradient),
        );
      } else {
        iconWidgetSpan = WidgetSpan(
          child: Icon(
            leadingIcon,
            size: Theme.of(context).textTheme.bodyText1.fontSize,
            color: iconColor,
          ),
        );
      }
      List<TextSpan> textItems = [];
      attributeList.forEach((element) {
        textItems.add(
          TextSpan(
            children: [
              iconWidgetSpan,
              TextSpan(
                text: " " + element + "\n",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        );
      });
      return Column(children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            attributeTitle,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          subtitle: RichText(
            text: TextSpan(
              children: textItems,
            ),
          ),
        ),
        Divider()
      ]);
    }

    Widget _greenSubtitle(String text) {
      return ScanEatAppStyle.createGradientShaderMask(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          gradient: ScanEatAppStyle.currentThemeIsDarkTheme
              ? ScanEatAppStyle.gradient1
              : ScanEatAppStyle.gradient2);
    }

    Widget _redSubtitle(String text) {
      return Text(
        text.toString(),
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(color: ScanEatAppStyle.danger),
      );
    }

    Widget _yellowSubtitle(String text) {
      return Text(
        text.toString(),
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .copyWith(color: ScanEatAppStyle.warning),
      );
    }

    // only used if estimated shelf life is given
    List<Widget> _createShelfLifeAttributes(EanProduct prod) {
      DateTime bestBeforeDate = prod.calculateEstimatedBestBeforeDate();
      bool isBefore = DateTime.now().isBefore(bestBeforeDate);

      String estimatedBestBeforeDate =
          DateFormat("dd.MM.yyyy").format(bestBeforeDate);

      int daysLeft = DateTime.now().difference(bestBeforeDate).inDays;
      daysLeft = daysLeft.abs();

      Widget estimatedBestBeforeDateSubtitle;
      Widget estimatedShelfLifeLeftSubtitle;

      String estimatedShelfLifeleft;
      if (isBefore) {
        //date in the future
        estimatedShelfLifeleft = Utils.daysToDuration(daysLeft);

        if (daysLeft > config.warningDaysBeforeProductExpiration) {
          estimatedBestBeforeDateSubtitle =
              _greenSubtitle(estimatedBestBeforeDate);
          estimatedShelfLifeLeftSubtitle =
              _greenSubtitle(estimatedShelfLifeleft);
        } else if (daysLeft > 0) {
          estimatedBestBeforeDateSubtitle =
              _yellowSubtitle(estimatedBestBeforeDate);
          estimatedShelfLifeLeftSubtitle =
              _yellowSubtitle(estimatedShelfLifeleft);
        } else {
          estimatedBestBeforeDateSubtitle =
              _redSubtitle(estimatedBestBeforeDate);
          estimatedShelfLifeLeftSubtitle = _redSubtitle(estimatedShelfLifeleft);
        }
      } else {
        //date in the past

        estimatedShelfLifeleft = Utils.daysToDuration(daysLeft) + " ago";

        estimatedBestBeforeDateSubtitle = _redSubtitle(estimatedBestBeforeDate);
        estimatedShelfLifeLeftSubtitle = _redSubtitle(estimatedShelfLifeleft);
      }

      return [
        _createAttributeWithCustomSubtitle(
          "Estimated best before date",
          estimatedBestBeforeDateSubtitle,
        ),
        _createAttributeWithCustomSubtitle(
          "Estimated shelf life left",
          estimatedShelfLifeLeftSubtitle,
        ),
      ];
    }

    // only used if a true best before date is given
    Widget _createTrueBestBeforeDate(DateTime bestBeforeDate) {
      bool isBefore = DateTime.now().isBefore(bestBeforeDate);

      int daysLeft = DateTime.now().difference(bestBeforeDate).inDays;
      daysLeft = daysLeft.abs();

      String bestBeforeDateString =
          DateFormat("dd.MM.yyyy").format(bestBeforeDate);

      Widget trueBestBeforeDateSubtitle;
      if (isBefore) {
        //date in the future

        if (daysLeft > config.warningDaysBeforeProductExpiration) {
          trueBestBeforeDateSubtitle = _greenSubtitle(bestBeforeDateString);
        } else if (daysLeft > 0) {
          trueBestBeforeDateSubtitle = _yellowSubtitle(bestBeforeDateString);
        } else {
          trueBestBeforeDateSubtitle = _redSubtitle(bestBeforeDateString);
        }
      } else {
        //date in the past
        trueBestBeforeDateSubtitle = _redSubtitle(bestBeforeDateString);
      }

      return _createAttributeWithCustomSubtitle(
        "Best before date",
        trueBestBeforeDateSubtitle,
      );
    }

    Widget _createActionButton({
      @required Function onPressed,
      String snackBarText,
      @required IconData icon,
      @required String title,
      bool iconDanger = false,
    }) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 90,
          child: Builder(
            builder: (context) => ScanEatAppStyle.createRaisedButton(
              onPressed: () {
                onPressed();
                if (snackBarText != null &&
                    snackBarText.isNotEmpty &&
                    context != null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    margin: EdgeInsets.all(40),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Theme.of(context).primaryColor,
                    content: Text(
                      snackBarText,
                      style: TextStyle(fontSize: 15),
                    ),
                  ));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconDanger
                      ? Icon(
                          icon,
                          size: 30,
                          color: ScanEatAppStyle.danger,
                        )
                      : ScanEatAppStyle.createGradientShaderMask(
                          child: Icon(
                            icon,
                            size: 30,
                          ),
                          gradient: ScanEatAppStyle.currentThemeIsDarkTheme
                              ? ScanEatAppStyle.gradient1
                              : ScanEatAppStyle.gradient2,
                        ),
                  Padding(padding: EdgeInsets.only(bottom: 5)),
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _createActionButtons() {
      GridView grid = GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: (100 / 60),
        controller: new ScrollController(keepScrollOffset: false),
        children: [
          if (eanPage != eanProductPage.shoppingList)
            _createActionButton(
              onPressed: () =>
                  addProductCopyToPage(id, eanProductPage.shoppingList),
              icon: Icons.add_shopping_cart,
              title: "Add to shopping list",
              snackBarText: 'added "${product.name}" to shopping list',
            ),
          if (eanPage != eanProductPage.householdList)
            _createActionButton(
              onPressed: () =>
                  addProductCopyToPage(id, eanProductPage.householdList),
              icon: Icons.add_business_outlined,
              title: "Add to household list",
              snackBarText: 'added "${product.name}" to household list',
            ),
          if (eanPage != eanProductPage.fridge)
            _createActionButton(
              onPressed: () {
                addProductCopyToPage(id, eanProductPage.fridge);
                Provider.of<EanItemsProvider>(context, listen: false)
                    .syncFridgeEansWithDB();
              },
              icon: Icons.add_box_outlined,
              title: "Add to my frige",
              snackBarText: 'added "${product.name}" to my fridge',
            ),
          _createActionButton(
            onPressed: () {
              deleteListProductOfPage(id, eanPage);
              Navigator.of(context).pop();
            },
            icon: Icons.clear,
            title: "Remove",
            iconDanger: true,
            snackBarText: "removed $product.name",
          ),
        ],
      );
      return _createAttributeWithCustomSubtitle("Actions", grid);
    }

    return Scaffold(
      appBar: ScanEatAppStyle.createGradientAppBar(
        title: product.name,
      ),
      body: ListView(
        children: [
          if (product.detailname != null)
            _createAttribute("Full Name", product.detailname),
          if (product.timeStamp != null)
            _createAttribute("Time Added",
                DateFormat("dd.MM.yyyy").format(product.timeStamp)),
          if (eanPage == eanProductPage.fridge &&
              product.estimatedShelfLifeDays != null)
            ..._createShelfLifeAttributes(product),
          if (product.trueBestBeforeDate != null &&
              product.estimatedShelfLifeDays == null)
            _createTrueBestBeforeDate(product.trueBestBeforeDate),
          _createActionButtons(),
          if (product.descr != null)
            _createAttribute("Description", product.descr),
          if (product.vendor != null)
            _createAttribute("Vendor", product.vendor),
          if (product.contentProperties != null)
            if (product.contentProperties.length > 0)
              _createAttributeList(
                "Contents",
                product.contentProperties,
                Icons.check,
                iconGradient: ScanEatAppStyle.currentThemeIsDarkTheme
                    ? ScanEatAppStyle.gradient1
                    : ScanEatAppStyle.gradient2,
              ),
          if (product.packProperties != null)
            if (product.packProperties.length > 0)
              _createAttributeList(
                "Package",
                product.packProperties,
                Icons.warning,
                iconColor: ScanEatAppStyle.currentThemeIsDarkTheme
                    ? Colors.yellow[500]
                    : Colors.yellow[900],
              ),
          if (product.maincat != null)
            _createAttribute("Main Category", product.maincat),
          if (product.subcat != null)
            _createAttribute("Sub Category", product.subcat),
          if (product.origin != null && product.origin != "-")
            _createAttribute("Origin", product.origin),
          if (product.validated != null)
            _createAttribute("Validation", product.validated),
          if (product.ean != null) _createAttribute("EAN", product.ean),
        ],
      ),
    );
  }
}
