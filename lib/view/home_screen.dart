import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/bg_data.dart';
import '../view_model/FileStorageService.dart';
import 'category_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 2;
  List<String> categories = [];
  Map<String, List<String>> expensesByCategory = {};
  final FileStorageService _fileStorageService = FileStorageService();

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFile();
  }

  Future<void> _loadCategoriesFromFile() async {
    final data = await _fileStorageService.readUserData();
    if (data != null) {
      setState(() {
        categories = List<String>.from(data['categories'] ?? []);
        expensesByCategory =
            Map<String, List<String>>.from(data['expensesByCategory'] ?? {});
      });
    }
  }

  Future<void> _saveCategoriesToFile() async {
    await _fileStorageService.saveUserData({
      'categories': categories,
      'expensesByCategory': expensesByCategory,
    });
  }

  void _onAddButtonPressed() {
    String? newCategory;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Добавить категорию расходов"),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(hintText: "Введите название категории"),
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                if (newCategory != null && newCategory!.isNotEmpty) {
                  setState(() {
                    categories.add(newCategory!);
                    expensesByCategory[newCategory!] = [];
                  });
                  _saveCategoriesToFile();
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onCategoryTapped(String category, int backgroundIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryInfoScreen(
            category: category, backgroundIndex: backgroundIndex),
      ),
    );
  }

  void _onCategoryLongPressed(String category) async {
    double totalExpenses = await _calculateTotalExpenses();

    List<String>? expenses = expensesByCategory[category];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Расходы для $category: $totalExpenses"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<double> _calculateTotalExpenses() async {
    double total = 0.0;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      total = await _fileStorageService.readTotalExpenses(userId) ?? 0.0;
    }

    return total;
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final topPadding = screenHeight * 0.53;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgList[selectedIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Привет'),
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding, left: 16.0, right: 16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () =>
                      _onCategoryTapped(categories[index], selectedIndex),
                  onLongPress: () => _onCategoryLongPressed(categories[index]),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 3,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          categories[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddButtonPressed,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
