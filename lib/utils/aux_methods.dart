class AuxMethods {
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  bool isToday(DateTime date) {
    final DateTime today = DateTime.now();
    if (date.year == today.year && date.month == today.month && date.day == today.day) return true;
    return false;
  }
}