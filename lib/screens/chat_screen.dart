import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messaging_app_update/services/access_services.dart';
import 'package:messaging_app_update/utils/chat_data.dart';
import 'package:messaging_app_update/utils/show_account_data.dart';
import 'package:provider/provider.dart';

import '../services/storage_services.dart';
import '../utils/search_data.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildAppBarTitle(context),
        actions: [
          IconButton(
              onPressed: () {
                context.read<SearchData>().toggleSearchField();
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: context.read<ChatData>().streamMessages(),
              builder: (ctx, snapshot) {
                const defaultEmptyReturn = Center(
                  child: Text("Pesan Kosong, Mulailah Berbicara"),
                );
                if (!(snapshot.hasData)) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data!.docs.reversed
                    .where((e) => e['text'].toString().toLowerCase().contains(
                        context.read<SearchData>().searchTerm.toLowerCase()))
                    .toList();
                if (messages.isEmpty) {
                  return defaultEmptyReturn;
                }

                return ListView.separated(
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      sender: messages[index]['sender'],
                      text: messages[index]['text'],
                      senderUid: messages[index]['sender_uid'],
                      sentTime: ((messages[index]['sent_time'] ??
                              Timestamp.now()) as Timestamp)
                          .toDate(),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: messages.length,
                );
              },
            ),
          ),
          const ChatTextField(),
        ],
      ),
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    return context.watch<SearchData>().showSearchField
        ? TextField(
            autofocus: true,
            showCursor: true,
            onChanged: (value) {
              context.read<SearchData>().searchTerm = value;
            },
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          )
        : ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipOval(
              child: FutureBuilder<String>(
                future: StorageService.getImageLink(
                  context.select<ChatData, String>((value) => value.image),
                ),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Image(
                    image: NetworkImage(snapshot.data ?? ""),
                    height: 40,
                    width: 40,
                  );
                },
              ),
            ),
            title: Text(
              context.select<ChatData, String>((value) => value.title),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: context.watch<ChatData>().groupModel.isPC
                ? () async {
                    await context
                        .read<ShowAccountData>()
                        .loadUserModel(context.read<ChatData>().pcUid);
                    Navigator.pushNamed(context, "/show_account");
                  }
                : () async {
                    context.read<SearchData>().clearSearch();
                    await context.read<ChatData>().loadDesc();
                    Navigator.of(context).pushNamed("/chat/info");
                  },
          );
  }
}

class ChatTextField extends StatefulWidget {
  const ChatTextField({Key? key}) : super(key: key);

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  late TextEditingController messageController;

  @override
  initState() {
    messageController =
        TextEditingController(text: context.read<ChatData>().messageText);
    super.initState();
  }

  @override
  dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendButton = context.watch<ChatData>().loading
        ? const CircularProgressIndicator()
        : TextButton(
            onPressed: () {
              context.read<ChatData>().send();
              messageController.clear();
            },
            child: const Text(
              'Send',
            ),
          );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: messageController,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                decoration: const InputDecoration.collapsed(
                  hintText: "Pesan",
                ),
                autofocus: true,
                onChanged: (value) =>
                    context.read<ChatData>().messageText = value,
                onSubmitted: (_) {
                  context.read<ChatData>().send();
                  messageController.clear();
                },
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: sendButton,
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String senderUid;
  final DateTime sentTime;

  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.senderUid,
    required this.sentTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rowChildren = [
      Material(
        elevation: 3,
        color: senderUid ==
                context.select<AccessServices, String>(
                  (value) => value.userModel.uid,
                )
            ? Colors.lightBlueAccent
            : Colors.lightGreenAccent,
        borderRadius: senderUid ==
                context.select<AccessServices, String>(
                    (value) => value.userModel.uid)
            ? const BorderRadius.all(Radius.circular(15)).copyWith(
                topRight: Radius.zero,
              )
            : const BorderRadius.all(Radius.circular(15)).copyWith(
                topLeft: Radius.zero,
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Column(
            crossAxisAlignment: senderUid ==
                    context.select<AccessServices, String>(
                        (value) => value.userModel.uid)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 2 + 50,
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 5,
                  textAlign: senderUid ==
                          context.select<AccessServices, String>(
                              (value) => value.userModel.uid)
                      ? TextAlign.end
                      : TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      Column(
        children: [
          Text(
            DateFormat.yMd().format(sentTime),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            DateFormat.Hms().format(sentTime),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      )
    ];
    return Row(
      mainAxisAlignment: senderUid ==
              context.select<AccessServices, String>(
                  (value) => value.userModel.uid)
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: senderUid ==
              context.select<AccessServices, String>(
                  (value) => value.userModel.uid)
          ? rowChildren.reversed.toList()
          : rowChildren,
    );
  }
}