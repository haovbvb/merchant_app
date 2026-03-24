import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../constants/legal_urls.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonWebViewPage(
      initialUrl: userAgreementUrl,
      title: '用户协议',
    );
  }
}
