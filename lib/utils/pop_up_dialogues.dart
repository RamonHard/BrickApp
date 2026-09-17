import 'package:brickapp/models/property_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BrickContactDialog extends StatelessWidget {
  const BrickContactDialog({
    super.key,
    required this.property,
    this.contactName = 'Ramon Estates',
    this.contactPhone = '0793568423',
    this.dialogTitle = 'Purchase Enquiry',
    this.contactPrompt = 'Contact us for this property:',
  });

  final PropertyModel property;
  final String contactName;
  final String contactPhone;
  final String dialogTitle;
  final String contactPrompt;

  /// Convenience helper to show this dialog
  static Future<void> show(
    BuildContext context, {
    required PropertyModel property,
    String contactName = 'Ramon Estates',
    String contactPhone = '0793568423',
    String dialogTitle = 'Purchase Enquiry',
    String contactPrompt = 'Contact us for this property:',
  }) {
    return showDialog(
      context: context,
      builder: (_) => BrickContactDialog(
        property: property,
        contactName: contactName,
        contactPhone: contactPhone,
        dialogTitle: dialogTitle,
        contactPrompt: contactPrompt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Sale Price ───────────────────────────────
            if (property.salePrice != null && property.salePrice! > 0)
              Text(
                'UGX ${NumberFormat('#,###').format(property.salePrice)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                overflow: TextOverflow.ellipsis,
              ),

            // ─── Sale Conditions ──────────────────────────
            if (property.saleConditions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Conditions: ${property.saleConditions}',
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // ─── Contact Prompt ───────────────────────────
            Text(
              contactPrompt,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // ─── Contact Name ─────────────────────────────
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    contactName.isNotEmpty ? contactName : 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ─── Contact Phone ────────────────────────────
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    contactPhone.isNotEmpty ? contactPhone : 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}