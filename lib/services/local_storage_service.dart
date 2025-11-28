import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/cart_item.dart';

class LocalStorageService {
  static const String _usersKey = 'users';
  static const String _cartKey = 'cart';

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList(_usersKey) ?? [];
    users.add(jsonEncode(user.toJson()));
    await prefs.setStringList(_usersKey, users);
  }

  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersJson = prefs.getStringList(_usersKey) ?? [];
    return usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
  }

  Future<User?> authenticateUser(String email, String password) async {
    List<User> users = await getUsers();
    try {
      return users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCart(List<CartItem> cart) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartJson = cart.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_cartKey, cartJson);
  }

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartJson = prefs.getStringList(_cartKey) ?? [];
    return cartJson.map((json) => CartItem.fromJson(jsonDecode(json))).toList();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
