import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:stitches_africa/models/firebase_models/tailor_side/tailor_model.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:flutter/material.dart';

import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_home/future_or_stream_widget/transaction_tile_widget.dart';

class TransactionHistoryStreamWidget extends StatelessWidget {
  final Stream<TailorModel> getTailorStream;
  const TransactionHistoryStreamWidget({
    super.key,
    required this.getTailorStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getTailorStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Utilities.backgroundColor));
          } else if (snapshot.hasError) {
            if (Platform.isIOS) {
              return IOSAlertDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.${snapshot.error}',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () {
                    Navigator.pop(context);
                  },
                  isDefaultAction1: true,
                  isDestructiveAction1: false);
            } else {
              return AndriodAleartDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () {
                    Navigator.pop(context);
                  });
            }
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text(
              'No address saved',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ));
          }
          final tailorData = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: tailorData.transactionHistory.length,
                      itemBuilder: (context, index) {
                        final transaction =
                            tailorData.transactionHistory[index];
                        return TransactionTileWidget(transaction: transaction);
                      }))
            ],
          );
        });
  }
}
