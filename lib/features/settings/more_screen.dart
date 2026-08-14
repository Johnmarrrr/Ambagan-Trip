import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export All Data'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('App Theme'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
