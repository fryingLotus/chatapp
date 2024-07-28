import 'package:chatapp/components/my_button.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  // login method
  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();
    try {
      await authService.signInWithEmailPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(e.toString()),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 50),
              Text("Welcome Back",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 20),
              MyTextField(
                  controller: emailController,
                  hintText: 'johndoe@example.com',
                  obsecureText: false),
              const SizedBox(height: 20),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obsecureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              MyButton(onTap: () => login(context), text: "Sign in"),
              // register now
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not A Member?",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register Now",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
