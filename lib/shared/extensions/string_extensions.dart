extension StringX on String {
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String get titleCase {
    return split(' ').map((w) => w.capitalized).join(' ');
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(trim());
  }
}
