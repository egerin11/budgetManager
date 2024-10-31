import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';

import '../data/bg_data.dart';
import '../view_model/FileStorageService.dart';

class SubcategoryData {
  final String name;
  double amount;
  final Color color;

  SubcategoryData({
    required this.name,
    required this.amount,
    Color? color,
  }) : color = color ??
            Colors.primaries[math.Random().nextInt(Colors.primaries.length)];
}

class CustomPieChart extends CustomPainter {
  final List<SubcategoryData> data;
  final double total;

  CustomPieChart({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    double startAngle = 0;

    for (var item in data) {
      final sweepAngle = 2 * math.pi * (item.amount / total);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = item.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        strokePaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPieChart oldDelegate) => true;
}

class CategoryInfoScreen extends StatefulWidget {
  final String category;
  final int backgroundIndex;

  const CategoryInfoScreen({
    Key? key,
    required this.category,
    this.backgroundIndex = 2,
  }) : super(key: key);

  @override
  State<CategoryInfoScreen> createState() => _CategoryInfoScreenState();
}

class _CategoryInfoScreenState extends State<CategoryInfoScreen> {
  int selectedIndex = 2;
  List<SubcategoryData> subcategories = [];
  double totalExpenses = 0;
  final FileStorageService fileStorageService = FileStorageService();
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;

      Map<String, dynamic>? userData = await fileStorageService.readUserData();
      if (userData != null && userData.containsKey(userId)) {
        List<dynamic> subcategoryList = userData[userId]['subcategories'] ?? [];
        setState(() {
          subcategories = subcategoryList
              .map((data) => SubcategoryData(
                    name: data['name'],
                    amount: data['amount'],
                    color: Color(data['color']),
                  ))
              .toList();

          totalExpenses = userData[userId]['totalExpenses'] ?? 0.0;

          _updateTotalExpenses();
        });
      }
    }
  }

  void _updateTotalExpenses() {
    totalExpenses = subcategories.fold(0, (sum, item) => sum + item.amount);
  }

  void _addSubcategory() {
    String? newSubcategory;
    double? amount;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          title: const Text("Добавить подкатегорию"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newSubcategory = value;
                },
                decoration: const InputDecoration(
                  hintText: "Введите название подкатегории",
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0;
                },
                decoration: const InputDecoration(
                  hintText: "Введите сумму",
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                if (newSubcategory != null &&
                    newSubcategory!.isNotEmpty &&
                    amount != null) {
                  setState(() {
                    subcategories.add(SubcategoryData(
                      name: newSubcategory!,
                      amount: amount!,
                    ));
                    _updateTotalExpenses();
                    _saveUserData();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUserData() async {
    if (userId != null) {
      Map<String, dynamic> userData = {
        userId!: {
          'subcategories': subcategories.map((subcategory) {
            return {
              'name': subcategory.name,
              'amount': subcategory.amount,
              'color': subcategory.color.value,
            };
          }).toList(),
          'totalExpenses': totalExpenses,
        }
      };

      await fileStorageService.saveUserData(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.category),
      ),
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
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subcategories.isNotEmpty) ...[
                  Container(
                    height: 280,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Общая сумма: ${totalExpenses.toStringAsFixed(2)} BYN',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 150,
                          child: CustomPaint(
                            painter: CustomPieChart(
                              data: subcategories,
                              total: totalExpenses,
                            ),
                            size: const Size(150, 150),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: subcategories.map((data) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: data.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${data.name} (${(data.amount / totalExpenses * 100).toStringAsFixed(1)}%)',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1,
                      ),
                      itemCount: subcategories.length,
                      itemBuilder: (context, index) {
                        final subcategory = subcategories[index];
                        return Card(
                          color: Colors.white.withOpacity(0.8),
                          elevation: 3,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    subcategory.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${subcategory.amount.toStringAsFixed(2)} BYN',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _addSubcategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
