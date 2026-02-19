import 'package:intl/intl.dart';

class Utils {
  static const String APP_VERSION = '1.0.0';

  static String formatDate(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  static String getSquadName(int squadId) {
    switch(squadId){
      case 1:
        return 'General';
      case 2:
        return 'Sub-General';
      case 3:
        return 'Galonista G.';
      case 4:
        return 'Galonista G.';
      case 5:
        return 'Comandante';
      case 6:
        return 'Sub-Comandante';
      case 7:
        return 'Galonista';
      case 8:
        return 'Integrante';
      default:
        return '';
    }
  }

  static bool isGeneralPerfil(int position) {
    return [1,2,3,4].contains(position);
  }

}