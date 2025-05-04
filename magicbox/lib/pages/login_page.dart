// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController authController = Get.find();
  String method = 'phone'; // 默认手机号登录
  final accountController = TextEditingController();
  final codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [method == 'phone', method == 'email'],
              onPressed: (index) {
                setState(() {
                  method = index == 0 ? 'phone' : 'email';
                });
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('手机号')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('邮箱')),
              ],
            ),
            TextField(
              controller: accountController,
              decoration: const InputDecoration(labelText: '手机号或邮箱'),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: '验证码'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authController.login(method, accountController.text.trim(), codeController.text.trim());
              },
              child: const Text('登录'),
            )
          ],
        ),
      ),
    );
  }
}
