// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '魔盒',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Obx(() {
                if (authController.isLoading) {
                  return const CircularProgressIndicator();
                }
                return Column(
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '密码',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        authController.login(
                          usernameController.text,
                          passwordController.text,
                        );
                      },
                      child: const Text('登录'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('注册新用户'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: usernameController,
                                  decoration: const InputDecoration(
                                    labelText: '用户名',
                                  ),
                                ),
                                TextField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    labelText: '邮箱',
                                  ),
                                ),
                                TextField(
                                  controller: phoneController,
                                  decoration: const InputDecoration(
                                    labelText: '手机号（选填）',
                                  ),
                                ),
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: '密码',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('取消'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  authController.register(
                                    username: usernameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                    phoneNumber: phoneController.text.isEmpty
                                        ? null
                                        : phoneController.text,
                                  );
                                  Get.back();
                                },
                                child: const Text('注册'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('注册新用户'),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
