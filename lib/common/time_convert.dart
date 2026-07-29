import 'package:intl/intl.dart';

String timeConvert(date) {
  try {
    DateTime parseDate = DateFormat('yyyy-MM-dd HH:mm:ss', 'id').parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat.Hm('id');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  } catch (e) {
    return '';
  }
}

String dateConvert(date) {
  try {
    DateTime parseDate = DateFormat('yyyy-MM-dd HH:mm:ss', 'id').parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat.yMMMMd('id');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  } catch (e) {
    return '';
  }
}

String dateConvertWithT(date) {
  try {
    // DateTime parseDate = DateFormat('yyyy-MM-ddHH:mm:ss', 'id').parse(date);
    var inputDate = DateTime.parse(date.toString());
    var outputFormat = DateFormat.yMMMMd('id');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  } catch (e) {
    return '';
  }
}

String timeConvertWithT(date) {
  try {
    var inputDate = DateTime.parse(date.toString());
    var outputFormat = DateFormat.Hm('id');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  } catch (e) {
    return '';
  }
}

String formatToIndonesianDateNextDay(String isoString) {
  try {
    // Parse ISO string ke DateTime
    DateTime dateTime = DateTime.parse(isoString);

    // Tambahkan satu hari
    dateTime = dateTime.add(const Duration(days: 1));

    // Format ke bahasa Indonesia
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(dateTime);
  } catch (e) {
    return '';
  }
}
