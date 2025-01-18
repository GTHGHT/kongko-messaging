import 'package:flutter/material.dart';
import 'package:messaging_app_update/utils/group_data.dart';
import 'package:messaging_app_update/utils/personal_chat_data.dart';
import 'package:provider/provider.dart';

import '../services/access_services.dart';
import '../utils/chat_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreensState();
}

class _RegisterScreensState extends State<RegisterScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  int passwordCounter = 0;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerButton = context.watch<AccessServices>().loading
        ? const SizedBox(
      key: ValueKey(1),
            height: 52.0,
            width: 52.0,
            child: CircularProgressIndicator(),
          )
        : SizedBox(
      key: const ValueKey(2),
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<AccessServices>()
                    .register(
                      username: usernameController,
                      email: emailController,
                      password: passwordController,
                      confirmPassword: confirmPasswordController,
                      showSnackBar: (String message) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(message),
                            ),
                          );
                      },
                    )
                    .then(
                  (value) {
                    if (value) {
                      context.read<GroupData>().loadUser();
                      context.read<PersonalChatData>().loadUser();
                      context.read<ChatData>().loadUser();
                      Navigator.pushReplacementNamed(context, "/main");
                    }
                  },
                );
              },
              child: const Text("Register"),
            ),
          );

    // TODO: Desain Ulang Bagian Register
    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 6) * 5,
                child: TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(hintText: "Username"),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 6) * 5,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(hintText: "Email"),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 6) * 5,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Password"),
                  style: Theme.of(context).textTheme.bodyMedium,
                  buildCounter: (
                    BuildContext context, {
                    required int currentLength,
                    required int? maxLength,
                    required bool isFocused,
                  }) {
                    return Text(
                      '$currentLength Karakter',
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 6) * 5,
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(hintText: "Konfirmasi Password"),
                  style: Theme.of(context).textTheme.bodyMedium,
                  buildCounter: (
                    BuildContext context, {
                    required int currentLength,
                    required int? maxLength,
                    required bool isFocused,
                  }) {
                    return Text(
                      '$currentLength Karakter',
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: registerButton,
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/access");
                  },
                  child: const Text("Kembali"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}