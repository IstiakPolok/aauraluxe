import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme.dart';
import '../controllers/login_controller.dart';
import '../../../../app/routes/app_routes.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
            child: const Text('Skip to Shop', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.s24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(AppTheme.s32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.borderLarge,
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.softShadow,
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Placeholder
                  const Center(
                    child: Hero(
                      tag: 'logo',
                      child: Text(
                        'A U R A L U X E',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.s8),
                  Obx(() => Text(
                        controller.isSignUp.value
                            ? 'Create an account to start shopping'
                            : 'Sign in to access your orders',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      )),
                  const SizedBox(height: AppTheme.s32),

                  // Email Field
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppTheme.s8),
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'name@example.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.s24),

                  // Password Field
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppTheme.s8),
                  Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: !controller.showPassword.value,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showPassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: AppTheme.s32),

                  // Submit Button
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(controller.isSignUp.value ? 'Create Account' : 'Sign In'),
                      )),
                  const SizedBox(height: AppTheme.s24),

                  // Switch Mode Link
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.isSignUp.value
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: controller.toggleMode,
                            child: Text(
                              controller.isSignUp.value ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
