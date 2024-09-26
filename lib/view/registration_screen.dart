import 'package:flutter/material.dart';
import '../utils/input_field.dart';
import '../utils/text_utils.dart';

class RegistrationScreen extends StatelessWidget {
  final VoidCallback onToggle;

  const RegistrationScreen({Key? key, required this.onToggle}) : super(key: key);

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
            const InputField(
              hintText: "Email",
              icon: Icons.mail,
            ),
            const SizedBox(height: 20),
            const InputField(
              hintText: "Password",
              icon: Icons.lock,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('кнопка регистрации нажата');
              },
              child: const Text('Зарегистрироваться'),
            ),
            TextButton(
              onPressed: onToggle,
              child: const Text('Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
