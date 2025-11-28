// account_type_selection_widget.dart
import 'package:brickapp/models/user_model.dart';
import 'package:brickapp/providers/account_type_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/account_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountTypeSelectionWidget extends ConsumerWidget {
  const AccountTypeSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAccountType = ref.watch(userProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Account Type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildAccountTypeChip(
              context: context,
              ref: ref,
              type: AccountType.regular,
              label: 'Regular Client',
              isSelected: selectedAccountType == AccountType.regular,
            ),
            _buildAccountTypeChip(
              context: context,
              ref: ref,
              type: AccountType.transportServiceProvider,
              label: 'Transport Manager',
              isSelected:
                  selectedAccountType == AccountType.transportServiceProvider,
            ),
            _buildAccountTypeChip(
              context: context,
              ref: ref,
              type: AccountType.propertyOwner,
              label: 'Property Manager',
              isSelected: selectedAccountType == AccountType.propertyOwner,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountTypeChip({
    required BuildContext context,
    required WidgetRef ref,
    required AccountType type,
    required String label,
    required bool isSelected,
  }) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          ref.read(userProvider.notifier).updateAccountType(type);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}
