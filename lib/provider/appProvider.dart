import 'package:flutter/material.dart';
import './provider/userProvider.dart'; // Your UserProvider

class AppProvider with ChangeNotifier {
  final UserProvider userProvider;

  AppProvider({required this.userProvider}) {
    print("AppProvider initialized!"); // Print when AppProvider is created
  }

}