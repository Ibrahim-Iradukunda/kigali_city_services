import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import '../../theme/app_theme.dart';
import '../detail/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Listing? _selectedListing;

  // Kigali center
  static const LatLng _kigaliCenter = LatLng(-1.9403, 29.8739);

  Set<Marker> _buildMarkers(List<Listing> listings) {
    return listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id ?? listing.name),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getCategoryHue(listing.category),
        ),
        onTap: () {
          setState(() => _selectedListing = listing);
        },
      );
    }).toSet();
  }

  double _getCategoryHue(String category) {
    switch (category) {
      case 'Hospital':
        return BitmapDescriptor.hueRed;
      case 'Police Station':
        return BitmapDescriptor.hueBlue;
      case 'Library':
        return BitmapDescriptor.hueViolet;
      case 'Restaurant':
        return BitmapDescriptor.hueOrange;
      case 'Café':
      case 'Coffee Shop':
        return BitmapDescriptor.hueYellow;
      case 'Park':
        return BitmapDescriptor.hueGreen;
      case 'Tourist Attraction':
        return BitmapDescriptor.hueMagenta;
      case 'Pharmacy':
        return BitmapDescriptor.hueRose;
      case 'Utility Office':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Map View',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  // Recenter button
                  GestureDetector(
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          const CameraPosition(
                            target: _kigaliCenter,
                            zoom: 13,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: AppTheme.accentGold,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Map
            Expanded(
              child: Stack(
                children: [
                  Consumer<ListingsProvider>(
                    builder: (context, provider, _) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: _kigaliCenter,
                            zoom: 13,
                          ),
                          markers: _buildMarkers(provider.allListings),
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          onMapCreated: (controller) {
                            _mapController = controller;
                            controller.setMapStyle(_darkMapStyle);
                          },
                          onTap: (_) {
                            setState(() => _selectedListing = null);
                          },
                        ),
                      );
                    },
                  ),

                  // Bottom card for selected listing
                  if (_selectedListing != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListingDetailScreen(
                                listing: _selectedListing!,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Category icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold
                                      .withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getCategoryIcon(
                                      _selectedListing!.category),
                                  color: AppTheme.accentGold,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedListing!.name,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_selectedListing!.category} · ${_selectedListing!.address}',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppTheme.accentGold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Legend
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Consumer<ListingsProvider>(
                        builder: (context, provider, _) {
                          return Text(
                            '${provider.allListings.length} places',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
