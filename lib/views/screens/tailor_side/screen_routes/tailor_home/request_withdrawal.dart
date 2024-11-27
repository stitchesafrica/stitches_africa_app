// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:stitches_africa/config/providers/withdrawal_provider/bank_list_provider.dart';
import 'package:stitches_africa/config/providers/withdrawal_provider/payment_method_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/api/paystack_models/single_transfer_model.dart';
import 'package:stitches_africa/models/api/paystack_models/transfer_receipent_model.dart';
import 'package:stitches_africa/models/api/paystack_models/verified_account_model.dart';
import 'package:stitches_africa/services/api_service/paystack_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/bank_list_pop_up.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:toastification/toastification.dart';

class RequestWithdrawal extends ConsumerStatefulWidget {
  final int withdrawAmount;

  const RequestWithdrawal({super.key, required this.withdrawAmount});

  @override
  ConsumerState<RequestWithdrawal> createState() => _RequestWithdrawalState();
}

class _RequestWithdrawalState extends ConsumerState<RequestWithdrawal> {
  final FocusNode focusNode1 = FocusNode();
  // Controllers
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  // Services
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification _showToasitification = ShowToasitification();
  final PaystackApiService _paystackApiService = PaystackApiService();

  late String invoiceId;

  bool _verifiedStatus = false;

  /// Generates a unique invoice ID
  String _generateInvoiceId() {
    final DateTime now = DateTime.now();
    final Random random = Random();

    final String datePart =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final String randomPart = random.nextInt(999999).toString().padLeft(6, '0');

    return "INV-$datePart-$randomPart";
  }

  /// Validates the account number field
  bool _validateFields() {
    return _accountNumberController.text.length == 10;
  }

  String formatAmount(int value) {
    // Create a formatter with space as the grouping separator
    final formatter = NumberFormat.currency(
      locale: 'en',
      symbol: '', // No currency symbol
      decimalDigits: 0, // No decimal places
      customPattern: '#,##0', // Group by three digits without decimals
    );

    // Replace default commas with spaces
    return formatter.format(value).replaceAll(',', ' ');
  }

