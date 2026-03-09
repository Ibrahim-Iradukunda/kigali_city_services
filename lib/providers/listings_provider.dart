import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Listing> _allListings = [];
  List<Listing> _filteredListings = [];
  List<Listing> _userListings = [];
  Listing? _selectedListing;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  StreamSubscription? _listingsSubscription;
  StreamSubscription? _userListingsSubscription;

  // Getters
  List<Listing> get allListings => _allListings;
  List<Listing> get filteredListings => _filteredListings;
  List<Listing> get userListings => _userListings;
  Listing? get selectedListing => _selectedListing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  String _formatFirestoreError(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Firestore permission denied. Update your Firestore Rules to allow access (or sign in with an allowed account).';
      }
      if (error.code == 'failed-precondition') {
        return 'Firestore query failed. This can happen when an index is required.';
      }
      return error.message ?? 'Firestore error: ${error.code}';
    }
    return error.toString();
  }

  // Initialize stream for all listings
  void initListingsStream() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _listingsSubscription?.cancel();
    _listingsSubscription = _firestoreService.getListingsStream().listen(
      (listings) {
        _allListings = listings;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = _formatFirestoreError(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Initialize stream for user's own listings
  void initUserListingsStream(String userId) {
    _userListingsSubscription?.cancel();
    _userListingsSubscription = _firestoreService
        .getUserListingsStream(userId)
        .listen(
          (listings) {
            _userListings = listings;
            notifyListeners();
          },
          onError: (error) {
            // If fetching the user's own listings fails (for example due to
            // missing indexes), don't break the main directory screen.
            // Instead, surface it as "no user listings yet".
            _userListings = [];
            notifyListeners();
          },
        );
  }

  // Apply search and category filters
  void _applyFilters() {
    _filteredListings = _allListings.where((listing) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          listing.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          listing.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      bool matchesCategory =
          _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          listing.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Set category filter
  void setSelectedCategory(String? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null; // Toggle off if same category
    } else {
      _selectedCategory = category;
    }
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
  }

  // Select a listing for detail view
  void selectListing(Listing listing) {
    _selectedListing = listing;
    notifyListeners();
  }

  // Create a new listing
  Future<bool> createListing(Listing listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.createListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _error = _formatFirestoreError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update a listing
  Future<bool> updateListing(String id, Listing listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.updateListing(id, listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _error = _formatFirestoreError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a listing
  Future<bool> deleteListing(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.deleteListing(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _error = _formatFirestoreError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get listings count by category
  Map<String, int> getCategoryCounts() {
    Map<String, int> counts = {};
    for (var listing in _allListings) {
      counts[listing.category] = (counts[listing.category] ?? 0) + 1;
    }
    return counts;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    _userListingsSubscription?.cancel();
    super.dispose();
  }
}
