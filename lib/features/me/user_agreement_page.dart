import 'package:flutter/material.dart';
import 'package:merchant_app/core/constants/legal_urls.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/widgets/common_webview_page.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonWebViewPage(
      initialUrl: userAgreementUrl,
      title: context.l10n.profileUserAgreement,
    );
  }
}
