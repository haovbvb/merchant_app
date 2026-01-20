import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PromoteWebPage extends StatefulWidget {
  const PromoteWebPage({super.key});

  @override
  State<PromoteWebPage> createState() => _PromoteWebPageState();
}

class _PromoteWebPageState extends State<PromoteWebPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isParse = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.promoteWebTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: l10n.promoteWebUrlLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(l10n.promoteWebParseMode),
            value: _isParse,
            onChanged: (value) => setState(() => _isParse = value),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _openWebView,
            child: Text(l10n.promoteWebOpen),
          ),
        ],
      ),
    );
  }

  Future<void> _openWebView() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PromoteWebView(
          url: url,
          parseMode: _isParse,
        ),
      ),
    );
  }
}

class _PromoteWebView extends StatefulWidget {
  const _PromoteWebView({required this.url, required this.parseMode});

  final String url;
  final bool parseMode;

  @override
  State<_PromoteWebView> createState() => _PromoteWebViewState();
}

class _PromoteWebViewState extends State<_PromoteWebView> {
  late final WebViewController _controller;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) => setState(() => _progress = value / 100),
        ),
      )
      ..addJavaScriptChannel(
        'java_obj',
        onMessageReceived: (message) {
          if (widget.parseMode) {
            Navigator.of(context).pop(message.message);
          }
        },
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
