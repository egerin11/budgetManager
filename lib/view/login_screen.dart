import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/animations.dart';
import '../data/bg_data.dart';
import '../utils/text_utils.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedIndex = 0;
  bool showOption = false;
  bool isLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Регистрация успешна: ${userCredential.user!.email}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: пользователь не создан.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Этот email уже используется.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Пароль слишком слабый.';
        } else {
          errorMessage = 'Ошибка: ${e.message}';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Неизвестная ошибка: $e')));
      }
    }
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Вход успешен: ${userCredential.user!.email}')));
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'Пользователь с таким email не найден.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Неверный пароль.';
        } else {
          errorMessage = 'Ошибка: ${e.message}';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Неизвестная ошибка: $e')));
      }
    }
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        height: 49,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: showOption
                  ? ShowUpAnimation(
                      delay: 100,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: bgList.length,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16.0),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: selectedIndex == index
                                  ? Colors.white
                                  : Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(bgList[index]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox(),
            ),
            const SizedBox(width: 20),
            showOption
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = false;
                      });
                    },
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 25),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = true;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(bgList[selectedIndex]),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(bgList[selectedIndex]), fit: BoxFit.fill),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Center(
                        child: TextUtil(
                            text: isLogin ? "Вход" : "Регистрация",
                            weight: true,
                            size: 30),
                      ),
                      const Spacer(),
                      TextUtil(text: "Email"),
                      Container(
                        height: 35,
                        decoration: const BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: Colors.white)),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.mail, color: Colors.white),
                            fillColor: Colors.white,
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Введите email';
                            return null;
                          },
                        ),
                      ),
                      const Spacer(),
                      TextUtil(text: "Password"),
                      Container(
                        height: 35,
                        decoration: const BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: Colors.white)),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.lock, color: Colors.white),
                            fillColor: Colors.white,
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Введите пароль';
                            return null;
                          },
                        ),
                      ),
                      if (!isLogin) ...[
                        const Spacer(),
                        TextUtil(text: "Confirm Password"),
                        Container(
                          height: 35,
                          decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.white)),
                          ),
                          child: TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.lock, color: Colors.white),
                              fillColor: Colors.white,
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Подтвердите пароль';
                              return null;
                            },
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (isLogin)
                        Row(
                          children: [
                            Container(
                                height: 15, width: 15, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextUtil(
                                  text: "Запомнить меня",
                                  size: 12,
                                  weight: true),
                            ),
                          ],
                        ),
                      const Spacer(),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        child: ElevatedButton(
                          onPressed: isLogin ? _signIn : _registerUser,
                          style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent),
                          child: Center(
                              child: Text(isLogin ? 'Вход' : 'Регистрация')),
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: GestureDetector(
                          onTap: toggleForm,
                          child: TextUtil(
                              text: isLogin
                                  ? "Создать аккаунт"
                                  : "Уже есть аккаунт?",
                              color: Colors.white,
                              size: 12),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
