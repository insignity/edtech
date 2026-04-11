mixin EmailValidator {
  static const _pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$";

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email required";
    }

    if (!RegExp(_pattern).hasMatch(value)) {
      return "Invalid email";
    }

    return null;
  }
}
