import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isSignUp = false.obs;
  final showPassword = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleMode() {
    isSignUp.value = !isSignUp.value;
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    bool success;
    if (isSignUp.value) {
      success = await _authController.signUp(email, password);
    } else {
      success = await _authController.login(email, password);
    }
    
    isLoading.value = false;
    if (success) {
      emailController.clear();
      passwordController.clear();
    }
  }
}
