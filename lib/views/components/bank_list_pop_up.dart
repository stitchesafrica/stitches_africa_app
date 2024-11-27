import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/withdrawal_provider/bank_list_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/api/paystack_models/bank_list_model.dart';
import 'package:stitches_africa/services/api_service/paystack_api_service.dart';

class BankListPopUp extends ConsumerStatefulWidget {
  final String selectedBank;
  const BankListPopUp({super.key, required this.selectedBank});

  @override
  ConsumerState<BankListPopUp> createState() => _BankListPopUpState();
}

class _BankListPopUpState extends ConsumerState<BankListPopUp> {
  final PaystackApiService _paystackApiService = PaystackApiService();
  List<Bank> _banks = [];

  @override
  void initState() {
    super.initState();
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    try {
      final BankListModel bankList = await _paystackApiService.getBankList();
      setState(() {
        _banks = bankList.banks;
      });
    } catch (e) {
      // Handle error
      if (kDebugMode) {
        print('Error fetching banks: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Utilities.backgroundColor,
      surfaceTintColor: Utilities.backgroundColor,
      icon: const Icon(
        FluentSystemIcons.ic_fluent_chevron_down_filled,
        size: 18,
      ),
      onSelected: (value) {
        ref.read(selectedBankProvider.notifier).state = value;
      },
      itemBuilder: (context) {
        if (_banks.isEmpty) {
          return [
            const PopupMenuItem(
              value: 'loading',
              child: Text('Loading...'),
            ),
          ];
        }
        return _banks.map((bank) {
          return PopupMenuItem<String>(
            value: bank.bankName,
            onTap: () {
              ref.read(selectedBankCodeProvider.notifier).state = bank.bankCode;
            },
            child: _buildPopupMenuItem(bank.bankName),
          );
        }).toList();
      },
    );
  }

  Widget _buildPopupMenuItem(String bankName) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: widget.selectedBank == bankName
            ? Utilities.primaryColor
            : Utilities.backgroundColor,
        borderRadius: BorderRadius.circular(0.r),
      ),
      child: Text(
        bankName,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 14.spMin,
          color: widget.selectedBank == bankName
              ? Utilities.backgroundColor
              : Utilities.primaryColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
