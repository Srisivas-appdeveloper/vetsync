import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/animal_repository.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';

/// Add new pet page
class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final AnimalRepository _animalRepo = Get.find<AnimalRepository>();
  final SessionController _sessionController = Get.find<SessionController>();

  // Form
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final ownerPhoneController = TextEditingController();
  final ownerEmailController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();
  final notesController = TextEditingController();

  // State
  final Rx<Species> species = Species.dog.obs;
  final RxString breed = ''.obs;
  final Rx<Sex> sex = Sex.male.obs;
  final RxBool isLoading = false.obs;

  @override
  void dispose() {
    nameController.dispose();
    ownerNameController.dispose();
    ownerPhoneController.dispose();
    ownerEmailController.dispose();
    weightController.dispose();
    ageController.dispose();
    notesController.dispose();
    super.dispose();
  }

  List<String> get breedList {
    switch (species.value) {
      case Species.dog:
        return DogBreeds.all;
      case Species.cat:
        return CatBreeds.all;
      default:
        return ['Other'];
    }
  }

  Future<void> _savePet() async {
    if (!formKey.currentState!.validate()) return;

    if (breed.isEmpty) {
      Get.snackbar('Error', 'Please select a breed');
      return;
    }

    isLoading.value = true;

    try {
      final animal = await _animalRepo.createAnimal(
        name: nameController.text.trim(),
        species: species.value,
        breed: breed.value,
        age: double.tryParse(ageController.text) ?? 1.0,
        weightKg: double.tryParse(weightController.text) ?? 10.0,
        sex: sex.value,
        ownerName: ownerNameController.text.trim(),
        ownerPhone: ownerPhoneController.text.trim().isEmpty
            ? null
            : ownerPhoneController.text.trim(),
        ownerEmail: ownerEmailController.text.trim().isEmpty
            ? null
            : ownerEmailController.text.trim(),
        medicalNotes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      _sessionController.currentAnimal.value = animal;
      Get.offNamed(Routes.collarScan);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create pet');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add New Pet')),
      body: Obx(
        () => LoadingOverlay(
          isLoading: isLoading.value,
          message: 'Saving...',
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Species selection
                  Text('Species', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  Obx(
                    () => SegmentedButton<Species>(
                      segments: Species.values
                          .map(
                            (s) => ButtonSegment(
                              value: s,
                              label: Text(s.displayName),
                              icon: Icon(
                                s == Species.dog
                                    ? Icons.pets
                                    : s == Species.cat
                                    ? Icons.cruelty_free
                                    : Icons.help,
                              ),
                            ),
                          )
                          .toList(),
                      selected: {species.value},
                      onSelectionChanged: (value) {
                        species.value = value.first;
                        breed.value = '';
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pet name
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name *',
                      hintText: 'e.g., Max',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pet name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Breed
                  Text('Breed *', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: breed.value.isEmpty ? null : breed.value,
                      hint: const Text('Select breed'),
                      items: breedList
                          .map(
                            (b) => DropdownMenuItem(value: b, child: Text(b)),
                          )
                          .toList(),
                      onChanged: (value) => breed.value = value ?? '',
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Age and Weight row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age (years) *',
                            hintText: 'e.g., 5',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final age = double.tryParse(value);
                            if (age == null || age < 0 || age > 30) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg) *',
                            hintText: 'e.g., 25',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0 || weight > 150) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sex
                  Text('Sex', style: AppTypography.labelMedium),
                  const SizedBox(height: 8),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      children: Sex.values
                          .map(
                            (s) => ChoiceChip(
                              label: Text(s.displayName),
                              selected: sex.value == s,
                              onSelected: (_) => sex.value = s,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Owner info
                  Text('Owner Information', style: AppTypography.titleSmall),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: ownerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Owner Name *',
                      hintText: 'e.g., John Smith',
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Owner name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: ownerPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      hintText: 'e.g., +1 555 123 4567',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: ownerEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
                      hintText: 'e.g., john@example.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !GetUtils.isEmail(value)) {
                        return 'Enter valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Medical notes
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Medical Notes (optional)',
                      hintText: 'Any relevant medical history...',
                      prefixIcon: Icon(Icons.medical_information),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  ElevatedButton(
                    onPressed: _savePet,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save & Continue'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
