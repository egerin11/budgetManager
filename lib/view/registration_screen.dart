import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/input_field.dart';
import '../utils/text_utils.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onToggle;

  const RegistrationScreen({Key? key, required this.onToggle}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('Успешная регистрация: ${userCredential.user?.email}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Пароль слишком слабый.');
      } else if (e.code == 'email-already-in-use') {
        print('Аккаунт с таким email уже существует.');
      } else {
        print('Ошибка: ${e.message}');
      }
    } catch (e) {
      print('Ошибка: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextUtil(text: "Регистрация", weight: true, size: 30),
            const SizedBox(height: 20),
            InputField(
              hintText: "Email",
              icon: Icons.mail,
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            InputField(
              hintText: "Password",
              icon: Icons.lock,
              controller: _passwordController,
              isObscured: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Зарегистрироваться'),
            ),
            TextButton(
              onPressed: widget.onToggle,
              child: const Text('Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
