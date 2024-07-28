import 'package:chatapp/components/my_button.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController conPwController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConPasswordVisible = false;

  void register(BuildContext context) async {
    // auth service
    final authService = AuthService();

    // Check if passwords match
    if (passwordController.text != conPwController.text) {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Passwords do not match"),
              ));
      return;
    }

    try {
      await authService.signUpWithEmailPassword(
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
            Text(
              "Let's Create An Account For you!",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: emailController,
              hintText: 'johndoe@example.com',
              obsecureText: false,
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: passwordController,
              hintText: 'Password',
              obsecureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: conPwController,
              hintText: 'Confirm Password',
              obsecureText: !_isConPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConPasswordVisible = !_isConPasswordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            MyButton(onTap: () => register(context), text: "Sign up"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already Have An Account?",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Login Now",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
