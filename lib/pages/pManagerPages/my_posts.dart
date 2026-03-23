import 'package:brickapp/custom_widgets/post_item_widget.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:brickapp/pages/pManagerPages/edit_post.dart';
import 'package:brickapp/pages/pManagerPages/post_preview.dart';
import 'package:brickapp/providers/product_provider.dart';
import 'package:brickapp/providers/property_providers.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class MyPostsPage extends ConsumerWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(userProvider).token ?? '';
    final myListingsAsync = ref.watch(myListingsFamilyProvider(token));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Property Posts',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: myListingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load your listings'),
                  TextButton(
                    onPressed:
                        () => ref.refresh(myListingsFamilyProvider(token)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data: (listings) {
          // Sync into productProvider so EditPost can use it
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(productProvider.notifier).setProducts(listings);
          });

          if (listings.isEmpty) {
            return const Center(
              child: Text('No posts yet. Tap + to add your first property!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return PostListItem(
                property: listings[index],
                publicState: listings[index].status == 'active',
              );
            },
          );
        },
      ),
    );
  }
}
