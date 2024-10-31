import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  get math => null;

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/user_data.json';
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    final path = await _getFilePath();
    final file = File(path);

    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>?> readUserData() async {
    try {
      final path = await _getFilePath();
      final file = File(path);

      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents);
      }
      return null;
    } catch (e) {
      print('Ошибка при чтении файла: $e');
      return null;
    }
  }

  Future<void> addSubcategory(String userId, String name, double amount) async {
    final userData = await readUserData() ?? {};
    final subcategoryList = userData[userId]['subcategories'] ?? [];

    subcategoryList.add({
      'name': name,
      'amount': amount,
      'color': Colors.primaries[math.Random().nextInt(Colors.primaries.length)].value
    });

    userData[userId] = {
      'subcategories': subcategoryList,
    };

    await saveUserData(userData);
  }
  Future<void> saveTotalExpenses(String userId, double totalExpenses) async {
    final path = await _getFilePath();
    final file = File(path);

    Map<String, dynamic>? userData = await readUserData();
    if (userData == null) {
      userData = {};
    }

    userData[userId] = {
      'totalExpenses': totalExpenses,
      'subcategories': userData[userId]?['subcategories'] ?? [],
    };

    await file.writeAsString(jsonEncode(userData));
  }

  Future<double?> readTotalExpenses(String userId) async {
    final userData = await readUserData();
    if (userData != null && userData.containsKey(userId)) {
      return userData[userId]['totalExpenses']?.toDouble();
    }
    return null;
  }

}

