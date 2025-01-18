import 'package:flutter/material.dart';
import 'package:messaging_app_update/model/group_model.dart';
import 'package:messaging_app_update/utils/image_data.dart';
import 'package:provider/provider.dart';

import '../utils/group_data.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController groupId = TextEditingController();
  TextEditingController groupTitle = TextEditingController();
  TextEditingController groupDesc = TextEditingController();

  showSnackBar(String content) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(content),
        ),
      );
  }

  @override
  dispose() {
    super.dispose();
    groupId.dispose();
    groupTitle.dispose();
    groupDesc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addButton = context.select<GroupData, bool>((value) => value.loading)
        ? const SizedBox(
            height: 52.0,
            width: 52.0,
            child: CircularProgressIndicator(),
          )
        : ElevatedButton(
            onPressed: () async {
              context.read<GroupData>().groupModel = GroupModel(
                  id: groupId.text,
                  title: groupTitle.text,
                  image: "",
                  desc: groupDesc.text);
              bool success = await context
                  .read<GroupData>()
                  .createGroup(context.read<ImageData>().image);
              if (success) {
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text("Group Sudah Ada"),
                    ),
                  );
              }
            },
            child: const Text("Buat Grup"),
          );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Grup"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () =>
                  context.read<ImageData>().showImagePickerDialog(context),
              child: CircleAvatar(
                radius: 64,
                child: ClipOval(
                  child: context.watch<ImageData>().image != null
                      ? Image.file(context.watch<ImageData>().image!)
                      : Image.asset("images/default_group.png"),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: groupId,
              decoration: const InputDecoration(labelText: "ID Grup"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: groupTitle,
              decoration: const InputDecoration(labelText: "Judul Grup"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: groupDesc,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Deskripsi Grup",
                contentPadding: EdgeInsets.all(10),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: addButton,
            ),
          ],
        ),
      ),
    );
  }
}