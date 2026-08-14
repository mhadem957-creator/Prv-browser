import 'package:flutter/material.dart';

import '../models/browser_tab.dart';

/// Simple tab manager: lists open tabs, lets the user switch, close, or
/// open a new one.
class TabsScreen extends StatelessWidget {
  const TabsScreen({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onSelect,
    required this.onClose,
    required this.onNewTab,
  });

  final List<BrowserTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onClose;
  final VoidCallback onNewTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${tabs.length} ${tabs.length == 1 ? 'Tab' : 'Tabs'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New tab',
            onPressed: onNewTab,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isCurrent = index == currentIndex;
          return Card(
            color: isCurrent
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.public),
              title: Text(
                tab.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                tab.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close tab',
                onPressed: () => onClose(index),
              ),
              onTap: () => onSelect(index),
            ),
          );
        },
      ),
    );
  }
}
