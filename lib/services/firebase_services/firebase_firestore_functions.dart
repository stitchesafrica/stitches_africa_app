import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/cart_providers.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/tailor_order_providers.dart';
import 'package:stitches_africa/models/firebase_models/tailor_work_model.dart';
import 'package:stitches_africa/services/hive_service/hive_service.dart';

class FirebaseFirestoreFunctions {
  String? uID;

  FirebaseFirestoreFunctions() {
    uID = getCurrentUserId();
  }
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  HiveService hiveService = HiveService();

  var box = Hive.box('user_preferences');

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference shippmentIdsCollection =
      FirebaseFirestore.instance.collection('users_shipments_ids');
  final CollectionReference usersMeasurements =
      FirebaseFirestore.instance.collection('users_measurements');

  Future<void> addUser(String email, String? userId, bool isTailor) async {
    final user = box.get('user');
    String firstName = user['firstName'];
    String lastName = user['lastName'];
    String shoppingPreference = user['shoppingPreference'];

    if (userId != null) {
      try {
        await users.doc(userId).set({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'shopping_preference': shoppingPreference,
          'is_tailor': isTailor,
          'is_general_admin': false,
        });
        if (kDebugMode) {
          print("User added successfully");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to add user: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("User ID is null");
      }
    }
  }

  Future<void> updateUserDetails(
    String? userId,
    String firstName,
    String lastName,
  ) async {
    if (userId != null) {
      try {
        await users.doc(userId).update({
          'first_name': firstName,
          'last_name': lastName,
        });
        if (kDebugMode) {
          print("User updated successfully");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to update user: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("User ID is null");
      }
    }
  }

  Future<void> updateShoppingPrefrence(
    String? userId,
    String preference,
  ) async {
    if (userId != null) {
      try {
        await users.doc(userId).update({
          'shopping_preference': preference,
        });
        if (kDebugMode) {
          print("User updated successfully");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to update user: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("User ID is null");
      }
    }
  }

  Future<Map<String, dynamic>>? getUserDataAndStoreLocally(
      String? userId) async {
    print(userId);
    if (userId != null) {
      try {
        DocumentSnapshot userCollection = await users.doc(userId).get();
        if (userCollection.exists) {
          if (kDebugMode) {
            print("Document data: ${userCollection.data()}");
          }
          Map<String, dynamic> userData =
              userCollection.data() as Map<String, dynamic>;
          await hiveService.saveUserData(
            firstName: userData['first_name'],
            lastName: userData['last_name'],
            shoppingPreference: userData['shopping_preference'],
          );
          return userData;
        } else {
          if (kDebugMode) {
            print("Document does not exist");
          }
          return {};
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error getting document: $e");
        }
        rethrow;
      }
    }
    return {};
  }

  //! W I S H L I S T  F U N C T I O N S
  Future<void> addWishlistItems(
      CollectionReference collection,
      String id,
      String productId,
      List<String> imageUrl,
      String title,
      double price) async {
    return await collection.doc().set({
      'id': id,
      'product_id': productId,
      'images': imageUrl,
      'title': title,
      'price': price,
      'is_saved': true,
    }).then((value) {
      if (kDebugMode) {
        print('Wishlist item added');
      }
    });
  }

  Future<void> deletWishlistItems(
      String title, CollectionReference subCollectionRef) async {
    QuerySnapshot querySnapshot =
        await subCollectionRef.where('title', isEqualTo: title).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      String docID = querySnapshot.docs.first.id;
      await subCollectionRef.doc(docID).delete();
      if (kDebugMode) {
        print('Wishlist item title:$title deleted successfully');
      }
    }
  }

  Future wishlistStateHandler(
      CollectionReference subCollectionRef, String id, bool isSaved) async {
    QuerySnapshot querySnapshot = await subCollectionRef
        .where('product_id', isEqualTo: id)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String docID = querySnapshot.docs.first.id;

      await subCollectionRef.doc(docID).update({'is_saved': isSaved});
      if (kDebugMode) {
        print('wishlist state updated successfully');
      }
    } else {
      if (kDebugMode) {
        print('No document fetched from the collection');
      }
    }
  }

  Future<bool> getWishlistState(
      CollectionReference collectionRef, String id) async {
    QuerySnapshot querySnapshot =
        await collectionRef.where('product_id', isEqualTo: id).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      bool bookmarkState = querySnapshot.docs.first['is_saved'];
      return bookmarkState;
    } else {
      if (kDebugMode) {
        print('No snapshot available');
      }
      return false;
    }
  }

