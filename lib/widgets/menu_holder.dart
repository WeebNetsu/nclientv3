import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

class MenuHolder extends StatelessWidget {
  const MenuHolder({
    Key? key,
    required this.menuItems,
    required this.child,
    required this.onTap,
    this.openWithTap = false,
  }) : super(key: key);

  final List<FocusedMenuItem> menuItems;
  final Widget child;
  final void Function() onTap;

  /// Should it be opened with a tap or long press
  final bool openWithTap;

  @override
  Widget build(BuildContext context) {
    return FocusedMenuHolder(
      menuWidth: MediaQuery.of(context).size.width * 0.50,
      blurSize: 5.0,
      menuItemExtent: 45,
      menuBoxDecoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(14.0)),
      ),
      duration: const Duration(milliseconds: 100),
      animateMenuItems: true,
      blurBackgroundColor: Colors.black54,
      openWithTap: openWithTap,
      menuOffset: 5.0,
      menuItems: menuItems,
      onPressed: onTap,
      child: child,
    );
  }
}
