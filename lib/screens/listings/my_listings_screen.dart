import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../detail/listing_detail_screen.dart';
import 'create_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  const Text(
                    'My Listings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  // Add new listing button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CreateEditListingScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppTheme.primaryDark,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add New',
                            style: TextStyle(
                              color: AppTheme.primaryDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // User listings
            Expanded(
              child: Consumer<ListingsProvider>(
                builder: (context, provider, _) {
                  final listings = provider.userListings;

                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentGold,
                      ),
                    );
                  }

                  if (listings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.add_location_alt_outlined,
                              color: AppTheme.accentGold,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No listings yet',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Add your first service or place listing to help the Kigali community!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CreateEditListingScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Create Listing'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return ListingCard(
                        listing: listing,
                        showActions: true,
                        onTap: () {
                          provider.selectListing(listing);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListingDetailScreen(
                                  listing: listing),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateEditListingScreen(
                                listing: listing,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          _showDeleteDialog(
                              context, provider, listing.id!);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, ListingsProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Listing',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to delete this listing? This action cannot be undone.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
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
            onPressed: () async {
              Navigator.pop(context);
              bool success = await provider.deleteListing(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Listing deleted successfully'
                          : 'Failed to delete listing',
                    ),
                    backgroundColor: success
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
