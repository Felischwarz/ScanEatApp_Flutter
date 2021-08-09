import 'package:ScanEatApp/providers/ean_items_provider.dart';
import 'package:flutter/material.dart';

import '../../style.dart';
import './manual_product_tab_content.dart';

class TabPage {
  String title;
  Widget content;

  TabPage(this.title, this.content);
}

class AddProductBottomSheet extends StatefulWidget {
  final eanProductPage _currentPage;

  AddProductBottomSheet(this._currentPage);

  @override
  _AddProductBottomSheetState createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  Widget createTab(String title) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      color: ScanEatAppStyle.currentTheme.cardColor,
      child: Text(
        title,
      ),
    );
  }

  int _currentTabIndex = 0;
  List<TabPage> _tabs = [];

  @override
  initState() {
    super.initState();  
    _tabs = [
      TabPage("Manually", ManualProductTabContent(widget._currentPage)),
      TabPage("Camera", Text("")),
      TabPage("EAN", Text("")),
    ];
  }

  _changeTab(int newTabIndex) {
    setState(() {
      _currentTabIndex = newTabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: _currentTabIndex,
      child: Scaffold(
        backgroundColor: ScanEatAppStyle.currentTheme.canvasColor,
        appBar: TabBar(
          tabs: [..._tabs.map((tab) => createTab(tab.title))],
          onTap: (newTabIndex) => _changeTab(newTabIndex),
          labelStyle: ScanEatAppStyle.currentTheme.textTheme.bodyText1
              .copyWith(fontSize: 16),
          unselectedLabelColor: ScanEatAppStyle.currentTheme.primaryColorDark,
          labelPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          indicator: ShapeDecoration(
            shape: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 0,
                style: BorderStyle.solid,
              ),
            ),
            gradient: ScanEatAppStyle.currentThemeIsDarkTheme
                ? ScanEatAppStyle.gradient1
                : ScanEatAppStyle.gradient2,
          ),
        ),
        body: _tabs[_currentTabIndex].content,
      ),
    );
  }
}
