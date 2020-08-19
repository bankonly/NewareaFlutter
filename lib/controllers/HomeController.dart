import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HomeController {
  // Icon function to get data of icon
  static bottomIcon({IconData icons, double size = 25, String title}) {
    return BottomNavigationBarItem(
        icon: Icon(
          icons,
          size: size,
        ),
        title: Text("$title"));
  }

  // List of bottom nar bar item
  static List items = <BottomNavigationBarItem>[
    bottomIcon(icons: Feather.clipboard, title: "Feed"),
    bottomIcon(icons: Feather.search, title: "Search"),
    bottomIcon(icons: Feather.play_circle, title: "Favorite"),
    bottomIcon(icons: Feather.message_circle, title: "Chat"),
    bottomIcon(icons: Feather.user, title: "Me")
  ];
}
