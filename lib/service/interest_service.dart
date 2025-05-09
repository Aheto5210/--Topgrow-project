import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InterestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  Future<bool> toggleInterest(String productId) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final interestRef =
    _firestore.collection('Interests').doc('${_userId}_$productId');
    final productRef = _firestore.collection('products').doc(productId);

    final interestDoc = await interestRef.get();
    final productDoc = await productRef.get();

    if (interestDoc.exists) {
      // Remove interest
      await interestRef.delete();
      if (productDoc.exists) {
        final interestedBuyers =
        List<String>.from(productDoc.data()?['interestedBuyers'] ?? []);
        interestedBuyers.remove(_userId);
        await productRef.update({'interestedBuyers': interestedBuyers});
      }
      return false; // Not interested anymore
    } else {
      // Add interest
      await interestRef.set({
        'buyerId': _userId,
        'productId': productId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (productDoc.exists) {
        final interestedBuyers =
        List<String>.from(productDoc.data()?['interestedBuyers'] ?? []);
        if (!interestedBuyers.contains(_userId)) {
          interestedBuyers.add(_userId);
          await productRef.update({'interestedBuyers': interestedBuyers});
        }
      }
      return true; // Now interested
    }
  }
}