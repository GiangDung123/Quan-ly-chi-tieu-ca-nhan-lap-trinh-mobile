class Validators {
  static String? validateEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống';
    }
    return null;
  }
}
