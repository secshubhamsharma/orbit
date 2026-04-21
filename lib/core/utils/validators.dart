import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.emailRequired;
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(value.trim())) return AppStrings.emailInvalid;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < 8) return AppStrings.passwordTooShort;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value != original) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.nameRequired;
    return null;
  }
}
