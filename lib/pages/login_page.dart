import 'package:flutter/material.dart';
import 'package:happy_chat/pages/signup_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                label: Text('Email'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  final isValid = _formKey.currentState?.validate() ?? false;
                  if (!isValid) {
                    return;
                  }
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  final res = await Supabase.instance.client.auth
                      .signIn(email: email, password: password);
                  if (res.error != null) {
                    print(res.error.toString());
                    return;
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Signin')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SignupPage(),
                    ),
                  );
                },
                child: const Text('Create an account')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
