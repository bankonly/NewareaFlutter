import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newarea/controllers/HomeController.dart';
import 'package:newarea/screens/Account.dart';
import 'package:newarea/screens/Home.dart';
import 'package:newarea/screens/Messages.dart';
import 'package:newarea/screens/My-Storage.dart';
import 'package:newarea/screens/Search.dart';

void main() => runApp(NewArea());

class NewArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [Home(), Search(), MyStorage(), Messages(), Account()];

    // Controller of Class
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.white,
          activeColor: Colors.blue,
          items: HomeController.items,
          border: Border(top: BorderSide(width: 0.5, color: Colors.grey[300])),
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (context) {
              return CupertinoPageScaffold(
                child: IndexedStack(
                  children: pages,
                  index: index,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
