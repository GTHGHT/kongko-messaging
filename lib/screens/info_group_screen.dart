import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app_update/services/access_services.dart';
import 'package:messaging_app_update/utils/chat_data.dart';
import 'package:messaging_app_update/utils/group_data.dart';
import 'package:messaging_app_update/utils/personal_chat_data.dart';
import 'package:messaging_app_update/utils/search_data.dart';
import 'package:messaging_app_update/utils/show_account_data.dart';
import 'package:provider/provider.dart';

import '../components/update_bottom_sheet.dart';
import '../services/storage_services.dart';
import '../utils/image_data.dart';

class InfoGroupScreen extends StatelessWidget {
  const InfoGroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          buildGroupImage(context),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(Icons.text_snippet),
            title: const Text("Grup Id"),
            subtitle: Text(context.watch<ChatData>().groupId),
          ),
          buildTitleTile(context),
          buildDescTile(context),
          buildGroupMembers(context),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      ),
    );
  }

  Widget buildGroupMembers(BuildContext context) {
    return Card(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: context.watch<ChatData>().getGroupMembers(),
        builder: (context, snapshot) {
          Widget defaultEmptyReturn = const Center(
            child: Text("Member Kosong, Mungkin Terjadi Error"),
          );
          if (!(snapshot.hasData)) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final members = snapshot.data!.docs;
          if (members.isEmpty) {
            return defaultEmptyReturn;
          }

          return Column(
            children: members
                .where((element) =>
                    element["username"].toString().toLowerCase().contains(
                          context.watch<SearchData>().searchTerm.toLowerCase(),
                        ))
                .map<Widget>(
                  (value) => MemberListTile(
                    image: value["image"],
                    name: value["username"],
                    isAdmin: value.data().containsKey("isAdmin")
                        ? value["isAdmin"]
                        : false,
                    onTap: () async {
                      if (context.read<AccessServices>().userModel.uid !=
                          value["uid"]) {
                        await context
                            .read<ShowAccountData>()
                            .loadUserModel(value['uid']);
                        Navigator.pushNamed(context, '/show_account');
                      }
                    },
                    onLongPress: context.watch<ChatData>().isAdmin
                        ? () {
                            if (context.read<AccessServices>().userModel.uid !=
                                value["uid"]) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    title: const Text("Pilih Aksi"),
                                    children: [
                                      if (!(value.data().containsKey("isAdmin")
                                          ? value["isAdmin"]
                                          : false))
                                        SimpleDialogOption(
                                          child: Text(
                                            "Jadikan Sebagai Admin",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<ChatData>()
                                                .changeAdminStatus(
                                                    value["uid"], true);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      if (value.data().containsKey("isAdmin")
                                          ? value["isAdmin"]
                                          : false)
                                        SimpleDialogOption(
                                          child: Text(
                                            "Batalkan Sebagai Admin",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<ChatData>()
                                                .changeAdminStatus(
                                                    value["uid"], false);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      SimpleDialogOption(
                                        child: Text(
                                          "Keluarkan Dari Grup",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<ChatData>()
                                              .kickMember(value["uid"]);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      SimpleDialogOption(
                                        child: Text(
                                          "Lihat Profil",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        onPressed: () async {
                                          await context
                                              .read<ShowAccountData>()
                                              .loadUserModel(value['uid']);
                                          Navigator.popAndPushNamed(
                                              context, '/show_account');
                                        },
                                      ),
                                      // SimpleDialogOption(
                                      //   child: Text("Pesan Personal Chat"),
                                      //   onPressed: () async {
                                      //     try {
                                      //       await context
                                      //           .read<PersonalChatData>()
                                      //           .loadFriendFromId(
                                      //               value['uid']);
                                      //       final pcId = await context
                                      //           .read<PersonalChatData>()
                                      //           .gotoPersonalChat();
                                      //       context
                                      //               .read<ChatData>()
                                      //               .groupModel =
                                      //           GroupModel.fromMap({
                                      //         'id': pcId,
                                      //         'title': context
                                      //             .read<PersonalChatData>()
                                      //             .friendModel
                                      //             .username,
                                      //         'image': context
                                      //             .read<PersonalChatData>()
                                      //             .friendModel
                                      //             .image,
                                      //       });
                                      //       context.read<ChatData>().pcUid =
                                      //           context
                                      //               .read<
                                      //                   PersonalChatData>()
                                      //               .friendModel
                                      //               .uid;
                                      //       Navigator.popAndPushNamed(
                                      //           context, '/chat');
                                      //     } catch (e) {
                                      //       debugPrint(e.toString());
                                      //     }
                                      //   },
                                      // ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        : null,
                  ),
                )
                .toList()
              ..insert(
                0,
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      "Member Grup",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Expanded(child: SizedBox()),
                    if (context.watch<ChatData>().isAdmin)
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          context.read<PersonalChatData>().clearModel();
                          Navigator.pushNamed(context, "/chat/info/add");
                        },
                      ),
                    IconButton(
                      onPressed: () {
                        context.read<SearchData>().toggleSearchField();
                      },
                      icon: Icon(context.watch<SearchData>().showSearchField
                          ? Icons.close
                          : Icons.search),
                    ),
                  ],
                ),
              )
              ..insert(
                1,
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: context.watch<SearchData>().showSearchField
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) =>
                                context.read<SearchData>().searchTerm = value,
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
          );
        },
      ),
    );
  }

  Widget buildDescTile(BuildContext context) {
    return ListTile(
      title: const Text("Deskripsi Grup"),
      subtitle: Text(context.watch<ChatData>().groupModel.desc ?? ""),
      trailing: const Icon(Icons.edit),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: UpdateBottomSheet(
              initialValue: context.watch<ChatData>().groupModel.desc ?? "",
              title: "Ubah Deskripsi Grup",
              loading: context.watch<ChatData>().loading,
              onPressed: (context, value) async {
                await context.read<ChatData>().changeGroupDesc(value);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  ListTile buildTitleTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.groups),
      title: const Text("Judul Grup"),
      subtitle: Text(context.watch<ChatData>().title),
      trailing: const Icon(Icons.edit),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: UpdateBottomSheet(
              initialValue: context.watch<ChatData>().title,
              title: "Ubah Judul Group",
              loading: context.watch<ChatData>().loading,
              onPressed: (context, value) async {
                await context.read<ChatData>().changeGroupTitle(value);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGroupImage(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.read<ImageData>().showImagePickerDialog(context);
        context
            .read<ChatData>()
            .changeGroupImage(context.read<ImageData>().image);
        showDialog(
            context: context,
            builder: (context) {
              if (context.watch<ChatData>().loading) {
                return AlertDialog(
                    title: const Text("Mengubah Gambar..."),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                      ],
                    ));
              } else {
                Navigator.pop(context);
                return const SizedBox();
              }
            });
      },
      child: CircleAvatar(
        radius: 64,
        child: ClipOval(
          child: context.watch<ChatData>().image.isEmpty
              ? Image.asset("images/default_group.png")
              : FutureBuilder<String>(
                  future: StorageService.getImageLink(
                      context.watch<ChatData>().image),
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
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("Info Group"),
      actions: [
        Tooltip(
          message: "Keluar Grup",
          child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar Grup'),
                    content: const Text('Apakah Kamu Yakin Ingin Keluar Dari Grup?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await context
                              .read<GroupData>()
                              .exitGroup(context.read<ChatData>().groupId);
                          Navigator.popUntil(
                              context, (e) => e.isFirst); // Closes the dialog
                        },
                        child: const Text('Ya'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.exit_to_app)),
        )
      ],
    );
  }
}

class MemberListTile extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String image;
  final String name;
  final bool isAdmin;

  const MemberListTile({
    Key? key,
    this.onTap,
    this.onLongPress,
    required this.image,
    required this.name,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            ClipOval(
              child: FutureBuilder<String>(
                future: StorageService.getImageLink(image),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Image(
                    image: NetworkImage(snapshot.data ?? ""),
                    height: 44,
                    width: 44,
                  );
                },
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 5,
                ),
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Admin"),
                  )
              ],
            ),
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}