  /// Generates a unique payment reference
  String _getReference() {
    final String platform = Platform.isIOS ? "iOS" : "Android";
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Gets the current logged-in user's ID
  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  /// Displays a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Utilities.backgroundColor),
      ),
    );
  }

  Future<void> _handleWithdrawal(String bankCode, String bankName) async {
    if (_verifiedStatus) {
      _showLoadingDialog(context);

      try {
        final String accountName = _accountNameController.text;
        final String accountNumber = _accountNumberController.text;

        // Create transfer recipient
        TransferReceipentModel transferReceipentModel =
            await _paystackApiService.createTransferRecipient(
          accountName,
          accountNumber,
          bankCode,
        );

        // Initiate transfer
        final String referenceCode = _getReference();
        final String recipientCode = transferReceipentModel.recepientCode;

        SingleTransferModel singleTransferModel =
            await _paystackApiService.initiateTransfer(
          widget.withdrawAmount * 100,
          referenceCode,
          recipientCode,
        );

        Navigator.pop(context); // Dismiss the loading dialog

        if (singleTransferModel.status) {
          // Record the transaction
          final transaction = {
            'invoice_id': invoiceId,
            'transaction_id': singleTransferModel.transferCode,
            'date': DateTime.now().toIso8601String(),
            'tailor_id': _getCurrentUserId(),
            'currency': 'NGN',
            'amount': ref.read(amountProvider),
            'bank_name': bankName,
            'bank_account_number': accountNumber,
            'account_holder_name': accountName,
            'bank_code': bankCode,
            'type': 'Withdraw',
            'reference': singleTransferModel.reference,
            'status': 'Success',
            'description': "Withdrawal",
          };
          // update user transaction history
          await _firebaseFirestoreFunctions.updateTransactions(
            _getCurrentUserId(),
            [transaction],
          );

          //update user wallet balance
          await _firebaseFirestoreFunctions.deductFromWalletBalance(
            _getCurrentUserId(),
            ref.read(amountProvider),
          );

          //reset amount provider
          ref.invalidate(amountProvider);

          // go to home
          context.goNamed('tailorHome');

          _showToasitification.showToast(
            context: context,
            toastificationType: ToastificationType.success,
            title: 'Withdrawal initiated successfully',
          );
        } else {
          throw Exception('Failed to initiate withdrawal');
        }
      } catch (e) {
        Navigator.pop(context); // Dismiss the loading dialog
        _showToasitification.showToast(
          context: context,
          toastificationType: ToastificationType.error,
          title: 'Error: $e',
        );
      }
    } else if (_validateFields()) {
      // Handle account verification
      _showLoadingDialog(context);

      try {
        VerifiedAccountModel verifiedAccountModel =
            await _paystackApiService.verifyAccount(
          _accountNumberController.text,
          bankCode,
        );

        Navigator.pop(context); // Dismiss the loading dialog

        setState(() {
          _verifiedStatus = verifiedAccountModel.status;
          _accountNameController.text = verifiedAccountModel.accountName;
        });
      } catch (e) {
        Navigator.pop(context); // Dismiss the loading dialog
        _showToasitification.showToast(
          context: context,
          toastificationType: ToastificationType.error,
          title: 'Error verifying account: $e',
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    invoiceId = _generateInvoiceId();
  }

  @override
  Widget build(BuildContext context) {
    final String bankName = ref.watch(selectedBankProvider);
    final String bankCode = ref.watch(selectedBankCodeProvider);

    _bankNameController.text = bankName;

    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Transform.flip(
            flipX: true,
            child: const Icon(FluentSystemIcons.ic_fluent_dismiss_filled),
          ),
        ),
      ),
      body: KeyboardActions(
        config: _buildConfig(context),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Text(
                  'Invoice ID: $invoiceId',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Utilities.secondaryColor,
                  ),
                ),
                Text(
                  'REQUEST WITHDRAWAL',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildLabel('Bank Name'),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: _bankNameController,
                        hintText: '',
                        obscureText: false,
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    BankListPopUp(selectedBank: bankName),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildLabel('Account Number'),
                MyTextField(
                  controller: _accountNumberController,
                  focusNode: focusNode1,
                  hintText: '',
                  obscureText: false,
                  maxLength: 10,
                  textType: TextInputType.number,
                ),
                _verifiedStatus
                    ? _buildAccountNameWidget()
                    : const SizedBox.shrink(),
                SizedBox(
                  height: 50.h,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.h,
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: Utilities.secondaryColor2.withOpacity(0.4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(
                        'Amount to be received',
                        fontSize: 13.spMin,
                      ),
                      Text(
                        '${formatAmount(widget.withdrawAmount)}.00 NGN',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Utilities.primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75.w,
                            child: const Divider(
                              thickness: 0.5,
                              color: Utilities.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        'Invoice ID',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Utilities.secondaryColor,
                        ),
                      ),
                      Text(
                        invoiceId,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Utilities.primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40.h,
        elevation: 0,
        color: Utilities.backgroundColor,
        padding: EdgeInsets.zero,
        child: Button(
          border: false,
          text: _verifiedStatus ? 'Confirm' : 'Verify Account',
          onTap: () => _handleWithdrawal(bankCode, bankName),
        ),
      ),
    );
  }

  /// Builds a label for input fields
  Widget _buildLabel(String label, {double? fontSize}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize ?? 14.sp,
        color: Utilities.secondaryColor,
      ),
    );
  }

  /// Builds the account name widget
  Widget _buildAccountNameWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        _buildLabel('Account Name'),
        MyTextField(
          controller: _accountNameController,
          hintText: '',
          obscureText: false,
          readOnly: true,
        ),
      ],
    );
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Utilities.secondaryColor2,
      nextFocus: true,
      actions: [
        KeyboardActionsItem(focusNode: focusNode1, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () {
                node.unfocus();
              },
              child: Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: const Text(
                  'Done',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.blue),
                ),
              ),
            );
          }
        ])
      ],
    );
  }
}
