import 'package:flutter/material.dart';


import 'package:stock_count_app/util/constant.dart' as constant;

class Layout extends StatelessWidget {
  const Layout({
    super.key,
    this.appBar,
    this.showBottomBar = true,
    required this.child,
  });
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool showBottomBar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black12),
      child: SafeArea(
        child: Scaffold(
          appBar: appBar,
          body: Container(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(251, 253, 253, 1)),
            padding: const EdgeInsets.all(15),
            child: child,
          ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerDocked,
          //

        ),
      ),
    );
  }
}

class BottomNavAction extends StatelessWidget {
  const BottomNavAction({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: constant.appGrey,
          ),
          Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: constant.appGrey),
          ),
        ],
      ),
    );
  }
}
