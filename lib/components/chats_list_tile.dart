import 'package:flutter/material.dart';

import '../services/storage_services.dart';

class ChatsListTile extends StatelessWidget {
  const ChatsListTile({
    Key? key,
    required this.imagePath,
    required this.title,
    this.onTap,
    this.trailing,
    this.subtitle,
  }) : super(key: key);

  final String imagePath;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipOval(
        child: FutureBuilder<String>(
          future: StorageService.getImageLink(imagePath),
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              );
            }
            return Image(
              image: NetworkImage(snapshot.data ?? "default_profile.png"),
              height: 44,
              width: 44,
            );
          },
        ),
      ),
      title: Text(
        title,
        style: Theme
            .of(context)
            .textTheme
            .bodyLarge,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:trailing,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}