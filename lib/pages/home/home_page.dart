import 'package:flutter/material.dart';
import 'package:simple_mqtt/pages/home/sub/messages_page.dart';
import 'package:simple_mqtt/pages/home/sub/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageIndex = ValueNotifier<int>(0);

    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: pageIndex,
        builder: (context, index, __) {
          return IndexedStack(
            index: index,
            children: const [
              MessagesPage(),
              SettingsPage(),
            ],
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: pageIndex,
        builder: (context, index, __) {
          return BottomNavigationBar(
            currentIndex: index,
            onTap: (value) => pageIndex.value = value,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: "Messages",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
          );
        },
      ),
    );
  }
}
