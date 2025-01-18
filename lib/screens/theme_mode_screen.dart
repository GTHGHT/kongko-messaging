import 'package:flutter/material.dart';
import 'package:messaging_app_update/utils/theme_mode_data.dart';
import 'package:provider/provider.dart';

class ThemeModeScreen extends StatelessWidget {
  const ThemeModeScreen({Key? key}) : super(key: key);

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Tema"),
      ),
      body: Column(
        children: [
          ListTileRadio(
            titleString: "Pengaturan Sistem",
            onTap: () {
              context.read<ThemeModeData>().changeTheme(ThemeMode.system);
              showSnackBar(
                context,
                "Tema berubah menjadi Pengaturan Sistem",
              );
            },
            groupValue: context.watch<ThemeModeData>().themeMode,
            value: ThemeMode.system,
          ),
          ListTileRadio(
            titleString: "Terang",
            onTap: () {
              context.read<ThemeModeData>().changeTheme(ThemeMode.light);
              showSnackBar(
                context,
                "Tema berubah menjadi Terang",
              );
            },
            groupValue: context.watch<ThemeModeData>().themeMode,
            value: ThemeMode.light,
          ),
          ListTileRadio(
            titleString: "Gelap",
            onTap: () {
              context.read<ThemeModeData>().changeTheme(ThemeMode.dark);
              showSnackBar(
                context,
                "Tema berubah menjadi Gelap",
              );
            },
            groupValue: context.watch<ThemeModeData>().themeMode,
            value: ThemeMode.dark,
          ),
        ],
      ),
    );
  }
}

class ListTileRadio extends StatelessWidget {
  final String titleString;
  final VoidCallback onTap;
  final Object groupValue;
  final Object value;

  const ListTileRadio({
    Key? key,
    required this.titleString,
    required this.onTap,
    required this.groupValue,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(titleString),
      onTap: onTap,
      leading: Radio(
        value: value,
        groupValue: groupValue,
        onChanged: (value) {
          onTap();
        },
      ),
    );
  }
}