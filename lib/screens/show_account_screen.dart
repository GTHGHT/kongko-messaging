import 'package:flutter/material.dart';
import 'package:messaging_app_update/utils/show_account_data.dart';
import 'package:provider/provider.dart';

import '../services/storage_services.dart';

class ShowAccountScreen extends StatelessWidget {
  const ShowAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${context.watch<ShowAccountData>().userModel.username} Profile"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 64,
            child: ClipOval(
              child: context.watch<ShowAccountData>().userModel.image.isEmpty
                  ? Image.asset("images/default_group.png")
                  : FutureBuilder<String>(
                      future: StorageService.getImageLink(
                          context.watch<ShowAccountData>().userModel.image),
                      builder: (_, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Image(
                          image: NetworkImage(snapshot.data ?? ""),
                        );
                      },
                    ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(context.watch<ShowAccountData>().userModel.username),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(context.watch<ShowAccountData>().userModel.email),
          ),
        ],
      ),
    );
  }
}