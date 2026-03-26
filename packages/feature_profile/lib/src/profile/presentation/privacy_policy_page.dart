import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

import '../constants/legal_urls.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonWebViewPage(
      initialUrl: privacyPolicyUrl,
      title: context.l10n.privacyPolicy,
    );
  }
}
