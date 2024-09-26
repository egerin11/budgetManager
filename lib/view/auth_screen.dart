import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/animations.dart';
import '../data/bg_data.dart';
import '../utils/auth_form.dart';
import '../utils/floating_action_button_section.dart';
import '../utils/text_utils.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int selectedIndex = 0;
  bool showOption = false;
  bool isLogin = true;

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButtonSection(
        selectedIndex: selectedIndex,
        showOption: showOption,
        onSelect: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        toggleShowOption: () {
          setState(() {
            showOption = !showOption;
          });
        },
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgList[selectedIndex]),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: AuthForm(
                  isLogin: isLogin,
                  onToggle: toggleForm,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
