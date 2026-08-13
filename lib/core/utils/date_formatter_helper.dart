class DateFormatterHelper {
  const DateFormatterHelper._();

  static String formatRelative(DateTime date) {
    final today = DateTime.now();

    final now = DateTime(today.year, today.month, today.day);

    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(now).inDays;

    switch (difference) {
      case 0:
        return 'Today';

      case 1:
        return 'Tomorrow';

      default:
        if (difference > 1 && difference <= 7) {
          return 'In $difference days';
        }

        return _formatDate(target);
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }
}
