import 'package:flutter/material.dart';

class AccessScreen extends StatelessWidget {
  const AccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? "images/app_logo_round.png"
                    : "images/app_logo_round_b.png",
                width: MediaQuery.of(context).size.width / 2,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                "Kongko",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(
                height: 100,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pushReplacementNamed("/register");
                  },
                  child: const Text("Register"),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/login");
                  },
                  child: const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}