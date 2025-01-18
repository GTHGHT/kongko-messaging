
import 'package:flutter/material.dart';
import 'package:messaging_app_update/utils/chat_data.dart';
import 'package:provider/provider.dart';

import '../components/chats_list_tile.dart';
import '../utils/personal_chat_data.dart';

class AddMembersScreen extends StatelessWidget {

    const AddMembersScreen({Key? key}) : super(key: key);

    showSnackBar(BuildContext context,String value) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(value),
          ),
        );
    }

  @override
  Widget build(BuildContext context) {
    String searchValue = "";
    final searchButton =
    context.select<PersonalChatData, bool>((value) => value.loading)
        ? const SizedBox(
      height: 52.0,
      width: 52.0,
      child: CircularProgressIndicator(),
    )
        : ElevatedButton(
      onPressed: () async {
        final isFound = await context
            .read<PersonalChatData>()
            .getFriendFromEmail(searchValue);
        if (!isFound) {
          showSnackBar(context,"$searchValue tidak ditemukan");
        }
      },
      child: const Text("Cari Teman"),
    );

    final searchResult =
    context.watch<PersonalChatData>().friendModel.email.isEmpty
        ? const Padding(
      padding: EdgeInsets.all(26.0),
      child: Center(
        child: Text("Teman Tidak Ditemukan"),
      ),
    )
        : ChatsListTile(
      imagePath: context.watch<PersonalChatData>().friendModel.image,
      title: context.watch<PersonalChatData>().friendModel.username,
      onTap: () async {
        try {
          await context.read<ChatData>().addMember(context.read<PersonalChatData>().friendModel.uid);
          Navigator.of(context).pop();
        } catch (e) {
          showSnackBar(context ,"Member Sudah Ada");
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Personal Chat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (value)=>searchValue = value,
              decoration: const InputDecoration(labelText: "Email Teman"),
            ),
            const SizedBox(
              height: 20,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: searchButton,
            ),
            const SizedBox(
              height: 20,
            ),
            AnimatedSwitcher(
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  child: child,
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                ),
              ),
              duration: const Duration(milliseconds: 200),
              child: searchResult,
            ),
          ],
        ),
      ),
    );
  }
}