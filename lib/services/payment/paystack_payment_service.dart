// ignore_for_file: unused_import

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stitches_africa/models/api/logistics/terminal_africa_models/create_shipment_model.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/services/api_service/logistics/terminal_africa_api_service.dart';
import 'package:stitches_africa/services/api_service/notifications/one_signal_api.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';

class PaystackPaymentServices {
  final BuildContext context;

  final String publicKey;
  final String? userEmail;
  final String countryCode;
  final int price;
  final Map<String, dynamic>? selectedAddress;
  final String deliveryDate;

  PaystackPaymentServices({
    required this.context,
    required this.publicKey,
    required this.countryCode,
    this.userEmail,
    required this.price,
    this.selectedAddress,
    required this.deliveryDate,
  });
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final TerminalAfricaApiService _terminalApiService =
      TerminalAfricaApiService();
  final OneSignalApi _oneSignalApi = OneSignalApi();
  Map<String, double> tailorPayments = {};
  String orderId = '';

  PaystackPlugin plugin = PaystackPlugin();
  Future initializePlugin() async {
    await plugin.initialize(publicKey: publicKey);
  }

  String generateOrderId() {
    const length = 7;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  String generateTransactionId() {
    final DateTime now = DateTime.now();
    final Random random = Random();

    // Use a timestamp and random number to ensure uniqueness
    final String timestamp = now.millisecondsSinceEpoch.toString();
    final String randomNumber =
        random.nextInt(999999).toString().padLeft(6, '0');

    return 'TRX_${timestamp}_$randomNumber';
  }

  String generateCommissionId() {
    final DateTime now = DateTime.now();
    final Random random = Random();

    // Use a timestamp and random number to ensure uniqueness
    final String timestamp = now.millisecondsSinceEpoch.toString();
    final String randomNumber =
        random.nextInt(999999).toString().padLeft(6, '0');

    return 'COM_${timestamp}_$randomNumber';
  }

  Future<CreateShipmentModel> _createShipment() async {
    final shippingData =
        await firebaseFirestoreFunctions.getShippingDetails(getCurrentUserId());
    final createShipmentModel = await _terminalApiService.createShipment(
      pickUpAddressId: shippingData!['pickup_address_id'],
      deliveryAddressId: shippingData['delivery_address_id'],
      parcelId: shippingData['parcel_id'],
      addressReturnId: shippingData['pickup_address_id'],
    );
    return createShipmentModel;
  }

  Future<void> _arrangePickup(CreateShipmentModel shipmentModel) async {
    final shippingData =
        await firebaseFirestoreFunctions.getShippingDetails(getCurrentUserId());
    await _terminalApiService.arrangePickup(
      rateId: shippingData!['rate_id'],
      shipmentId: shipmentModel.shipmentId,
    );
  }

  void trackOrderConfirmation(String orderId) async {
    await OneSignal.User.addTags({
      "last_action": "purchased",
      "order_id": orderId,
      "order_date": DateTime.now().toIso8601String(),
    });
    print("Order confirmation tags added");
  }

  Future<Map<String, dynamic>> getUserAddressesOnce() async {
    List<AddressModel> addresses = await FirebaseFirestore.instance
        .collection('users_addresses')
        .doc(getCurrentUserId())
        .collection('user_addresses')
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromDocument(doc.data()))
            .toList());

