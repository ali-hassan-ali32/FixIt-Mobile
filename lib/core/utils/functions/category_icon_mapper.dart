import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/widgets.dart';

class CategoryIconMapper {
  static IconData iconOf(String? icon) {
    switch (icon) {
      case 'fa-couch':
        return FontAwesomeIcons.couch;

      case 'fa-industry':
        return FontAwesomeIcons.industry;

      case 'fa-video':
        return FontAwesomeIcons.video;

      case 'fa-network-wired':
        return FontAwesomeIcons.networkWired;

      case 'fa-truck':
        return FontAwesomeIcons.truck;

      case 'fa-toolbox':
        return FontAwesomeIcons.toolbox;

      case 'fa-window-maximize':
        return FontAwesomeIcons.windowMaximize;

      case 'fa-hammer':
        return FontAwesomeIcons.hammer;

      case 'fa-bolt':
        return FontAwesomeIcons.bolt;

      case 'fa-faucet':
        return FontAwesomeIcons.faucet;

      case 'fa-snowflake':
        return FontAwesomeIcons.snowflake;

      case 'fa-paint-roller':
        return FontAwesomeIcons.paintRoller;

      default:
        return FontAwesomeIcons.screwdriverWrench;
    }
  }
}