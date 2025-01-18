import 'package:flutter/material.dart';
import 'package:messaging_app_update/services/access_services.dart';
import 'package:messaging_app_update/utils/chat_data.dart';
import 'package:messaging_app_update/utils/group_data.dart';
import 'package:messaging_app_update/utils/personal_chat_data.dart';
import 'package:provider/provider.dart';

class LoginScreens extends StatefulWidget {
  const LoginScreens({Key? key}) : super(key: key);

  @override
  State<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int passwordCounter = 0;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginButton = context.watch<AccessServices>().loading
        ? const SizedBox(key: ValueKey(2),height: 52.0,
        width: 52.0,child: CircularProgressIndicator())
        : SizedBox(
      key: const ValueKey(2),
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<AccessServices>()
                    .login(
                      email: emailController,
                      password: passwordController,
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
                    .then((value) {
                  if (value) {
                    context.read<GroupData>().loadUser();
                    context.read<PersonalChatData>().loadUser();
                    context.read<ChatData>().loadUser();
                    Navigator.of(context).pushReplacementNamed("/main");
                  }
                });
              },
              child: const Text("Login"),
            ),
          );

    // TODO: Desain Ulang Bagian Login
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
                height: 50,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: loginButton,
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