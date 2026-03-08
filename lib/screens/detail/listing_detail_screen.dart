import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final LatLng position = LatLng(listing.latitude, listing.longitude);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with back button
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            title: Text(
              listing.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  width: double.infinity,
                  height: 200,
                  color: AppTheme.cardDark,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(listing.category),
                          size: 56,
                          color: AppTheme.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          listing.category,
                          style: TextStyle(
                            color: AppTheme.textMuted.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        listing.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category & rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.accentGold,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            listing.category,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          if (listing.rating != null) ...[
                            const SizedBox(width: 8),
                            const Text(
                              '·',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${listing.rating!.toStringAsFixed(1)} rating',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        listing.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info rows
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Address',
                        listing.address,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Contact',
                        listing.contactNumber,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.access_time_outlined,
                        'Added',
                        DateFormat('MMM d, yyyy').format(listing.timestamp),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.pin_drop_outlined,
                        'Coordinates',
                        '${listing.latitude.toStringAsFixed(4)}, ${listing.longitude.toStringAsFixed(4)}',
                      ),

                      const SizedBox(height: 28),

                      // Embedded Google Map
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 220,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: position,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId:
                                    MarkerId(listing.id ?? 'marker'),
                                position: position,
                                infoWindow: InfoWindow(
                                  title: listing.name,
                                  snippet: listing.address,
                                ),
                              ),
                            },
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                            onMapCreated: (controller) {
                              _mapController = controller;
                              // Apply dark map style
                              controller.setMapStyle(_darkMapStyle);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Navigation button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchNavigation(listing),
                          icon: const Icon(Icons.navigation_rounded,
                              size: 20),
                          label: const Text(
                            'Get Directions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGold,
                            foregroundColor: AppTheme.primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Call button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _makePhoneCall(
                              listing.contactNumber),
                          icon: const Icon(Icons.phone_outlined, size: 20),
                          label: const Text(
                            'Call Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Rate this service button
                      Center(
                        child: OutlinedButton(
                          onPressed: () {
                            _showRatingDialog(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentGold,
                            side: const BorderSide(
                                color: AppTheme.accentGold, width: 1.5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Rate this service',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentGold, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Police Station':
        return Icons.local_police;
      case 'Library':
        return Icons.local_library;
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
      case 'Coffee Shop':
        return Icons.local_cafe;
      case 'Park':
        return Icons.park;
      case 'Tourist Attraction':
        return Icons.place;
      case 'Pharmacy':
        return Icons.local_pharmacy;
      case 'Utility Office':
        return Icons.business;
      default:
        return Icons.place;
    }
  }

  Future<void> _launchNavigation(Listing listing) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String number) async {
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showRatingDialog(BuildContext context) {
    double rating = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Rate this service',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() => rating = i + 1.0);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        i < rating ? Icons.star : Icons.star_outline,
                        color: AppTheme.accentGold,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Rated ${rating.toInt()} stars!'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
    {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
    {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#263c3f"}]},
    {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#6b9a76"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
    {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
    {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#9ca5b3"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#746855"}]},
    {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#1f2835"}]},
    {"featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [{"color": "#f3d19c"}]},
    {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#2f3948"}]},
    {"featureType": "transit.station", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]},
    {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#515c6d"}]},
    {"featureType": "water", "elementType": "labels.text.stroke", "stylers": [{"color": "#17263c"}]}
  ]
  ''';
}
