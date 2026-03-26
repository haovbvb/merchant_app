import 'package:design_system/design_system.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

import 'presentation/about_page.dart';
import 'presentation/change_password_page.dart';
import 'presentation/language_page.dart';
import 'presentation/message_page.dart';
import 'presentation/privacy_policy_page.dart';
import 'presentation/service_agreement_page.dart';
import 'presentation/user_agreement_page.dart';
import 'profile_feature_contract.dart';
import 'profile_route_paths.dart';

class ProfileFeatureModule {
  ProfileFeatureModule();

  final ProfileFeatureContract contract = ProfileFeatureContract(
    publicPaths: const {
      ProfileRoutePaths.userAgreement,
      ProfileRoutePaths.privacyPolicy,
      ProfileRoutePaths.serviceAgreement,
    },
    routes: [
      GoRoute(
        path: ProfileRoutePaths.userAgreement,
        builder: (context, state) => const UserAgreementPage(),
      ),
      GoRoute(
        path: ProfileRoutePaths.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: ProfileRoutePaths.serviceAgreement,
        builder: (context, state) => const ServiceAgreementPage(),
      ),
      GoRoute(
        path: ProfileRoutePaths.about,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: ProfileRoutePaths.messages,
        builder: (context, state) => const MessagePage(),
      ),
      GoRoute(
        path: ProfileRoutePaths.messageDetail,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final initialUrl = query['url'] ?? '';
          final title = query['title'] ?? context.l10n.messageDetail;
          return CommonWebViewPage(initialUrl: initialUrl, title: title);
        },
      ),
      GoRoute(
        path: ProfileRoutePaths.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: ProfileRoutePaths.language,
        builder: (context, state) => const LanguageSelectionPage(),
      ),
    ],
  );
}
