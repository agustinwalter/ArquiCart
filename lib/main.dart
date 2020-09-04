import 'package:arquicart/provider/BuildingModel.dart';
import 'package:arquicart/provider/UserModel.dart';
import 'package:arquicart/screens/MapScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BuildingModel()),
        ChangeNotifierProvider(create: (context) => UserModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArquiCart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    () async {
      await Future.delayed(Duration.zero);
      Provider.of<UserModel>(context, listen: false).getCurrentUser();
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MapScreen();
  }
}
