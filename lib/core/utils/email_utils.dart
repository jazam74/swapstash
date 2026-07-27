import 'package:flutter/services.dart';

final RegExp _emailWhitespaceAndInvisibleCharacters = RegExp(
  r'[\s\u00A0\u200B\u200C\u200D\u2060\uFEFF]',
);

final RegExp _basicEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String normalizeEmailAddress(String value) {
  return value
      .replaceAll(_emailWhitespaceAndInvisibleCharacters, '')
      .trim()
      .toLowerCase();
}

bool isValidEmailAddress(String value) {
  return _basicEmailPattern.hasMatch(normalizeEmailAddress(value));
}

TextInputFormatter get emailInputFormatter {
  return FilteringTextInputFormatter.deny(
    _emailWhitespaceAndInvisibleCharacters,
  );
}
