import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/access_screen.dart';
import 'screens/add_members_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/create_group_screen.dart';
import 'screens/create_personal_chat.dart';
import 'screens/info_group_screen.dart';
import 'screens/join_group_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/register_screen.dart';
import 'screens/show_account_screen.dart';
import 'screens/theme_mode_screen.dart';
import 'screens/update_account_screen.dart';
import 'services/access_services.dart';
import 'utils/bottom_nav_bar_data.dart';
import 'utils/chat_data.dart';
import 'utils/group_data.dart';
import 'utils/image_data.dart';
import 'utils/personal_chat_data.dart';
import 'utils/search_data.dart';
import 'utils/show_account_data.dart';
import 'utils/theme_mode_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Kongko());
}

class Kongko extends StatelessWidget {
  const Kongko({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textTheme = TextTheme(
      titleLarge: TextStyle(
        fontFamily: "Philosopher",
        fontWeight: FontWeight.w500,
        fontSize: 22,
      ),
      titleMedium: TextStyle(
        fontFamily: "Mulish",
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        fontFamily: "Mulish",
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: "Mulish",
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        fontFamily: "Mulish",
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
      displaySmall: TextStyle(
        fontFamily: "Philosopher",
        fontSize: 36,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GroupData>(
          create: (_) => GroupData(),
        ),
        ChangeNotifierProvider<ImageData>(
          create: (_) => ImageData(),
        ),
        ChangeNotifierProvider<AccessServices>(
          create: (_) => AccessServices(),
        ),
        ChangeNotifierProvider<BottomNavBarData>(
          create: (_) => BottomNavBarData(),
        ),
        ChangeNotifierProvider<ChatData>(
          create: (_) => ChatData(),
        ),
        ChangeNotifierProvider<PersonalChatData>(
          create: (_) => PersonalChatData(),
        ),
        ChangeNotifierProvider<ThemeModeData>(
          create: (_) => ThemeModeData(),
        ),
        ChangeNotifierProvider<SearchData>(
          create: (_) => SearchData(),
        ),
        ChangeNotifierProvider<ShowAccountData>(
          create: (_) => ShowAccountData(),
        ),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: context.watch<ThemeModeData>().themeMode,
          // Light Theme
          theme: ThemeData.light().copyWith(
            colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: Colors.lightBlue,
              error: Colors.deepOrange,
              onBackground: Colors.grey,
            ),
            inputDecorationTheme: InputDecorationTheme(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              hintStyle: textTheme.bodyLarge,
            ),
            textTheme: textTheme.apply(
              bodyColor: const Color(0xff2b2b2b),
              displayColor: const Color(0xff2b2b2b),
            ),
            listTileTheme: const ListTileThemeData(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              style: ListTileStyle.list,
              textColor: Color(0xff2b2b2b),
            ),
            primaryTextTheme: textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: textTheme.bodyLarge,
              ),
            ),
          ),

          // Dark Theme
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Colors.lightGreen,
              error: Colors.pink,
              onBackground: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              hintStyle: textTheme.bodyLarge,
            ),
            textTheme: textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            listTileTheme: const ListTileThemeData(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              style: ListTileStyle.list,
              textColor: Colors.white,
            ),
            primaryTextTheme: textTheme.apply(
              bodyColor: const Color(0xff2b2b2b),
              displayColor: const Color(0xff2b2b2b),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: textTheme.bodyLarge,
              ),
            ),
          ),
          routes: {
            "/": (_) => const LoadingScreen(),
            "/landing": (_) => const LandingScreen(),
            "/access": (_) => const AccessScreen(),
            "/login": (_) => const LoginScreens(),
            "/register": (_) => const RegisterScreen(),
            "/main": (_) => const MainScreen(),
            "/chat": (_) => const ChatScreen(),
            "/create_group": (_) => const CreateGroupScreen(),
            "/join_group": (_) => const JoinGroupScreen(),
            "/create_pc": (_) => const CreatePersonalChatScreen(),
            "/change_theme_mode": (_) => const ThemeModeScreen(),
            "/update_account": (_) => const UpdateAccountScreen(),
            "/chat/info": (_) => const InfoGroupScreen(),
            "/show_account": (_) => const ShowAccountScreen(),
            "/chat/info/add": (_) => const AddMembersScreen(),
          },
          initialRoute: "/",
        );
      }),
    );
  }
}