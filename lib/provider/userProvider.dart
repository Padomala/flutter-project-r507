import 'package:flutter/material.dart';
import './model/user.dart';

class UserProvider extends ChangeNotifier {
  late UserModel user;

  UserProvider() {
    user = UserModel(
      id: '123',
      name: 'Jean Dupont',
      email: 'jean.dupont@example.com',
    );
  }

  void updateUserName(String newName) {
    user = user.copyWith(name: newName);
    notifyListeners();    //modify ux
  }

  Map<String, dynamic> get userAsJson => user.toJson();

  void loadUserFromJson(Map<String, dynamic> json) {
    user = UserModel.fromJson(json);
    notifyListeners();
  }
}
