import 'package:flutter/material.dart';
import 'package:stock_count_app/components/Button.dart';
import 'package:stock_count_app/components/FullPageLoader.dart';

enum AlertState { error, warning, info, success }

showAlert(
  BuildContext context,
  AlertState type,
  String body, {
  String? title = "",
  Widget? extras,
  String okText = "Ok",
  bool showCancel = false,
  String cancelText = "Cancel",
  Function? okCallback,
  Function? cancelCallback,
}) {
  // set up the buttons

  Widget continueButton = Center(
    child: Button(
      text: okText,
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (okCallback != null) {
          okCallback();
        }
      },
    ),
  );
  Widget cancelButton = Container(
    margin: const EdgeInsets.only(top: 15),
    child: Center(
      child: TextButton(
        child: const Text("Cancel", textAlign: TextAlign.center),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (cancelCallback != null) {
            cancelCallback();
          }
        },
      ),
    ),
  );

  Color getBackgroundColor() {
    switch (type) {
      case AlertState.info:
        return const Color.fromARGB(26, 79, 140, 255); // Light blue
      case AlertState.success:
        return const Color.fromARGB(26, 139, 118, 255); // Light purple
      case AlertState.warning:
        return const Color.fromARGB(26, 255, 184, 0); // Light orange
      case AlertState.error:
        return const Color.fromARGB(26, 255, 82, 82); // Light red
    }
  }

  Color getIconColor() {
    switch (type) {
      case AlertState.info:
        return const Color.fromRGBO(79, 140, 255, 1); // Blue
      case AlertState.success:
        return const Color.fromRGBO(139, 118, 255, 1); // Purple
      case AlertState.warning:
        return const Color.fromRGBO(255, 184, 0, 1); // Orange
      case AlertState.error:
        return const Color.fromRGBO(255, 82, 82, 1); // Red
    }
  }

  IconData getIcon() {
    switch (type) {
      case AlertState.info:
        return Icons.info_outline;
      case AlertState.success:
        return Icons.check;
      case AlertState.warning:
        return Icons.warning_amber_outlined;
      case AlertState.error:
        return Icons.close;
    }
  }

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    // icon: Icon(Icons.info),
    content: Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: getBackgroundColor(),
            radius: 40,
            child: Center(
              child: Icon(getIcon(), size: 50, color: getIconColor()),
            ),
          ),
          if (title?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 20),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 15),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          if (extras != null) ...[const SizedBox(height: 20), extras],
        ],
      ),
    ),
    actions: [continueButton, if (showCancel) cancelButton],
    actionsPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    actionsAlignment: MainAxisAlignment.center,
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showFullPageLoader(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const FullPageLoader();
    },
  );
}
