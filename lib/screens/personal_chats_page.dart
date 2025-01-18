import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app_update/services/access_services.dart';
import 'package:messaging_app_update/utils/personal_chat_data.dart';
import 'package:provider/provider.dart';

import '../components/chats_list_tile.dart';
import '../utils/chat_data.dart';
import '../model/group_model.dart';
import '../utils/search_data.dart';

class PersonalChatsPage extends StatelessWidget {
  const PersonalChatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const defaultImage = "default_profile.png";
    return context.watch<AccessServices>().userModel.username.isEmpty
        ? const SizedBox()
        : StreamBuilder<QuerySnapshot>(
            initialData: null,
            stream: context.watch<PersonalChatData>().getUserPersonalChats(),
            builder: (context, snapshot) {
              Widget defaultEmptyReturn = const Center(
                child: Text(
                  "Personal Chat Kosong, \nSilahkan Join atau Buat Grup",
                  textAlign: TextAlign.center,
                ),
              );
              if (!(snapshot.hasData)) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final personalChats = snapshot.data!.docs.toList();
              if (personalChats.isEmpty) {
                return defaultEmptyReturn;
              } else {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final pcData =
                        personalChats[index].data() as Map<String, dynamic>;
                    return ChatsListTile(
                      imagePath: pcData['image'] ?? defaultImage,
                      title: pcData['username'],
                      onTap: () {
                        context.read<ChatData>().groupModel = GroupModel(
                          id: pcData['id'],
                          title: pcData['username'],
                          image: pcData['image'],
                          isPC: true,
                        );
                        context.read<ChatData>().pcUid = pcData['uid'];
                        context.read<SearchData>().clearSearch();
                        Navigator.of(context).pushNamed("/chat");
                      },
                    );
                  },
                  itemCount: personalChats.length,
                );
              }
            },
          );
  }
}