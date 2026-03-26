import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

import '../constants/legal_urls.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonWebViewPage(
      initialUrl: userAgreementUrl,
      title: context.l10n.userAgreement,
    );
  }
}
