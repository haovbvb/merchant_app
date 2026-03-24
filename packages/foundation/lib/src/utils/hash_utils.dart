import 'dart:convert';

import 'package:crypto/crypto.dart';

class HashUtils {
  const HashUtils._();

  static String md5Lower32(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
