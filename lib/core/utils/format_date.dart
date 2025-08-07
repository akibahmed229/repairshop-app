import 'package:intl/intl.dart';

String formatDateByMMMYYYY(DateTime dateTime) {
  return DateFormat("d MMM, yyyy").format(dateTime);
}
