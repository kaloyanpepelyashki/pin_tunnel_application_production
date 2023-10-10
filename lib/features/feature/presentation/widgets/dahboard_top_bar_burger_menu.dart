import 'package:flutter/material.dart';

class DashboardTopBarBurgerMenu extends StatelessWidget
    implements PreferredSizeWidget {
  const DashboardTopBarBurgerMenu({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        "My system",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          icon: const Icon(color: Colors.black, size: 50.0, Icons.menu_rounded),
          padding: const EdgeInsets.fromLTRB(0, 5, 40.0, 0),
        )
      ],
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      titleSpacing: 25,
    );
  }
}
