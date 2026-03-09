import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/sales/rent_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/base_applicant_sheet.dart';

class RentApplicantResult {
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

  const RentApplicantResult({
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

class RentApplicantSheet extends StatelessWidget {
  const RentApplicantSheet({
    super.key,
    required this.notifier,
    required this.advancedMode,
    this.initialCardNum,
  });

  final RentBindNotifier notifier;
  final bool advancedMode;
  final String? initialCardNum;

  static Future<RentApplicantResult?> show(
    BuildContext context,
    RentBindNotifier notifier, {
    required bool advancedMode,
    String? initialCardNum,
  }) async {
    final result = await showModalBottomSheet<ApplicantFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RentApplicantSheet(
        notifier: notifier,
        advancedMode: advancedMode,
        initialCardNum: initialCardNum,
      ),
    );

    if (result == null) return null;
    return RentApplicantResult(
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
        title: l10n.rentBindSelectApplicant,
        userIdHint: l10n.rentBindUserIdHint,
        submit: l10n.rentBindSubmit,
        account: l10n.rentBindAccount,
        firstName: l10n.rentBindFirstName,
        lastName: l10n.rentBindLastName,
        phone: l10n.rentBindPhone,
        nid: l10n.rentBindNid,
        uploadNidPhoto: l10n.rentBindUploadNidPhoto,
        nidPhotoHint: l10n.rentBindNidPhotoHint,
        personalPhoto: l10n.rentBindPersonalPhoto,
        birthday: l10n.rentBindBirthday,
        email: l10n.rentBindEmail,
        emailHint: l10n.rentBindEmailHint,
        address: l10n.rentBindAddress,
        addressHint: l10n.rentBindAddressHint,
      ),
      advancedMode: advancedMode,
      initialCardNum: initialCardNum,
      onQueryUser: notifier.queryUser,
      onUploadCardImage: notifier.uploadCardImage,
    );
  }
}