    return addresses.first.toMap();
  }

  Future<void> updateTailorPayments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(_getCurrentUserId())
        .collection('user_cart_items')
        .get();

    List<QueryDocumentSnapshot> cartItems = querySnapshot.docs;

    for (QueryDocumentSnapshot item in cartItems) {
      final Map<String, dynamic> data = item.data() as Map<String, dynamic>;
      String tailorId = data['id'];
      double price = data['price'];
      int quantity = data['quantity'];
      if (tailorPayments.containsKey(tailorId)) {
        tailorPayments[tailorId] =
            (tailorPayments[tailorId] ?? 0) + price * quantity;
      } else {
        tailorPayments[tailorId] = price * quantity;
      }
    }
  }

  Future<void> updateTailorWallet() async {
    for (var entry in tailorPayments.entries) {
      String tailorId = entry.key;
      double amount = (entry.value) * 0.80; //tailor's commission

      //update wallet
      await firebaseFirestoreFunctions.addToWalletBalance(tailorId, amount);
    }
  }

  Future<void> updateTailorTransaction() async {
    for (var entry in tailorPayments.entries) {
      String tailorId = entry.key;
      double amount = entry.value;

      final transactionId = generateTransactionId();
      final commissionId = generateCommissionId();

      final List<Map<String, dynamic>> transactions = [
        {
          'transaction_id': transactionId,
          'date': DateTime.now().toIso8601String(),
          'amount': amount,
          'type': 'Payment',
          'status': 'Success',
          'description': "Payment for order #$orderId",
        },
        {
          'transaction_id': commissionId,
          'date': DateTime.now().toIso8601String(),
          'amount': amount * 0.20,
          'related_transaction_id': transactionId,
          'type': 'Commission',
          'status': 'Success',
          'description': "Commission deducted for platform services",
        }
      ];

      //update transactions
      await firebaseFirestoreFunctions.updateTransactions(
          tailorId, transactions);
    }
  }

  /// Creates an order for the current user by transferring items from the cart to the orders collection.
  Future<void> createUserOrder() async {
    try {
      // References for the order and cart collections
      final CollectionReference orderCollection = FirebaseFirestore.instance
          .collection('users_orders')
          .doc(_getCurrentUserId())
          .collection('user_orders');

      final QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users_cart_items')
          .doc(_getCurrentUserId())
          .collection('user_cart_items')
          .get();

      // Get cart items
      List<QueryDocumentSnapshot> cartItems = cartSnapshot.docs;

      // Process each cart item
      for (QueryDocumentSnapshot item in cartItems) {
        final Map<String, dynamic> data = item.data() as Map<String, dynamic>;

        // Extract cart item details
        String tailorId = data['id'];
        String productId = data['product_id'];
        String title = data['title'];
        int quantity = data['quantity'];
        double price = data['price'];
        List<String> images = List<String>.from(data['images']);

        // Generate a unique order ID
        orderId = generateOrderId();

        // Get user address
        Map<String, dynamic> userAddress = selectedAddress ??
            await getUserAddressesOnce(); // Use `selectedAddress` if available

        // Ensure the order collection exists for the user
        await FirebaseFirestore.instance
            .collection('users_orders')
            .doc(_getCurrentUserId())
            .set({'id': _getCurrentUserId()}, SetOptions(merge: true));

        // Place the order
        await firebaseFirestoreFunctions.placeOrder(
          orderCollection,
          tailorId,
          _getCurrentUserId(),
          productId,
          orderId,
          title,
          quantity,
          price,
          images,
          userAddress,
          deliveryDate,
        );

        // Track the order confirmation
        trackOrderConfirmation(orderId);

        //send notification to tailor
        _oneSignalApi.sendTailorOrderNotification(tailorId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user order: $e');
      }
    }
  }

  Future<void> clearCart() async {
    final cartCollection = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(_getCurrentUserId())
        .collection('user_cart_items');

    await cartCollection.get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    await OneSignal.User.removeTags(
        ["cart_status", "cart_item_count", "last_cart_update"]);
    if (kDebugMode) {
      print('Cart cleared');
    }
  }

  String _getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  String _getCountryCode() {
    switch (countryCode) {
      case 'NGN':
        return 'NGN';
      case 'KES':
        return 'KES';
      case 'GHS':
        return 'GHS';
      case 'ZAR':
        return 'ZAR';
      default:
        return 'USD';
    }
  }

  //refernce
  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = "iOS";
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardUI() {
    return PaymentCard(number: '', cvc: '', expiryMonth: 0, expiryYear: 0);
  }

  chargeAndMakePayment() async {
    initializePlugin().then((value) async {
      Charge charge = Charge()
        ..amount = price * 100
        ..email = userEmail!
        ..reference = _getReference()
        ..card = _getCardUI()
        ..currency = _getCountryCode();

      CheckoutResponse response = await plugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );

      if (response.status) {
        // //create shipment
        // final shipmentModel = await _createShipment();
        // //arrange delivery
        // await _arrangePickup(shipmentModel);
        // // place user order
        await createUserOrder();
        //send notification
        await _oneSignalApi.sendAfterPurchaseNotification(_getCurrentUserId());
        // update tailor payment
        await updateTailorPayments();
        // update tailor wallet
        await updateTailorWallet();
        // update tailor transaction
        await updateTailorTransaction();
        // clear cart
        await clearCart();
      }
    });
  }
}
