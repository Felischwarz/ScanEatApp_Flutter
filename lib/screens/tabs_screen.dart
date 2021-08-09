import 'package:flutter/material.dart';

import './fridge_screen.dart';
import './shopping_list_screen.dart';
import './settings_screen.dart';
import '../style.dart';
import '../screens/household_list_screen.dart';

class TabPage {
  String name;
  Object content;
  Icon icon;

  TabPage(this.name, this.content, this.icon);
}

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentTabIndex = 1;
  List<TabPage> _pages;

  void _onTap(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  void initState() {
    _pages = [
      TabPage(
        "Recipes",
        null,
        Icon(Icons.fastfood_outlined),
      ),
      TabPage(
        "My Fridge",
        FridgeScreen(),
        Icon(Icons.all_inbox),
      ),
      TabPage(
        "Shopping List",
        ShoppingListScreen(),
        Icon(Icons.shopping_cart_outlined),
      ),
    ];
    super.initState();
  }

  List<BottomNavigationBarItem> get _navBarItems {
    List<BottomNavigationBarItem> items = [];
    _pages.forEach((item) {
      items.add(
        _createNavBarItem(item.name, item.icon),
      );
    });
    return items;
  }

  BottomNavigationBarItem _createNavBarItem(String label, Icon icon) {
    return BottomNavigationBarItem(
      label: label,
      icon: icon,
      activeIcon: ScanEatAppStyle.createGradientShaderMask(
        gradient: ScanEatAppStyle.currentThemeIsDarkTheme
            ? ScanEatAppStyle.gradient1
            : ScanEatAppStyle.gradient2,
        child: icon,
      ),
      backgroundColor: Colors.white,
    );
  }

  AppBar _createAppBar(ctx) {
    return ScanEatAppStyle.createGradientAppBar(
      title: _pages[_currentTabIndex].name,
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          color: Theme.of(context).iconTheme.color,
          onPressed: () =>
              Navigator.of(ctx).pushNamed(SettingsScreen.pageRoute),
        ),
      ],
    );
  }

  AppBar _createShoppingListAppBar(ctx) {
    return ScanEatAppStyle.createGradientAppBar(
      title: _pages[_currentTabIndex].name,
      leading: IconButton(
        icon: Icon(Icons.view_list),
        color: Theme.of(context).iconTheme.color,
        onPressed: () => Navigator.of(ctx).pushNamed(HouseholdListScreen.pageRoute),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          color: Theme.of(context).iconTheme.color,
          onPressed: () =>
              Navigator.of(ctx).pushNamed(SettingsScreen.pageRoute),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentTabIndex == 2
          ? _createShoppingListAppBar(context)
          : _createAppBar(context),
      body: _pages[_currentTabIndex].content,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        currentIndex: _currentTabIndex,
        onTap: _onTap,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        selectedItemColor: Theme.of(context).textTheme.bodyText1.color,
        items: [..._navBarItems],
      ),
    );
  }
}