  //! F A V O R I T E  T A I L O R S  F U N C T I O N S
  Future<void> addFavoriteTailor(
    CollectionReference collection,
    String brandName,
    String id,
  ) async {
    return await collection.doc().set({
      'id': id,
      'brand_name': brandName,
      'is_saved': true,
    }).then((value) {
      if (kDebugMode) {
        print('Favorite tailor item added');
      }
    });
  }

  Future<void> deleteFavoriteTailor(
      String id, CollectionReference subCollectionRef) async {
    QuerySnapshot querySnapshot =
        await subCollectionRef.where('id', isEqualTo: id).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      String docID = querySnapshot.docs.first.id;
      await subCollectionRef.doc(docID).delete();
      if (kDebugMode) {
        print('favorite tailor id:$id deleted successfully');
      }
    }
  }

  Future favoriteStateHandler(
      CollectionReference subCollectionRef, String id, bool isSaved) async {
    QuerySnapshot querySnapshot =
        await subCollectionRef.where('id', isEqualTo: id).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      String docID = querySnapshot.docs.first.id;

      await subCollectionRef.doc(docID).update({'is_saved': isSaved});
      if (kDebugMode) {
        print('wishlist state updated successfully');
      }
    } else {
      if (kDebugMode) {
        print('No document fetched from the collection');
      }
    }
  }

  Future<bool> getFavoriteState(
      CollectionReference collectionRef, String id) async {
    QuerySnapshot querySnapshot =
        await collectionRef.where('id', isEqualTo: id).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      bool bookmarkState = querySnapshot.docs.first['is_saved'];
      return bookmarkState;
    } else {
      if (kDebugMode) {
        print('No snapshot available');
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserFavoriteTailors(
      CollectionReference collectionRef) async {
    final querySnapshot = await collectionRef.get();
    List<Map<String, dynamic>> favoriteTailors = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> tailorData = doc.data() as Map<String, dynamic>;

      favoriteTailors.add(tailorData);
    }

    return favoriteTailors;
  }

  //! C A R T  F U N C T I O N S

  Future<void> refreshCart(
      WidgetRef ref, CollectionReference collection) async {
    // Check if the widget is still mounted before performing actions
    if (!ref.read(mountedProvider)) return;

    // Get price
    double price = await getTotalPrice(collection);

    // Update price globally
    ref.read(totalPriceProvider.notifier).state = price;

    // Get total cart items
    int totalItems = await getTotalNoOfCartItems(collection);

    // Update total items globally
    ref.read(totalCartItemsProvider.notifier).state = totalItems;
  }

  Future<bool> addToCart(
    WidgetRef ref,
    CollectionReference collection,
    String id,
    String productId,
    List<String> images,
    String title,
    double price,
    int quantity,
  ) async {
    try {
      // Check if the item already exists in the cart
      QuerySnapshot querySnapshot =
          await collection.where('title', isEqualTo: title).limit(1).get();

      // If the item does not exist, add it to the cart
      if (querySnapshot.docs.isEmpty) {
        await collection.doc().set({
          'id': id,
          'product_id': productId,
          'images': images,
          'title': title,
          'price': price,
          'quantity': quantity,
        });

        // Refresh cart data and update cart tags if necessary
        await refreshCart(ref, collection);
        int totalItems = await getTotalNoOfCartItems(collection);

        // Update OneSignal tags for the user
        if (totalItems > 0) {
          await OneSignal.User.addTags({
            "cart_status": "has_items",
            "cart_item_count": "$totalItems",
            "last_cart_update": DateTime.now().toIso8601String(),
          });

          if (kDebugMode) {
            print("Cart tags updated for user");
          }
        }

        if (kDebugMode) {
          print('Cart item added');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Cart item already exists');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item to cart: $e');
      }
      return false;
    }
  }

  Future incrementProductQuantity(
      CollectionReference subCollectionRef, String title, WidgetRef ref) async {
    QuerySnapshot querySnapshot =
        await subCollectionRef.where('title', isEqualTo: title).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      String docID = querySnapshot.docs.first.id;

      //upadte quantity
      await subCollectionRef
          .doc(docID)
          .update({'quantity': FieldValue.increment(1)});

      await refreshCart(ref, subCollectionRef);
    }
  }

  Future decrementProductQuantity(
      WidgetRef ref, CollectionReference subCollectionRef, String title) async {
    QuerySnapshot querySnapshot =
        await subCollectionRef.where('title', isEqualTo: title).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      String docID = querySnapshot.docs.first.id;

      subCollectionRef.doc(docID).get().then((docSnapshot) async {
        int currentValue =
            (docSnapshot.data() as Map<String, dynamic>)['quantity'] ?? 0;
        if (currentValue > 1) {
          await subCollectionRef
              .doc(docID)
              .update({'quantity': FieldValue.increment(-1)});
          await refreshCart(ref, subCollectionRef);
        }
      });
    }
  }

  Future<void> deletcartItem(
      WidgetRef ref, String title, CollectionReference collection) async {
    QuerySnapshot querySnapshot =
        await collection.where('title', isEqualTo: title).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      String docID = querySnapshot.docs.first.id;
      await collection.doc(docID).delete();

      int totalItems = await getTotalNoOfCartItems(collection);

      // Update OneSignal tags for the user
      if (totalItems == 0) {
        await OneSignal.User.removeTags(
            ["cart_status", "cart_item_count", "last_cart_update"]);
        if (kDebugMode) {
          print("Cart tags deleted for user");
        }
      }

      // Ensure refreshCart is only called if the widget is mounted
      if (ref.read(mountedProvider)) {
        await refreshCart(ref, collection);
      }

      if (kDebugMode) {
        print('cart item title:$title deleted successfully');
      }
    }
  }

  Future<double> getTotalPrice(CollectionReference subCollection) async {
    double totalValue = 0.0;

    QuerySnapshot querySnapshot = await subCollection.get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      double price =
          (documentSnapshot.data() as Map<String, dynamic>)['price'] ?? 0.0;
      int quantity =
          (documentSnapshot.data() as Map<String, dynamic>)['quantity'] ?? 0;

      double itemValue = price * quantity;
      totalValue += itemValue;
    }
    if (kDebugMode) {
      print('cart total price: $totalValue');
    }

    return totalValue;
  }

  Future<int> getTotalNoOfCartItems(CollectionReference subCollection) async {
    int totalCartItems = 0;

    QuerySnapshot querySnapshot = await subCollection.get();
    // ignore: unused_local_variable
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      totalCartItems++;
    }
    return totalCartItems;
  }

  Future<List<Map<String, dynamic>>> prepareParcelItemsFromCartCollection(
      CollectionReference cartCollection) async {
    const String description = "Traditional Wears";
    const double weight = 0.6;

    try {
      // Fetch all items from the cart collection
      final QuerySnapshot cartSnapshot = await cartCollection.get();

      // Map the cart items into the required format
      List<Map<String, dynamic>> parcelItems = cartSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          "description": description,
          "name": data['title'],
          "type": "parcel",
          "currency": "USD",
          "value": data['price'],
          "quantity": data['quantity'],
          "weight": weight,
        };
      }).toList();

      print('PARCE ITEMS: ${parcelItems.length}');
      return parcelItems;
    } catch (e) {
      if (kDebugMode) {
        print('Error preparing parcel items: $e');
      }
      return [];
    }
  }

  //! O R D E R  F U N C T I O N S
  Future<void> placeOrder(
    CollectionReference orderCollection,
    String tailorId,
    String userId,
    String productId,
    String orderId,
    String title,
    int quantity,
    double price,
    List<String> images,
    Map<String, dynamic> userAddress,
    String deliveryDate,
  ) async {
    try {
      await orderCollection.doc().set({
        'tailor_id': tailorId,
        'user_id': userId,
        'product_id': productId,
        'order_id': orderId,
        'title': title,
        'quantity': quantity,
        'price': price,
        'images': images,
        'order_status': 'pending',
        'user_address': userAddress,
        'delivery_date': deliveryDate,
        'timestamp': DateTime.now()
      }).then((_) {
        if (kDebugMode) {
          print('Order placed successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to place order: $e');
      }
    }
  }

  Future<int> getTotalOrdersInDb() async {
    int totalDocs = 0;

    QuerySnapshot usersOrdersSnapshot =
        await FirebaseFirestore.instance.collection('users_orders').get();

    for (var parentDoc in usersOrdersSnapshot.docs) {
      QuerySnapshot subCollectionSnapshot =
          await parentDoc.reference.collection('user_orders').get();

      // Add the number of documents in the sub-collection to totalDocs
      totalDocs += subCollectionSnapshot.docs.length;
    }

    if (kDebugMode) {
      print('Total number of documents in all sub-collections: $totalDocs');
    }
    return totalDocs;
  }

  Future<void> updateOrderStatus(String orderStatus, String userId,
      String productId, String tailorId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users_orders')
        .doc(userId)
        .collection('user_orders')
        .where('tailor_id', isEqualTo: tailorId)
        .where('product_id', isEqualTo: productId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String docID = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('users_orders')
          .doc(userId)
          .collection('user_orders')
          .doc(docID)
          .update({'order_status': orderStatus});

      if (kDebugMode) {
        print('Order status updated successfully');
      }
    } else {
      if (kDebugMode) {
        print('No document fetched from the collection');
      }
    }
  }

  Future<void> refreshTailorOrders(WidgetRef ref, String userId) async {
    //get total order items
    int totalItems = await getTotalNoOfActiveOrderItemsForTailors(userId);

    //update total items gloabally
    ref.read(totalOrderItemsProvider.notifier).state = totalItems;
  }

  Future<int> getTotalNoOfActiveOrderItemsForTailors(String tailorId) async {
    int totalOrderItems = 0;

    QuerySnapshot parentSnapshot =
        await FirebaseFirestore.instance.collection('users_orders').get();
    if (parentSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        print('No documents found in users_orders');
      }
      return 0;
    }

    // Loop through each document in 'users_orders'
    for (var parentDoc in parentSnapshot.docs) {
      // Get the 'user_orders' sub-collection
      QuerySnapshot subCollectionSnapshot = await FirebaseFirestore.instance
          .collection('users_orders')
          .doc(parentDoc.id)
          .collection('user_orders')
          .where('tailor_id', isEqualTo: tailorId)
          .where('order_status', isNotEqualTo: 'delivered')
          .get();

      print(subCollectionSnapshot.docs.length);
      // Count the matching documents in the sub-collection
      for (var documentSnapshot in subCollectionSnapshot.docs) {
        print('Found order with ID: ${documentSnapshot['tailor_id']}');
        totalOrderItems++;
      }
    }

    print('Total Order Items for Tailor: $totalOrderItems');
    return totalOrderItems;
  }

  //! A D D R E S S E S  F U N C T I O N S
  Future<void> addUserAddress(
      CollectionReference collection,
      String firstName,
      String lastName,
      String country,
      String countryCode,
      String streetAddress,
      String flatNumber,
      String state,
      String city,
      String postCode,
      String dialCode,
      String phoneNumber) async {
    try {
      await collection.doc().set({
        'first_name': firstName,
        'last_name': lastName,
        'country': country,
        'country_code': countryCode,
        'street_address': streetAddress,
        'flat_number': flatNumber,
        'state': state,
        'city': city,
        'post_code': postCode,
        'dial_code': dialCode,
        'phone_number': phoneNumber,
      }).then((_) {
        if (kDebugMode) {
          print('User address added successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add user address: $e');
      }
    }
  }

  Future<String?> getUserAddressDocId(
      CollectionReference collection,
      String firstName,
      String lastName,
      String country,
      String streetAddress,
      String? flatNumber,
      String state,
      String city,
      String postCode,
      String dialCode,
      String phoneNumber) async {
    try {
      // Query the collection where each field matches the provided value
      QuerySnapshot querySnapshot = await collection
          .where('first_name', isEqualTo: firstName)
          .where('last_name', isEqualTo: lastName)
          .where('country', isEqualTo: country)
          .where('street_address', isEqualTo: streetAddress)
          .where('flat_number', isEqualTo: flatNumber)
          .where('state', isEqualTo: state)
          .where('city', isEqualTo: city)
          .where('post_code', isEqualTo: postCode)
          .where('dial_code', isEqualTo: dialCode)
          .where('phone_number', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If there is a match, return the document ID of the first match
        return querySnapshot.docs.first.id;
      } else {
        // No match found
        if (kDebugMode) {
          print('No matching document found');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching document ID: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserFirstAddress(
      CollectionReference collection) async {
    try {
      QuerySnapshot querySnapshot = await collection.get();
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> firstAddress =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        print(firstAddress);
        return firstAddress;
      } else {
        if (kDebugMode) {
          print('No documents found in user addresses');
        }
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserAddress(
      CollectionReference collection,
      String
          docId, // You need the document ID of the existing address to update
      String firstName,
      String lastName,
      String country,
      String countryCode,
      String streetAddress,
      String flatNumber,
      String state,
      String city,
      String postCode,
      String dialCode,
      String phoneNumber) async {
    try {
      await collection.doc(docId).update({
        'first_name': firstName,
        'last_name': lastName,
        'country': country,
        'country_code': countryCode,
        'street_address': streetAddress,
        'flat_number': flatNumber,
        'state': state,
        'city': city,
        'post_code': postCode,
        'dial_code': dialCode,
        'phone_number': phoneNumber,
      }).then((_) {
        if (kDebugMode) {
          print('User address updated successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user address: $e');
      }
    }
  }

  Future<bool> checkIfUserHasAddress(CollectionReference collection) async {
    QuerySnapshot querySnapshot = await collection.get();

    if (querySnapshot.docs.isEmpty) {
      if (kDebugMode) {
        print('No user address available');
      }
      return false;
    }

    return true;
  }

  //! S E A R C H  F U N C T I O N S
  Future<void> addUserRecentlyViewedItems(
    CollectionReference userViewedItemsCollection,
    String productId,
    String image,
    String category,
  ) async {
    try {
      // Check if any document with the same 'product_id' already exists
      QuerySnapshot querySnapshot = await userViewedItemsCollection
          .where('product_id', isEqualTo: productId)
          .get();

      // If no such document exists, add the new one
      if (querySnapshot.docs.isEmpty) {
        await userViewedItemsCollection.doc().set({
          'image': image,
          'category': category,
          'product_id': productId,
          'timestamp': DateTime.now(),
        }).then((value) {
          if (kDebugMode) {
            print('User recently viewed item added');
          }
        });
      } else {
        if (kDebugMode) {
          print('Item with this product_id already exists');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add user recently viewed item: $e');
      }
    }
  }

  Future<TailorWorkModel> getTailorWorksByProductID(String productId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tailor_works')
        .where('product_id', isEqualTo: productId)
        .get();

    // Convert the documents into a list of TailorWorkModel
    List<TailorWorkModel> tailorWorks = snapshot.docs
        .map((doc) =>
            TailorWorkModel.fromDocument(doc.data() as Map<String, dynamic>))
        .toList();

    return tailorWorks.first;
  }

  //! T A I L O R  F U N C T I O N S
  Future<bool> isTailorOnBoarded(String userId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('tailors')
          .doc(userId)
          .get();

      // Check if the document exists
      if (kDebugMode) {
        print('Tailor Doc exists:${docSnapshot.exists}');
      }
      return docSnapshot.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking document existence: $e');
      }
      return false; // Return false in case of an error
    }
  }

  Future<void> createTailorData(
    String userId,
    String fullName,
    String dob,
    String faceImage,
    String identityImage,
    String streetAddress,
    String city,
    String state,
    String postalcode,
    String country,
    String addressImage,
    String tailorBrandName,
    String tailorTagline,
    String tailorLogo,
    String tailorEmailAddress,
    String dialCode,
    String phoneNumber,
    List<String> tailorFeaturedWorks,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('tailors').doc(userId).set({
        'tailor_personal_info': {
          'full_name': fullName,
          'dob': dob,
          'face_image': faceImage,
          'identity_image': identityImage,
        },
        'tailor_residential_info': {
          'street_address': streetAddress,
          'city': city,
          'state': state,
          'postal_code': postalcode,
          'country': country,
          'proof_of_address_image': addressImage,
        },
        'is_verified': 'pending',
        'brand_name': tailorBrandName,
        'tagline': tailorTagline,
        'logo': tailorLogo,
        'email_address': tailorEmailAddress,
        'dial_code': dialCode,
        'phone_number': phoneNumber,
        'featured_works': tailorFeaturedWorks,
        'wallet': 0.0,
        'transactions': [],
      }).then((value) {
        if (kDebugMode) {
          print('Tailor data created successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create tailor data: $e');
      }
    }
  }

  Future<void> updateBrandDetails(
    String userId,
    String tailorBrandName,
    String tailorTagline,
    String tailorLogo,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('tailors')
          .doc(userId)
          .update({
        'brand_name': tailorBrandName,
        'tagline': tailorTagline,
        'logo': tailorLogo,
      }).then((value) {
        if (kDebugMode) {
          print('Tailor brand updated successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update tailor brand: $e');
      }
    }
  }

  Future<void> updateTailorKYCDetails(
    String userId,
    String fullName,
    String dob,
    String faceImage,
    String identityImage,
    String streetAddress,
    String city,
    String state,
    String postalcode,
    String country,
    String addressImage,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('tailors')
          .doc(userId)
          .update({
        'tailor_personal_info': {
          'full_name': fullName,
          'dob': dob,
          'face_image': faceImage,
          'identity_image': identityImage,
        },
        'tailor_residential_info': {
          'street_address': streetAddress,
          'city': city,
          'state': state,
          'postal_code': postalcode,
          'country': country,
          'proof_of_address_image': addressImage,
        },
        'is_verified': 'pending',
      }).then((value) {
        if (kDebugMode) {
          print('Tailor kyc updated successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update tailor kyc: $e');
      }
    }
  }

  Future<String> getTailorVerificationStatus(String userId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('tailors')
          .doc(userId)
          .get();

      Map<String, dynamic> tailorData =
          docSnapshot.data() as Map<String, dynamic>;
      return tailorData['is_verified'] as String;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking document existence: $e');
      }
      return 'pending';
    }
  }

  Future<void> addToWalletBalance(String tailorId, double amount) async {
    try {
      await FirebaseFirestore.instance
          .collection('tailors')
          .doc(tailorId)
          .update({'wallet': FieldValue.increment(amount)}).then((value) {
        if (kDebugMode) {
          print('Tailor wallet updated successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update tailor wallet: $e');
      }
    }
  }

  Future<void> deductFromWalletBalance(String tailorId, double amount) async {
    try {
      await FirebaseFirestore.instance
          .collection('tailors')
          .doc(tailorId)
          .update({'wallet': FieldValue.increment(-amount)}).then((value) {
        if (kDebugMode) {
          print('Tailor wallet updated successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update tailor wallet: $e');
      }
    }
  }

  Future<void> updateTransactions(
      String tailorId, List<Map<String, dynamic>> transaction) async {
    try {
      await FirebaseFirestore.instance
          .collection('tailors')
          .doc(tailorId)
          .update({'transactions': FieldValue.arrayUnion(transaction)}).then(
              (value) {
        if (kDebugMode) {
          print('Tailor transactions updated successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update tailor transaction: $e');
      }
    }
  }

  Future<void> addImagesFromFeaturedWorks(
      String docId, List<String> imageUrls) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('tailors').doc(docId);

    try {
      await docRef.update({
        'featured_works': FieldValue.arrayUnion(imageUrls),
      });

      if (kDebugMode) {
        print('Image URL added successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add image URL: $e');
      }
    }
  }

  Future<void> removeImageFromFeaturedWorks(
      String docId, String imageUrl) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('tailors').doc(docId);

    try {
      await docRef.update({
        'featured_works': FieldValue.arrayRemove([imageUrl]),
      });

      if (kDebugMode) {
        print('Image URL removed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove image URL: $e');
      }
    }
  }

  Future<void> createTailoWork(
    String userId,
    String productId,
    String title,
    double price,
    String description,
    String category,
    List<String> tags,
    List<String> images,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('tailor_works')
          .doc(productId)
          .set({
        'id': userId,
        'product_id': productId,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'tags': tags,
        'images': images,
      }).then((value) {
        if (kDebugMode) {
          print('Tailor work created successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create tailor work: $e');
      }
    }
  }

  Future<void> updateTailorWork(
    String userId,
    String productId,
    String title,
    double price,
    String description,
    String category,
    List<String> tags,
    //List<String> images,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('tailor_works')
          .doc(productId)
          .update({
        'id': userId,
        'product_id': productId,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'tags': tags,
        //'images': images,
      }).then((value) {
        if (kDebugMode) {
          print('Tailor work updated successfully');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update tailor work: $e');
      }
    }
  }

  Future<QueryDocumentSnapshot?> getTailorWork(String productId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tailor_works')
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        print('No document found for productId: $productId');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
    return null;
  }

  Future<void> deleteTailorWork(String productId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tailor_works')
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docID = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('tailor_works')
            .doc(docID)
            .delete();
      } else {
        if (kDebugMode) {
          print('work item deleted');
        }
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  Future<void> addImagesToWorks(String docId, List<String> imageUrls) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('tailor_works').doc(docId);

    try {
      await docRef.update({
        'images': FieldValue.arrayUnion(imageUrls),
      });

      if (kDebugMode) {
        print('Image URL added successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add image URL: $e');
      }
    }
  }

  Future<void> removeImageFromWorks(String docId, String imageUrl) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('tailor_works').doc(docId);

    try {
      await docRef.update({
        'images': FieldValue.arrayRemove([imageUrl]),
      });

      if (kDebugMode) {
        print('Image URL removed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove image URL: $e');
      }
    }
  }

  //! S H I P M E N T  A N D  T R A C K I N G  F U N C T I O N S
  Future<void> addShippingIds(String? userId, Map<String, dynamic> data) async {
    if (userId != null) {
      try {
        await shippmentIdsCollection.doc(userId).set(data);
        if (kDebugMode) {
          print("Shipping Ids successfully");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to update user: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("User ID is null");
      }
    }
  }

  Future<void> updateShippingIds(
      String? userId, Map<String, dynamic> data) async {
    if (userId != null) {
      try {
        await shippmentIdsCollection.doc(userId).update(data);
        if (kDebugMode) {
          print("Shipping Ids updated successfully");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to update user: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("User ID is null");
      }
    }
  }

  Future<Map<String, dynamic>?> getShippingDetails(String? userId) async {
    if (userId != null) {
      try {
        DocumentSnapshot snapshot =
            await shippmentIdsCollection.doc(userId).get();
        if (snapshot.exists) {
          return snapshot.data() as Map<String, dynamic>;
        } else {
          if (kDebugMode) {
            print("No such document found");
          }
          return null;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error getting document: $e");
        }
        return null;
      }
    } else {
      if (kDebugMode) {
        print("User ID is null");
      }
      return null;
    }
  }

  //! M E A S U R M E N T  F U N C T I O N S
  Future<String> doesUserHave3DMeasurement(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users_measurements')
          .doc(userId)
          .get();

      // Check if the document exists

      if (doc.exists) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('task_set_url') &&
            data.containsKey('volume_params') &&
            data.containsKey('side_params') &&
            data.containsKey('front_params')) {
          return 'onboarded';
        } else {
          return 'exists';
        }
      } else {
        return '!exists';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking document existence: $e');
      }
      return '!exists'; // Return false in case of an error
    }
  }

  Future<void> addUserMeasurementData(
    CollectionReference collection,
    String userId,
    int id,
    int measurementUserId,
    String gender,
    int height,
    double weight,
  ) async {
    await collection.doc(userId).set({
      'id': id,
      'user_id': measurementUserId,
      'gender': gender,
      'height': height,
      'weight': weight,
    });
  }

  Future<void> syncUserMeasurementDataWithAPI(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await usersMeasurements.doc(userId).update(data);
      if (kDebugMode) {
        print("User Measurement updated successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update user: $e");
      }
    }
  }

  Future<void> updateUserMeasurementFields(
      String userId, Map<String, dynamic> updatedFields) async {
    try {
      // Retrieve the current measurement data
      final doc = await FirebaseFirestore.instance
          .collection('users_measurements')
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw Exception("User measurement data not found.");
      }

      final currentData = doc.data()!;
      final Map<String, dynamic> volumeParams =
          Map<String, dynamic>.from(currentData['volume_params'] ?? {});
      final Map<String, dynamic> sideParams =
          Map<String, dynamic>.from(currentData['side_params'] ?? {});
      final Map<String, dynamic> frontParams =
          Map<String, dynamic>.from(currentData['front_params'] ?? {});

      // Separate the updated fields into their respective categories
      final Map<String, dynamic> updatedVolumeParams = {};
      final Map<String, dynamic> updatedSideParams = {};
      final Map<String, dynamic> updatedFrontParams = {};

      updatedFields.forEach((key, value) {
        if (volumeParams.containsKey(key)) {
          updatedVolumeParams[key] = value;
        } else if (sideParams.containsKey(key)) {
          updatedSideParams[key] = value;
        } else if (frontParams.containsKey(key)) {
          updatedFrontParams[key] = value;
        } else {
          throw Exception("Unknown field: $key");
        }
      });

      // Update only the relevant sections in the database
      final Map<String, dynamic> updates = {};
      if (updatedVolumeParams.isNotEmpty) {
        updates['volume_params'] = {...volumeParams, ...updatedVolumeParams};
      }
      if (updatedSideParams.isNotEmpty) {
        updates['side_params'] = {...sideParams, ...updatedSideParams};
      }
      if (updatedFrontParams.isNotEmpty) {
        updates['front_params'] = {...frontParams, ...updatedFrontParams};
      }

      // Perform the update in Firestore
      await FirebaseFirestore.instance
          .collection('users_measurements')
          .doc(userId)
          .update(updates);

      if (kDebugMode) {
        print("Measurement data updated successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to update measurement data: $e");
      }
      rethrow; // Optionally rethrow to handle it further up the call stack
    }
  }

  Future<Map<String, dynamic>?> getUserMeasurementData(String userId) async {
    try {
      DocumentSnapshot snapshot = await usersMeasurements.doc(userId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print("No such document found");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting document: $e");
      }
      return null;
    }
  }
}
