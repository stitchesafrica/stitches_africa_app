import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:stitches_africa/constants/utilities.dart';

class TransactionTileWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const TransactionTileWidget({super.key, required this.transaction});

  String formatDate(String dateTimeString) {
    // Parse the input string into a DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Format the DateTime object into the desired format
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  Widget getTransactionTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return SvgPicture.asset(
          'assets/icons/money-deposit.svg',
          height: 24.h,
          color: Utilities.primaryColor,
        );
      case 'withdraw':
        return SvgPicture.asset(
          'assets/icons/money-withdraw.svg',
          height: 20.h,
          color: Utilities.secondaryColor,
        );
      case 'commission':
        return SvgPicture.asset(
          'assets/icons/money-withdraw.svg',
          height: 20.h,
          color: Utilities.secondaryColor,
        );
      default:
        return const Icon(Icons.money_off);
    }
  }

  String getTransactionAmount(String type, double amount) {
    String amountStr = amount.toStringAsFixed(2);
    switch (type.toLowerCase()) {
      case 'payment':
        return '+ $amountStr';
      case 'withdraw':
        return '- $amountStr';
      case 'commission':
        return '- $amountStr';
      default:
        return '0.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: getTransactionTypeIcon(transaction['type']),
      title: Text(
        transaction['type'],
        style: TextStyle(
            fontSize: 14.sp,
            color: Utilities.primaryColor,
            fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        formatDate(transaction['date']),
        style: TextStyle(fontSize: 12.spMin, color: Utilities.secondaryColor),
      ),
      trailing: Text(
        '${getTransactionAmount(transaction['type'], transaction['amount'])} USD',
        style: TextStyle(
            fontSize: 14.spMin,
            color: transaction['type'].toLowerCase() == 'payment'
                ? Utilities.primaryColor
                : Utilities.secondaryColor),
      ),
    );
  }
}
