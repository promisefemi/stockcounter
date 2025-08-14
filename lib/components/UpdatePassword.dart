import 'package:flutter/material.dart';
import 'package:stock_count_app/api/api.dart';
import 'package:stock_count_app/components/Button.dart';
import 'package:stock_count_app/util/dialog.dart';
import 'package:stock_count_app/util/util.dart';
import 'package:stock_count_app/components/CustomTextField.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  String oldPassword = "";
  String newPassword = "";
  String confirmPassword = "";
  bool _passwordResetLoading = false;

  bool _showNewPassword = false;
  bool _showOldPassword = false;

  initState() {
    super.initState();
  }

  _resetPassword() async {
    final parentContext = context; // Save context before popping

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      showAlert(parentContext, AlertState.info, "Please fill all fields");
      return;
    }

    if (newPassword != confirmPassword) {
      showAlert(parentContext, AlertState.error,
          "New password and confirm password do not match");
      return;
    }

    // Navigator.pop(context); // Closes bottom sheet

    showFullPageLoader(parentContext);

    var response = await Api.instance.updatePassword({
      "old_password": oldPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword
    });

    Navigator.pop(parentContext); // Close loader

    if (response == null) {
      showAlert(parentContext, AlertState.error, "Something went wrong");
      return;
    }

    print(response);

    if (response['status'] == true) {
      showAlert(
        parentContext,
        AlertState.success,
        "Password updated successfully",
        okCallback: () {
          Navigator.pop(parentContext);
        },
      );
    } else {
      showAlert(parentContext, AlertState.error, response['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Update Password",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
                //  bac: Colors.grey[200],
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close,
                  size: 16,
                  weight: 30,
                ))
          ],
        ),
        const SizedBox(height: 20),
        Form(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField.withOnChanged(
              hintText: "Old Password",
              borderRadius: 10,
              borderWidth: 1,
              color: const Color.fromRGBO(182, 182, 182, 1),
              onChanged: (value) {
                setState(() {
                  oldPassword = value;
                });
              },
              hideText: !_showOldPassword,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    _showOldPassword = !_showOldPassword;
                  });
                },
                icon: Icon(_showOldPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField.withOnChanged(
              hintText: "New Password",
              borderRadius: 10,
              borderWidth: 1,
              color: const Color.fromRGBO(182, 182, 182, 1),
              onChanged: (value) {
                setState(() {
                  newPassword = value;
                });
              },
              hideText: !_showNewPassword,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    _showNewPassword = !_showNewPassword;
                  });
                },
                icon: Icon(_showNewPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField.withOnChanged(
              hintText: "Confirm Password",
              borderRadius: 10,
              borderWidth: 1,
              color: const Color.fromRGBO(182, 182, 182, 1),
              hideText: true,
              onChanged: (value) {
                setState(() {
                  confirmPassword = value;
                });
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Button(
                borderRadius: 10,
                onPressed: _resetPassword,
                text:
                    _passwordResetLoading ? "Please wait..." : "Reset Password",
              ),
            ),
          ],
        ))
      ]),
    );
    ;
  }
}
