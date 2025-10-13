import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ClientHistoryWidget extends StatelessWidget {
  const ClientHistoryWidget({
    super.key,
    required this.img,
    required this.clientName,
    required this.itemName,
    required this.itemID,
    required this.time,
    required this.amount,
    required this.transactionType, // 'rental' or 'purchase'
    required this.duration, // For rentals: '3 days', '1 week', etc.
    required this.paymentMethod,
    required this.transactionDate,
    required this.dueDate, // For rentals
    required this.depositAmount,
    required this.taxAmount,
    required this.transactionId,
    this.clientPhone,
    this.clientEmail,
    this.itemCondition,
    this.notes,
  });

  final String img;
  final String clientName;
  final String itemName;
  final int itemID;
  final String time;
  final double amount;
  final String transactionType; // 'rental' or 'purchase'
  final String duration; // Rental period
  final String paymentMethod;
  final DateTime transactionDate;
  final DateTime dueDate; // For rental returns
  final double depositAmount;
  final double taxAmount;
  final String transactionId;
  final String? clientPhone;
  final String? clientEmail;
  final String? itemCondition;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.darkTextColor;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final primaryColor = theme.primaryColor;
    final isRental = transactionType == 'rental';

    // Format amounts
    final formattedAmount = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    ).format(amount);

    final formattedDeposit = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    ).format(depositAmount);

    final formattedTax = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    ).format(taxAmount);

    final subtotal = amount - taxAmount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with receipt title and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRental ? "RENTAL RECEIPT" : "SALES RECEIPT",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isRental
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isRental ? "RENTAL" : "PURCHASE",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isRental ? Colors.blue : Colors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Transaction ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Receipt No:",
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                      Text(
                        transactionId,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Date:",
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(transactionDate),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Client Information Section
              _SectionHeader(title: "CLIENT INFORMATION"),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Client Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 23,
                      backgroundImage: NetworkImage(img),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Client Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (clientPhone != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            clientPhone!,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                        if (clientEmail != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            clientEmail!,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Item Information Section
              _SectionHeader(title: "ITEM DETAILS"),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Item Name",
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                itemName,
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Item ID",
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                            Text(
                              "#$itemID",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (itemCondition != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "Condition: ",
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            itemCondition!,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isRental) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rental Period:",
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            duration,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Due Date:",
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(dueDate),
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Payment Information Section
              _SectionHeader(title: "PAYMENT INFORMATION"),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    // Payment Breakdown
                    _PaymentRow(
                      label: "Subtotal:",
                      amount: subtotal,
                      isTotal: false,
                    ),
                    _PaymentRow(
                      label: "Tax (VAT):",
                      amount: taxAmount,
                      isTotal: false,
                    ),
                    if (isRental && depositAmount > 0)
                      _PaymentRow(
                        label: "Security Deposit:",
                        amount: depositAmount,
                        isTotal: false,
                      ),
                    const Divider(height: 20),
                    _PaymentRow(
                      label: "Total Amount:",
                      amount: amount + (isRental ? depositAmount : 0),
                      isTotal: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Method:",
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            paymentMethod.toUpperCase(),
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Notes Section (if any)
              if (notes != null && notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _SectionHeader(title: "NOTES"),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Text(
                    notes!,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Thank you for your business!",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget for section headers
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Helper widget for payment rows
class _PaymentRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const _PaymentRow({
    required this.label,
    required this.amount,
    required this.isTotal,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    ).format(amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.green : Colors.grey[600],
            ),
          ),
          Text(
            formattedAmount,
            style: GoogleFonts.roboto(
              fontSize: isTotal ? 16 : 12,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? Colors.green : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
