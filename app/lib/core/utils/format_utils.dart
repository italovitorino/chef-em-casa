String formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  final datePart = isoDate.split('T').first;
  final parts = datePart.split('-');
  if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
  return isoDate;
}
