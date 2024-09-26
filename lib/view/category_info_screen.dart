import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryInfoScreen extends StatelessWidget {
  final String category;

  const CategoryInfoScreen({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: Center(
        child: Text('Информация о категории: $category'),
      ),
    );
  }
}
