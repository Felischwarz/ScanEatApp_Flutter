import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/custom_ean_product.dart';
import '../../providers/ean_items_provider.dart';
import '../../style.dart';
import '../SEA_text_form_field.dart';

class ManualProductTabContent extends StatelessWidget {
  final eanProductPage _currentPage;

  ManualProductTabContent(this._currentPage);

  @override
  Widget build(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _detailNameController = TextEditingController();
    TextEditingController _vendorController = TextEditingController();
    TextEditingController _descrController = TextEditingController();
    TextEditingController _originController = TextEditingController();

    DateTime _pickedBestBeforeDate;

    final Function addNewProductToPage =
        Provider.of<EanItemsProvider>(context, listen: false)
            .addNewProductToPage;

    void _addProduct() {
      CustomEanProduct prod = CustomEanProduct(
        page: _currentPage,
        name: _nameController.text,
        detailname: _detailNameController.text.replaceAll(" ", "") != ""
            ? _detailNameController.text
            : null,
        vendor: _vendorController.text.replaceAll(" ", "") != ""
            ? _vendorController.text
            : null,
        descr: _descrController.text.replaceAll(" ", "") != ""
            ? _descrController.text
            : null,
        origin: _originController.text.replaceAll(" ", "") != ""
            ? _originController.text
            : null,
        trueBestBeforeDate: _pickedBestBeforeDate,
      );

      addNewProductToPage(prod, _currentPage);
    }

    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SEATextFormField(
            labelText: "Name (required)",
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          if (_currentPage == eanProductPage.fridge)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ScanEatAppStyle.createGradientShaderMask(
                child: FlatButton(
                  onPressed: () => showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(3000))
                      .then((picked) => _pickedBestBeforeDate = picked),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.date_range),
                      Text(
                        " Add Best Before Date",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                gradient: ScanEatAppStyle.currentThemeIsDarkTheme
                    ? ScanEatAppStyle.gradient1
                    : ScanEatAppStyle.gradient2,
              ),
            ),
          SEATextFormField(
            labelText: "Detail Name",
            controller: _detailNameController,
          ),
          SEATextFormField(
            labelText: "Vendor",
            controller: _vendorController,
          ),
          SEATextFormField(
            labelText: "Description",
            controller: _descrController,
          ),
          SEATextFormField(
            labelText: "Origion",
            controller: _originController,
          ),
          ScanEatAppStyle.createGradientShaderMask(
            child: FlatButton(
              padding: EdgeInsets.only(top: 40),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _addProduct();
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Add Product",
                style: TextStyle(fontSize: 18),
              ),
            ),
            gradient: ScanEatAppStyle.currentThemeIsDarkTheme
                ? ScanEatAppStyle.gradient1
                : ScanEatAppStyle.gradient2,
          ),
        ],
      ),
    );
  }
}
