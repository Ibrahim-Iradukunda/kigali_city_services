import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../theme/app_theme.dart';

class CreateEditListingScreen extends StatefulWidget {
  final Listing? listing;

  const CreateEditListingScreen({super.key, this.listing});

  @override
  State<CreateEditListingScreen> createState() =>
      _CreateEditListingScreenState();
}

class _CreateEditListingScreenState extends State<CreateEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  String _selectedCategory = Listing.categories.first;
  bool _isSubmitting = false;

  bool get isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.listing?.name ?? '');
    _addressController =
        TextEditingController(text: widget.listing?.address ?? '');
    _contactController =
        TextEditingController(text: widget.listing?.contactNumber ?? '');
    _descriptionController =
        TextEditingController(text: widget.listing?.description ?? '');
    _latitudeController = TextEditingController(
        text: widget.listing?.latitude.toString() ?? '-1.9403');
    _longitudeController = TextEditingController(
        text: widget.listing?.longitude.toString() ?? '29.8739');

    if (widget.listing != null) {
      _selectedCategory = widget.listing!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final listingsProvider = context.read<ListingsProvider>();

    final listing = Listing(
      id: widget.listing?.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: double.tryParse(_latitudeController.text) ?? -1.9403,
      longitude: double.tryParse(_longitudeController.text) ?? 29.8739,
      createdBy: authProvider.user!.uid,
      timestamp: widget.listing?.timestamp ?? DateTime.now(),
      rating: widget.listing?.rating,
      reviewCount: widget.listing?.reviewCount,
    );

    bool success;
    if (isEditing) {
      success =
          await listingsProvider.updateListing(widget.listing!.id!, listing);
    } else {
      success = await listingsProvider.createListing(listing);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Listing updated successfully!'
                  : 'Listing created successfully!',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              listingsProvider.error ?? 'Something went wrong',
            ),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Edit Listing' : 'New Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              _buildLabel('Place or Service Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g., Kimironko Café',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),

              // Category
              _buildLabel('Category'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.searchBarBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: AppTheme.cardDark,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    items: Listing.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Address
              _buildLabel('Address'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g., KG 123 St, Kimironko, Kigali',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 20),

              // Contact Number
              _buildLabel('Contact Number'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g., +250 788 123 456',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Contact is required' : null,
              ),
              const SizedBox(height: 20),

              // Description
              _buildLabel('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Describe this place or service...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 20),

              // Coordinates
              _buildLabel('Geographic Coordinates'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                      style: const TextStyle(
                          color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Latitude',
                        prefixIcon: Icon(Icons.my_location,
                            color: AppTheme.textMuted, size: 18),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Required';
                        if (double.tryParse(v) == null)
                          return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                      style: const TextStyle(
                          color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Longitude',
                        prefixIcon: Icon(Icons.my_location,
                            color: AppTheme.textMuted, size: 18),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Required';
                        if (double.tryParse(v) == null)
                          return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Helper text for coordinates
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.accentGold.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.accentGold.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Kigali center: Lat -1.9403, Lng 29.8739. You can get coordinates from Google Maps.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryDark,
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'Update Listing'
                              : 'Create Listing',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
