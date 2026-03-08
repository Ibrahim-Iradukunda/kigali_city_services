import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String? id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;
  final double? rating;
  final int? reviewCount;
  final String? imageUrl;

  Listing({
    this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.rating,
    this.reviewCount,
    this.imageUrl,
  });

  // Categories available in the app
  static const List<String> categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Pharmacy',
    'Utility Office',
    'Coffee Shop',
  ];

  // Category icons mapping
  static Map<String, int> categoryIcons = {
    'Hospital': 0xe3f3,      // local_hospital
    'Police Station': 0xe54f, // local_police
    'Library': 0xe365,        // local_library
    'Restaurant': 0xe56c,     // restaurant
    'Café': 0xe541,           // local_cafe
    'Park': 0xe4be,           // park
    'Tourist Attraction': 0xe84f, // place
    'Pharmacy': 0xe548,       // local_pharmacy
    'Utility Office': 0xe0e5, // business
    'Coffee Shop': 0xe541,    // local_cafe
  };

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
    };
  }

  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
    double? rating,
    int? reviewCount,
    String? imageUrl,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
