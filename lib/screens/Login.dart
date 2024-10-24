import 'package:flutter/material.dart';

import 'package:stock_count_app/util/constant.dart' as constant;

import '../api/api.dart';
import '../components/Button.dart';
import '../components/CustomTextField..dart';
import '../models/ApiResponse.dart';
import '../models/Login.dart';
import '../util/shared_preference_helper.dart';
import '../util/util.dart';
import 'Dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = "";
  String _password = "";
  bool _dontShowPassword = true;
  bool _isLoading = false;

  void initState() {
    super.initState();
    // testData();
  }

  // testData() async {
  //   final pref = await SharedPreferencesHelper.getInstance();
  //   print(pref.getString(constant.apiKey));

  //   var userMap = pref.getMap(constant.userKey);

  //   if (userMap != null) {
  //     User user = User.fromJson(userMap);
  //     print(user.toJson());
  //   }
  // }

  manageLogin() async {
    // print("Username $_username");
    // print("Password $_password");

    if (_isLoading) {
      return;
    }

    if (_username == "" || _password == "") {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print("PRINTIN RES");
    try {
      ApiResponse<Login>? response =
          await Api.instance.login(_username, _password);

      setState(() {
        _isLoading = false;
      });
      if (response == null) {
        showAlert(
          context,
          "Something went wrong, please check your internet connection",
          title: "Error",
        );
        return;
      }

      if (!response.status) {
        showAlert(context, response.message.toUpperCase());
        return;
      }

// response.data.

      final pref = await SharedPreferencesHelper.getInstance();
      pref.setString(constant.apiKey, response.data.apiKey);
      pref.setMap(constant.userKey, response.data.user!.toJson());

      Navigator.pushNamed(context, Dashboard.routeName);

      return;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlert(
        context,
        "Something went wrong, please check your internet connection",
        title: "Error",
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: constant.primaryColor,
        ),
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: constant.primaryColor,
            ),
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/hand-with-key.png")
                      ],
                    ),
                  ),

                  // FORMS
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black38,
                      //     blurRadius: 10,
                      //     // offset: Offset.fromDirection(),
                      //     spreadRadius: 2,
                      //   )
                      // ],
                    ),
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, top: 25, bottom: 60),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "Let's sign you in ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(52, 73, 94, 1)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Form(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField.withOnChanged(
                                hintText: "Username",
                                borderRadius: 10,
                                borderWidth: 1,
                                color: Color.fromRGBO(182, 182, 182, 1),
                                onChanged: (value) {
                                  setState(() {
                                    _username = value;
                                  });
                                },
                                icon: const Icon(Icons.person_outline_rounded),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField.withOnChanged(
                                hintText: "Password",
                                borderRadius: 10,
                                borderWidth: 1,
                                color: Color.fromRGBO(182, 182, 182, 1),
                                onChanged: (value) {
                                  setState(() {
                                    _password = value;
                                  });
                                },
                                hideText: _dontShowPassword,
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _dontShowPassword = !_dontShowPassword;
                                    });
                                  },
                                  icon: Icon(_dontShowPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                ),
                                icon: const Icon(Icons.lock_outline_rounded),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: Button(
                                  borderRadius: 10,
                                  onPressed: manageLogin,
                                  text:
                                      _isLoading ? "Please wait..." : "Sign In",
                                ),
                              ),
                            ],
                          ))
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
