import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../theme/app_theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (listing.rating != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          listing.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(
                          Icons.star,
                          color: AppTheme.accentGold,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating stars
                  if (listing.rating != null)
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          double rating = listing.rating ?? 0;
                          if (i < rating.floor()) {
                            return const Icon(Icons.star,
                                color: AppTheme.accentGold, size: 14);
                          } else if (i < rating) {
                            return const Icon(Icons.star_half,
                                color: AppTheme.accentGold, size: 14);
                          } else {
                            return Icon(Icons.star_outline,
                                color: AppTheme.textMuted.withOpacity(0.5),
                                size: 14);
                          }
                        }),
                        const SizedBox(width: 8),
                        Text(
                          listing.category,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  if (listing.rating == null)
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: AppTheme.textMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          listing.category,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.address,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons
            if (showActions) ...[
              const SizedBox(width: 8),
              Column(
                children: [
                  if (onEdit != null)
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: AppTheme.accentGold,
                          size: 18,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (onDelete != null)
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.errorRed,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
