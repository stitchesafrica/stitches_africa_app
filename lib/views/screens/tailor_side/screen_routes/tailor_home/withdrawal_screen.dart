import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:stitches_africa/config/providers/withdrawal_provider/payment_method_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/api/price_model.dart';
import 'package:stitches_africa/services/api_service/price_api_service.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_home/request_withdrawal.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  final double walletBalance;
  const WithdrawalScreen({super.key, required this.walletBalance});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final FocusNode focusNode1 = FocusNode();
  final TextEditingController amountController = TextEditingController();
  final priceService = PriceServiceApi();

  double amount = 0.0;
  String? amountError;

  bool _validateFields() {
    setState(() {
      amountError =
          _validateWithdrawalAmount(double.parse(amountController.text))
              ? 'Must be between 1.00 - ${widget.walletBalance} USD'
              : null;
    });
    return amountError == null;
  }

  bool _validateWithdrawalAmount(double amount) {
    return amount >= widget.walletBalance;
  }

  Future<Price> fetchPrice(BuildContext context) async {
    try {
      final price = await priceService.getForexPrice('USD', 'NGN');
      return price;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> convertToNGN(BuildContext context, double totalPrice) async {
    final Price priceModel = await fetchPrice(context);
    final double price = priceModel.currencyExchangeRate * (totalPrice);

    return price;
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

  @override
  Widget build(BuildContext context) {
    final paymentMethod = ref.watch(paymentMethodProvider);
    double amount = ref.watch(amountProvider);
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Transform.flip(
            flipX: true,
            child: const Icon(
              FluentSystemIcons.ic_fluent_dismiss_filled,
            ),
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
                  'WITHDRAWAL',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 50.h,
                ),
                Text('Your Wallet',
                    style: TextStyle(
                        //fontFamily: 'Montserrat',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Utilities.secondaryColor)),
                Row(
                  children: [
                    Text(
                      widget.walletBalance.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      'USD',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: Utilities.secondaryColor),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Utilities.secondaryColor,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                          controller: amountController,
                          focusNode: focusNode1,
                          hintText: '',
                          fontSize: 24.sp,
                          obscureText: false,
                          errorText: amountError,
                          textType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onSubmitted: (value) {
                            if (_validateFields()) {
                              ref.read(amountProvider.notifier).state =
                                  double.parse(value);
                            }
                          }),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      'USD',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50.h,
                ),
                Text(
                  'To be withdrawn',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Utilities.secondaryColor,
                  ),
                ),
                SizedBox(
                  height: 10.h,
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
                  child: FutureBuilder(
                      future: convertToNGN(context, amount),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('...');
                        } else if (snapshot.hasError) {
                          return const Text('Error converting price');
                        }
                        amount = snapshot.data!;
                        return RichText(
                            text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Utilities.primaryColor,
                                ),
                                children: [
                              TextSpan(text: formatAmount(amount.round())),
                              TextSpan(
                                  text: '.00 NGN',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500))
                            ]));
                      }),
                ),
                SizedBox(
                  height: 20.h,
                ),
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
            text: 'Continue',
            onTap: () async {
              if (_validateFields()) {
                print(amount.round());
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RequestWithdrawal(withdrawAmount: amount.round());
                }));
              }
            }),
      ),
    );
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Utilities.secondaryColor2,
      nextFocus: true,
      actions: [
        KeyboardActionsItem(focusNode: focusNode1, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () {
                if (_validateFields()) {
                  ref.read(amountProvider.notifier).state =
                      double.parse(amountController.text);
                }
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
