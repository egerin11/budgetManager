import 'package:flutter/material.dart';
import '../utils/text_utils.dart';
import '../view/home_screen.dart';

class AuthForm extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const AuthForm({super.key, required this.isLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Center(
          child: TextUtil(
            text: isLogin ? "Вход" : "Регистрация",
            weight: true,
            size: 30,
          ),
        ),
        const Spacer(),
        TextUtil(
          text: "Email",
        ),
        _buildTextField(Icons.mail),
        const Spacer(),
        TextUtil(
          text: "Password",
        ),
        _buildTextField(Icons.lock),
        if (!isLogin) ...[
          const Spacer(),
          TextUtil(
            text: "Confirm Password",
          ),
          _buildTextField(Icons.lock),
        ],
        const Spacer(),
        Row(
          children: [
            Container(
              height: 15,
              width: 15,
              color: Colors.white,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextUtil(
                text: "Запомнить меня",
                size: 12,
                weight: true,
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildActionButton(context),
        const Spacer(),
        GestureDetector(
          onTap: onToggle,
          child: Center(
            child: TextUtil(
              text: isLogin
                  ? "Нет аккаунта? ЗАРЕГИСТРИРОВАТЬСЯ"
                  : "Уже есть аккаунт? ВОЙТИ",
              size: 12,
              weight: true,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildTextField(IconData icon) {
    return Container(
      height: 35,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white)),
      ),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          suffixIcon: Icon(
            icon,
            color: Colors.white,
          ),
          fillColor: Colors.white,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          print(isLogin ? 'Login button pressed' : 'Register button pressed');
          if (isLogin) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        },
        child: TextUtil(
          text: isLogin ? "Вход" : "Регистрация",
          color: Colors.black,
        ),
      ),
    );
  }
}
