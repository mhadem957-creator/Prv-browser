import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/browser_settings.dart';
import '../services/storage_service.dart';
import '../services/system_settings_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _searxController;
  late final TextEditingController _homeController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<BrowserSettings>();
    _searxController = TextEditingController(text: settings.searxngUrl);
    _homeController = TextEditingController(text: settings.homePage);
  }

  @override
  void dispose() {
    _searxController.dispose();
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<BrowserSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader('Search'),
          TextField(
            controller: _searxController,
            decoration: const InputDecoration(
              labelText: 'SearXNG search URL',
              helperText:
                  'Full endpoint ending at the query param, e.g.\n'
                  'https://your-instance.example/search?q=',
              helperMaxLines: 2,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => settings.updateSearxngUrl(v),
            onEditingComplete: () => settings.updateSearxngUrl(_searxController.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _homeController,
            decoration: const InputDecoration(
              labelText: 'Home page',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => settings.updateHomePage(v),
            onEditingComplete: () => settings.updateHomePage(_homeController.text),
          ),
          const SizedBox(height: 24),
          const _SectionHeader('Secure DNS (DNS-over-HTTPS)'),
          SwitchListTile(
            title: const Text('Use DoH for address-bar lookups'),
            subtitle: const Text(
              'Pre-resolves typed domains securely before navigation',
            ),
            value: settings.dohEnabled,
            onChanged: settings.toggleDoh,
          ),
          DropdownButtonFormField<String>(
            value: settings.dohProviderUrl,
            decoration: const InputDecoration(
              labelText: 'DoH provider',
              border: OutlineInputBorder(),
            ),
            items: AppConstants.dohProviders
                .map(
                  (p) => DropdownMenuItem<String>(
                    value: p['url'],
                    child: Text(p['name']!),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) settings.updateDohProvider(value);
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.dns_outlined),
            label: const Text('Open system Private DNS settings'),
            onPressed: SystemSettingsService.openPrivateDnsSettings,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Android WebView uses the device network stack, so this app '
              "can't force secure DNS onto pages by itself. For secure DNS "
              'to apply to everything you browse, enable Private DNS at the '
              'system level (Android 9+) using the button above.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader('Privacy & Blocking'),
          SwitchListTile(
            title: const Text('Block ads'),
            value: settings.adBlockEnabled,
            onChanged: settings.toggleAdBlock,
          ),
          SwitchListTile(
            title: const Text('Block trackers'),
            value: settings.trackerBlockEnabled,
            onChanged: settings.toggleTrackerBlock,
          ),
          SwitchListTile(
            title: const Text('Enable JavaScript'),
            value: settings.javascriptEnabled,
            onChanged: settings.toggleJavascript,
          ),
          SwitchListTile(
            title: const Text('Request desktop site by default'),
            value: settings.desktopMode,
            onChanged: settings.toggleDesktopMode,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              'Reopen a tab (or reload) after changing blocking/JavaScript '
              'toggles for them to take effect on that page.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Data'),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear cookies, cache & browsing data'),
            onPressed: () async {
              await StorageService.clearAllBrowsingData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Browsing data cleared')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
