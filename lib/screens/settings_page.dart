import 'package:flutter/material.dart';
import 'package:messaging_app_update/services/access_services.dart';
import 'package:messaging_app_update/utils/bottom_nav_bar_data.dart';
import 'package:provider/provider.dart';

import '../services/storage_services.dart';
import '../utils/image_data.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
          height: 20,
        ),
        ListTile(
          leading: FutureBuilder<String>(
            future: StorageService.getImageLink(
                context.read<AccessServices>().userModel.image),
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return CircleAvatar(
                radius: 32,
                child: ClipOval(
                  child: Image.network(snapshot.data ?? ""),
                ),
              );
            },
          ),
          title: Text(context.watch<AccessServices>().userModel.username),
          subtitle: Text(context.watch<AccessServices>().userModel.email),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text("Ubah Data Akun"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () {context.read<ImageData>().clearImage();Navigator.pushNamed(context, "/update_account");},
        ),
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text("Ubah Tema"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => Navigator.pushNamed(context, '/change_theme_mode'),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Keluar Dari Akun"),
          onTap: () {
            context.read<AccessServices>().logout();
            context.read<BottomNavBarData>().currentIndex = 0;
            Navigator.pushReplacementNamed(context, "/landing");
          },
        ),
      ],
    );
  }
}