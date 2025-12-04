import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/pet_selection_controller.dart';
import '../../widgets/common_widgets.dart';

/// Pet selection screen - Step 2 of session flow
class PetSelectionPage extends GetView<PetSelectionController> {
  const PetSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Pet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.addNewPet,
            tooltip: 'Add New Pet',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          
          // Results
          Expanded(
            child: Obx(() => _buildContent()),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: AppSpacing.screenPadding,
      color: AppColors.surface,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search by pet name or owner...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (controller.isSearching.value) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }
    
    final animals = controller.displayedAnimals;
    
    if (animals.isEmpty) {
      if (controller.isShowingSearchResults) {
        return const EmptyState(
          icon: Icons.search_off,
          title: 'No results found',
          subtitle: 'Try a different search term or add a new pet',
        );
      }
      return EmptyState(
        icon: Icons.pets,
        title: 'No recent pets',
        subtitle: 'Search for a pet or add a new one',
        action: ElevatedButton.icon(
          onPressed: controller.addNewPet,
          icon: const Icon(Icons.add),
          label: const Text('Add New Pet'),
        ),
      );
    }
    
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: animals.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              controller.isShowingSearchResults 
                  ? 'Search Results (${animals.length})'
                  : 'Recent Pets',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        
        final animal = animals[index - 1];
        return _PetCard(
          animal: animal,
          onTap: () => controller.selectAnimal(animal),
        );
      },
    );
  }
}

/// Pet card widget
class _PetCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  
  const _PetCard({
    required this.animal,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: animal.species == Species.dog 
                      ? AppColors.primarySurface 
                      : AppColors.secondaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  animal.species == Species.dog ? Icons.pets : Icons.cruelty_free,
                  color: animal.species == Species.dog 
                      ? AppColors.primary 
                      : AppColors.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          animal.name,
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          animal.sexIcon,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${animal.breed} • ${animal.ageDisplay}',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Owner: ${animal.ownerName}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              
              // Weight chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  animal.weightDisplay,
                  style: AppTypography.labelSmall,
                ),
              ),
              const SizedBox(width: 8),
              
              // Arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
