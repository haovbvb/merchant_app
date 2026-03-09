import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/sales/sell_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/base_applicant_sheet.dart';

class ApplicantResult {
  final String cardNum;
  final String firstName;
  final String lastName;
  final String phone;
  final String idNumber;
  final String birthday;
  final String email;
  final String address;
  final String? cardImgUrl;
  final String? personImgUrl;

  const ApplicantResult({
    required this.cardNum,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.idNumber,
    required this.birthday,
    required this.email,
    required this.address,
    this.cardImgUrl,
    this.personImgUrl,
  });
}

class ApplicantSheet extends StatelessWidget {
  const ApplicantSheet({
    super.key,
    required this.notifier,
    required this.advancedMode,
    this.initialCardNum,
  });

  final SellBindNotifier notifier;
  final bool advancedMode;
  final String? initialCardNum;

  static Future<ApplicantResult?> show(
    BuildContext context,
    SellBindNotifier notifier,
    bool advancedMode, {
    String? initialCardNum,
  }) async {
    final result = await showModalBottomSheet<ApplicantFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApplicantSheet(
        notifier: notifier,
        advancedMode: advancedMode,
        initialCardNum: initialCardNum,
      ),
    );

    if (result == null) return null;
    return ApplicantResult(
      cardNum: result.cardNum,
      firstName: result.firstName,
      lastName: result.lastName,
      phone: result.phone,
      idNumber: result.idNumber,
      birthday: result.birthday,
      email: result.email,
      address: result.address,
      cardImgUrl: result.cardImgUrl,
      personImgUrl: result.personImgUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BaseApplicantSheet(
      texts: ApplicantSheetTexts(
        title: l10n.sellBindSelectApplicant,
        userIdHint: l10n.sellBindUserIdHint,
        submit: l10n.sellBindSubmit,
        account: l10n.sellBindAccount,
        firstName: l10n.sellBindFirstName,
        lastName: l10n.sellBindLastName,
        phone: l10n.sellBindPhone,
        nid: l10n.sellBindNid,
        uploadNidPhoto: l10n.sellBindUploadNidPhoto,
        nidPhotoHint: l10n.sellBindNidPhotoHint,
        personalPhoto: l10n.sellBindPersonalPhoto,
        birthday: l10n.sellBindBirthday,
        email: l10n.sellBindEmail,
        emailHint: l10n.sellBindEmailHint,
        address: l10n.sellBindAddress,
        addressHint: l10n.sellBindAddressHint,
      ),
      advancedMode: advancedMode,
      initialCardNum: initialCardNum,
      onQueryUser: notifier.queryUser,
      onUploadCardImage: notifier.uploadCardImage,
    );
  }
}
