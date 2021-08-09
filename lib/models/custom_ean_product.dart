import 'package:flutter/foundation.dart';

import '../models/ean_product.dart';
import '../providers/ean_items_provider.dart';

class CustomEanProduct extends EanProduct {
  eanProductPage page;

  CustomEanProduct({
    @required String name,
    @required this.page,
    String detailname,
    String vendor,
    String maincat,
    String subcat,
    String descr,
    String origin,
    String validated,
    int estimatedShelfLifeDays,
    List<String> contentProperties,
    List<String> packProperties,
    DateTime trueBestBeforeDate,
    DateTime timeStamp,
  }) : super.manually(
          name: name,
          detailname: detailname,
          vendor: vendor,
          maincat: maincat,
          subcat: subcat,
          descr: descr,
          origin: origin,
          validated: validated,
          estimatedShelfLifeDays: estimatedShelfLifeDays,
          contentProperties: contentProperties,
          packProperties: packProperties,
          trueBestBeforeDate: trueBestBeforeDate,
          newTimeStamp: timeStamp,
        );

  CustomEanProduct.copy(CustomEanProduct prod) : super.copy(prod) {
    page = prod.page;
  }

  CustomEanProduct.fromJson(dynamic jsonProd)
      : super.manually(
          name: jsonProd["name"],
          detailname: jsonProd["detailname"],
          vendor: jsonProd["vendor"],
          maincat: jsonProd["maincat"],
          subcat: jsonProd["subcat"],
          descr: jsonProd["descr"],
          origin: jsonProd["origin"],
          validated: jsonProd["validated"],
          estimatedShelfLifeDays: jsonProd["estimatedShelfLifeDays"],
          contentProperties: jsonProd["contentProperties"]?.cast<String>(),
          packProperties: jsonProd["packProperties"]?.cast<String>(),
          trueBestBeforeDate: jsonProd["trueBestBeforeDate"]?.cast<String>(),
          newTimeStamp:
              EanItemsProvider.dbTimeStampFormat.parse(jsonProd["timeStamp"]),
        ) {
    try {
      this.page = eanProductPage.values[jsonProd["page"]];
    } on Exception catch (e) {
      print(
          "Error: Bad json data provided for CustomEanProduct. Full exception: " +
              e.toString());
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json["page"] = page.index;
    json["timeStamp"] =
        EanItemsProvider.dbTimeStampFormat.format(super.timeStamp);
    return json;
  }
}
