import 'package:intl/intl.dart';

class Utils {
  static const String APP_VERSION = '1.0.0';

  static String formatDate(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

}