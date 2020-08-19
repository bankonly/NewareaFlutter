import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newarea/controllers/HomeController.dart';

void main() => runApp(NewArea());

class NewArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Controller of Class
    return CupertinoApp(
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: Colors.blue,
          items: HomeController.items,
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (context) {
              return CupertinoPageScaffold(
                child: Center(
                  child: Text("HELLO WORLD $index"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
