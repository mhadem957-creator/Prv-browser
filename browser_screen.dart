import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../models/browser_settings.dart';
import '../models/browser_tab.dart';
import '../services/adblock_service.dart';
import '../services/search_service.dart';
import '../widgets/browser_toolbar.dart';
import '../widgets/url_bar.dart';
import 'settings_screen.dart';
import 'tabs_screen.dart';

const String _desktopUserAgent =
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final List<BrowserTab> _tabs = [];
  int _currentIndex = 0;
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  bool _isLoading = false;
  double _progress = 0;

  BrowserTab get _currentTab => _tabs[_currentIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<BrowserSettings>();
      _openNewTab(url: settings.homePage);
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _openNewTab({String? url}) {
    final settings = context.read<BrowserSettings>();
    final tab = BrowserTab(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      url: url ?? settings.homePage,
    );
    setState(() {
      _tabs.add(tab);
      _currentIndex = _tabs.length - 1;
      _urlController.text = tab.url;
    });
  }

  void _closeTab(int index) {
    final settings = context.read<BrowserSettings>();
    if (_tabs.length == 1) {
      // Always keep at least one tab open — reset it instead of closing.
      setState(() {
        _tabs[0] = BrowserTab(id: _tabs[0].id, url: settings.homePage);
        _currentIndex = 0;
        _urlController.text = _tabs[0].url;
      });
      return;
    }
    setState(() {
      _tabs.removeAt(index);
      if (_currentIndex >= _tabs.length) {
        _currentIndex = _tabs.length - 1;
      }
      _urlController.text = _currentTab.url;
    });
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
      _urlController.text = _tabs[index].url;
      _isLoading = false;
      _progress = 0;
    });
  }

  Future<void> _handleSubmitted(String input) async {
    final settings = context.read<BrowserSettings>();
    final searchService = SearchService(settings.searxngUrl);
    final resolved = searchService.resolveInput(input);
    if (resolved.isEmpty) return;

    _urlFocusNode.unfocus();
    final controller = _currentTab.controller;
    if (controller != null) {
      await controller.loadUrl(urlRequest: URLRequest(url: WebUri(resolved)));
    } else {
      setState(() => _currentTab.url = resolved);
    }
  }

  Future<void> _applyContentBlockers(InAppWebViewController controller) async {
    final settings = context.read<BrowserSettings>();
    final blockers = await AdBlockService.instance.buildContentBlockers(
      blockAds: settings.adBlockEnabled,
      blockTrackers: settings.trackerBlockEnabled,
    );
    await controller.setSettings(
      settings: InAppWebViewSettings(contentBlockers: blockers),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: UrlBar(
          controller: _urlController,
          focusNode: _urlFocusNode,
          isSecure: _currentTab.url.startsWith('https://'),
          onSubmitted: _handleSubmitted,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New tab',
            onPressed: () => _openNewTab(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _showSettingsScreen,
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress <= 0 ? null : _progress,
                ),
              )
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (int i = 0; i < _tabs.length; i++) _buildWebViewForTab(i),
        ],
      ),
      bottomNavigationBar: BrowserToolbar(
        onBack: _goBack,
        onForward: _goForward,
        onReload: _reloadOrStop,
        onHome: _goHome,
        isLoading: _isLoading,
        tabCount: _tabs.length,
        onTabsPressed: _showTabsScreen,
      ),
    );
  }

  Widget _buildWebViewForTab(int index) {
    final tab = _tabs[index];
    final settings = context.read<BrowserSettings>();

    return KeyedSubtree(
      key: ValueKey(tab.id),
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(tab.url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: settings.javascriptEnabled,
          cacheEnabled: true,
          supportZoom: true,
          transparentBackground: true,
          mediaPlaybackRequiresUserGesture: true,
          userAgent: settings.desktopMode ? _desktopUserAgent : null,
        ),
        onWebViewCreated: (controller) {
          tab.controller = controller;
          _applyContentBlockers(controller);
        },
        onLoadStart: (controller, url) {
          tab.url = url?.toString() ?? tab.url;
          if (index != _currentIndex) return;
          setState(() {
            _isLoading = true;
            _urlController.text = tab.url;
          });
        },
        onLoadStop: (controller, url) async {
          tab.url = url?.toString() ?? tab.url;
          tab.title = await controller.getTitle() ?? tab.url;
          if (!mounted || index != _currentIndex) return;
          setState(() {
            _isLoading = false;
            _urlController.text = tab.url;
          });
        },
        onProgressChanged: (controller, progress) {
          if (index != _currentIndex) return;
          setState(() => _progress = progress / 100);
        },
        onReceivedError: (controller, request, error) {
          if (index != _currentIndex) return;
          setState(() => _isLoading = false);
        },
        onTitleChanged: (controller, title) {
          if (title != null) tab.title = title;
        },
      ),
    );
  }

  Future<void> _goBack() async {
    final controller = _currentTab.controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
    }
  }

  Future<void> _goForward() async {
    final controller = _currentTab.controller;
    if (controller != null && await controller.canGoForward()) {
      await controller.goForward();
    }
  }

  Future<void> _reloadOrStop() async {
    final controller = _currentTab.controller;
    if (controller == null) return;
    if (_isLoading) {
      await controller.stopLoading();
    } else {
      await controller.reload();
    }
  }

  Future<void> _goHome() async {
    final settings = context.read<BrowserSettings>();
    await _handleSubmitted(settings.homePage);
  }

  void _showTabsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TabsScreen(
          tabs: _tabs,
          currentIndex: _currentIndex,
          onSelect: (i) {
            Navigator.pop(context);
            _switchTab(i);
          },
          onClose: _closeTab,
          onNewTab: () {
            Navigator.pop(context);
            _openNewTab();
          },
        ),
      ),
    );
  }

  void _showSettingsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}
