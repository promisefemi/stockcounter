import 'package:flutter/material.dart';

class NavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NavAppBar({super.key, this.onPressed, required this.title});

  final void Function()? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: true,
      foregroundColor: Colors.white,
      backgroundColor: Theme.of(context).primaryColorDark,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
      leading: onPressed != null
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onPressed,
            )
          : null,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(60.0);
}
