import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listing.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'listings';

  // Get all listings as a real-time stream
  Stream<List<Listing>> getListingsStream() {
    // Only allow access if user is authenticated
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Listing.fromFirestore(doc))
              .toList();
        });
  }

  // Get listings by category as a real-time stream
  Stream<List<Listing>> getListingsByCategoryStream(String category) {
    // Only allow access if user is authenticated
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Listing.fromFirestore(doc))
              .toList();
        });
  }

  // Get listings created by a specific user
  Stream<List<Listing>> getUserListingsStream(String userId) {
    // Only allow access if user is authenticated
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Listing.fromFirestore(doc))
              .toList();
        });
  }

  // Get a single listing by ID
  Future<Listing?> getListingById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();
      if (doc.exists) {
        return Listing.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get listing: $e');
    }
  }

  // Create a new listing
  Future<String> createListing(Listing listing) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(listing.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  // Update an existing listing
  Future<void> updateListing(String id, Listing listing) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(listing.toFirestore());
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  // Delete a listing
  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  // Search listings by name (client-side filtering for flexibility)
  Stream<List<Listing>> searchListingsStream(String query) {
    String searchLower = query.toLowerCase();
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Listing.fromFirestore(doc))
              .where(
                (listing) =>
                    listing.name.toLowerCase().contains(searchLower) ||
                    listing.address.toLowerCase().contains(searchLower) ||
                    listing.category.toLowerCase().contains(searchLower),
              )
              .toList();
        });
  }

  // Get all listings once (for initial load)
  Future<List<Listing>> getAllListings() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get listings: $e');
    }
  }
}
