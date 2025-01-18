import 'package:flutter/material.dart';
import 'package:messaging_app_update/screens/groups_page.dart';
import 'package:messaging_app_update/screens/personal_chats_page.dart';
import 'package:messaging_app_update/screens/settings_page.dart';
import 'package:messaging_app_update/utils/personal_chat_data.dart';
import 'package:provider/provider.dart';

import '../utils/bottom_nav_bar_data.dart';
import '../utils/group_data.dart';
import '../utils/image_data.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  PreferredSizeWidget? buildAppBar(BuildContext context, int index) {
    if (index == 0) {
      return AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Personal Chat"),
        actions: [
          Tooltip(
            message: "Buat Personal Chat",
            child: IconButton(
              onPressed: () {
                context.read<PersonalChatData>().clearModel();
                Navigator.of(context).pushNamed('/create_pc');
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      );
    } else if (index == 1) {
      return AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Group"),
        actions: [
          Tooltip(
            message: "Buat Grup",
            child: IconButton(
              onPressed: () {
                context.read<ImageData>().clearImage();
                Navigator.of(context).pushNamed('/create_group');
              },
              icon: const Icon(Icons.add),
            ),
          ),
          Tooltip(
            message: "Gabung Grup",
            child: IconButton(
              onPressed: () {
                context.read<GroupData>().clearModel();
                Navigator.of(context).pushNamed('/join_group');
              },
              icon: const Icon(Icons.group),
            ),
          )
        ],
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const PersonalChatsPage(),
      const GroupsPage(),
      const SettingsPage()
    ];

    return Scaffold(
      appBar:
          buildAppBar(context, context.watch<BottomNavBarData>().currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: context.watch<BottomNavBarData>().currentIndex,
        onTap: (index) => context.read<BottomNavBarData>().currentIndex = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Personal Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: _pages.elementAt(
          context.watch<BottomNavBarData>().currentIndex,
        ),
      ),
    );
  }
}