import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/edit_post.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class PostPreviewPage extends StatelessWidget {
  final PropertyModel property;

  const PostPreviewPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "en_US");
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Property Preview',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to EditPostPage
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (context) => EditPostPage(editPostModel: property),
              // ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            _buildImageSection(),
            const SizedBox(height: 20),

            // Property Status Badge
            _buildStatusBadge(),
            const SizedBox(height: 16),

            // Property Title and Price
            _buildTitleAndPrice(currencyFormatter),
            const SizedBox(height: 12),

            // Location
            _buildLocationSection(),
            const SizedBox(height: 16),

            // Listing Type
            _buildListingTypeSection(),
            const SizedBox(height: 20),

            // Basic Information
            _buildBasicInfoSection(),
            const SizedBox(height: 20),

            // Amenities
            if (property.amenities != null && property.amenities!.isNotEmpty)
              _buildAmenitiesSection(),

            // Description
            _buildDescriptionSection(),
            const SizedBox(height: 20),

            // Price Details
            _buildPriceDetails(currencyFormatter),
            const SizedBox(height: 20),

            // Upload Information
            _buildUploadInfo(dateFormatter),
            const SizedBox(height: 20),

            // Action Button
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child:
          property.productIMG != null && property.productIMG!.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property.productIMG!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.home,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      ),
                ),
              )
              : Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: property.isActive ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: property.isActive ? Colors.green[100]! : Colors.orange[100]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            property.isActive ? Icons.check_circle : Icons.pending,
            size: 14,
            color: property.isActive ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            property.isActive ? 'Active Listing' : 'Pending Review',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: property.isActive ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndPrice(NumberFormat currencyFormatter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.propertyType ?? 'Property',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextColor,
                ),
              ),
              if (property.propertyType != null &&
                  property.propertyType!.isNotEmpty)
                Text(
                  property.propertyType!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (property.isRent && property.price != null)
              Text(
                'UGX ${currencyFormatter.format(property.price)}/month',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
            if (property.isSale && property.enteredSalePrice != null)
              Text(
                'UGX ${currencyFormatter.format(property.enteredSalePrice)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            if (property.discount != null && property.discount! > 0)
              Text(
                'UGX ${currencyFormatter.format(property.discount)} discount',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            property.location ?? 'Location not specified',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildListingTypeSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (property.isRent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  'For Rent',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                if (property.package != null)
                  Text(
                    ' • ${property.package}',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
              ],
            ),
          ),
        if (property.isSale)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'For Sale',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                if (property.saleConditions != null &&
                    property.saleConditions!.isNotEmpty)
                  Text(
                    ' • ${property.saleConditions}',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
              ],
            ),
          ),
        if (property.isRent && property.isSale)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange[100]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business_center, size: 14, color: Colors.orange),
                const SizedBox(width: 6),
                Text(
                  'Both Rent & Sale',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              if (property.bedrooms != null && property.bedrooms! > 0)
                _buildInfoItem(Icons.bed, '${property.bedrooms} Bedrooms'),
              if (property.baths != null && property.baths! > 0)
                _buildInfoItem(Icons.bathroom, '${property.baths} Bathrooms'),
              if (property.sqft != null && property.sqft! > 0)
                _buildInfoItem(Icons.square_foot, '${property.sqft} sq ft'),
              if (property.units != null && property.units! > 0)
                _buildInfoItem(Icons.apartment, '${property.units} Units'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                property.amenities!.map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      amenity,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            property.description ?? 'No description provided',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          if (property.isRent)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow(
                  'Monthly Rent',
                  property.price,
                  currencyFormatter,
                ),
                if (property.discount != null && property.discount! > 0)
                  _buildPriceRow(
                    'Discount',
                    property.discount,
                    currencyFormatter,
                  ),
                if (property.commission != null && property.commission! > 0)
                  _buildPriceRow(
                    'Commission',
                    property.commission,
                    currencyFormatter,
                  ),
              ],
            ),
          if (property.isRent && property.isSale) const Divider(),
          if (property.isSale)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow(
                  'Sale Price',
                  property.enteredSalePrice,
                  currencyFormatter,
                ),
                if (property.saleConditions != null &&
                    property.saleConditions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Conditions: ${property.saleConditions}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double? amount,
    NumberFormat currencyFormatter,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            amount != null ? 'UGX ${currencyFormatter.format(amount)}' : 'N/A',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: label.contains('Discount') ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadInfo(DateFormat dateFormatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          if (property.uploaderName != null)
            _buildInfoRow('Uploaded by', property.uploaderName!),
          if (property.dateCreated != null)
            _buildInfoRow(
              'Date Posted',
              dateFormatter.format(property.dateCreated!),
            ),
          if (property.uploaderPhoneNumber != null)
            _buildInfoRow('Contact', property.uploaderPhoneNumber!.toString()),
          if (property.pendingReason != null &&
              property.pendingReason!.isNotEmpty)
            _buildInfoRow('Pending Reason', property.pendingReason!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to EditPostPage
          Navigator.pop(context); // Close preview first
          // Then navigate to edit page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPost(property: property),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.iconColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Edit This Post',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
