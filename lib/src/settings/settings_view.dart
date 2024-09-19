// File: settings_view.dart

import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  final VoidCallback onResetWeek;

  const SettingsView({Key? key, required this.onResetWeek}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Reset Week'),
            subtitle: const Text('Clear all expenses for the current week'),
            trailing: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Reset Week'),
                      content: const Text('Are you sure you want to reset all expenses for this week?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Reset'),
                          onPressed: () {
                            onResetWeek();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }
}