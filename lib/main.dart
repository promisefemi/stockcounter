import 'package:flutter/material.dart';
import 'package:stock_count_app/screens/Dashboard.dart';
import 'package:stock_count_app/screens/Login.dart';
import 'package:stock_count_app/util/shared_preference_helper.dart';
import 'package:stock_count_app/util/constant.dart' as constant;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferencesHelper prefs =
      await SharedPreferencesHelper.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.prefs,
  });

  final SharedPreferencesHelper prefs;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final String? userAPIKey = prefs.getString(constant.apiKey);

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(245, 0, 10, 1)),
        useMaterial3: true,
      ),
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        Dashboard.routeName: (context) => const Dashboard()

        // QrcodeScanner.routeName: (context) => const QrcodeScanner(),
      },
      initialRoute:
          userAPIKey == null ? LoginPage.routeName : Dashboard.routeName,
    );
  }
}
