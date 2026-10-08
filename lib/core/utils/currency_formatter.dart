import 'package:intl/intl.dart';
import 'package:patakha_khata/core/constants/app_strings.dart';

abstract final class CurrencyFormatter {
  static final _format = NumberFormat.currency(
    locale: 'en_PK',
    symbol: AppStrings.rupee,
    decimalDigits: 0,
  );

  static String format(num amount) => _format.format(amount);
}
