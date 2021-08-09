import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Key key;
  final Function onTap;
  final Function onDismissed;
  final String title;
  final Text subtitle;
  final Widget trailing;

  ListItem({
    @required this.key,
    @required this.onTap,
    @required this.onDismissed,
    @required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        child: ListTile(
          onTap: onTap,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          subtitle: subtitle,
          trailing: trailing,
        ),
      ),
      confirmDismiss: (_) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: ((BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            ],
          );
        }), //onDismissed,
      ),
      onDismissed: onDismissed,
    );
  }
}
