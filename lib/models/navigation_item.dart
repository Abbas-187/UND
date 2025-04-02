import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final String? route;
  final IconData icon;
  final List<String> allowedRoles;
  final List<NavigationItem>? children;

  NavigationItem({
    required this.title,
    this.route,
    required this.icon,
    required this.allowedRoles,
    this.children,
  });
}
