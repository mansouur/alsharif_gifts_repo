import 'package:intl/intl.dart';

final _fmt = NumberFormat('#,##0', 'en_US');

String formatPrice(double amount) => '${_fmt.format(amount)} ل.س';
