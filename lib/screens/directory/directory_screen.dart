import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../detail/listing_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      color: AppTheme.accentGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kigali City',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category selector (dropdown instead of horizontal chips)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<ListingsProvider>(
                builder: (context, provider, _) {
                  return DropdownButtonFormField<String>(
                    value: provider.selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Filter by category',
                    ),
                    items: Listing.categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      provider.setSelectedCategory(value);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<ListingsProvider>(
                builder: (context, provider, _) {
                  return TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for a service',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppTheme.textMuted,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      provider.setSearchQuery(value);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<ListingsProvider>(
                builder: (context, provider, _) {
                  String title = provider.selectedCategory != null
                      ? provider.selectedCategory!
                      : 'Services';
                  return Row(
                    children: [
                      Text(
                        provider.searchQuery.isNotEmpty
                            ? 'Search Results'
                            : title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (provider.selectedCategory != null ||
                          provider.searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            provider.clearFilters();
                            _searchController.clear();
                          },
                          child: const Text(
                            'Clear filters',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Listings list
            Expanded(
              child: Consumer<ListingsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentGold,
                      ),
                    );
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorRed,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final listings = provider.filteredListings;

                  if (listings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: AppTheme.textMuted,
                            size: 56,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No listings found',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : 'Be the first to add a listing!',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
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
                        onTap: () {
                          provider.selectListing(listing);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ListingDetailScreen(listing: listing),
                            ),
                          );
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
}
