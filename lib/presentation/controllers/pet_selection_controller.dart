import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../data/models/models.dart';
import '../../data/repositories/animal_repository.dart';
import 'session_controller.dart';

/// Controller for pet selection screen
class PetSelectionController extends GetxController {
  final AnimalRepository _animalRepo = Get.find<AnimalRepository>();
  final SessionController _sessionController = Get.find<SessionController>();

  // Search
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounceTimer;

  // State
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxList<Animal> searchResults = <Animal>[].obs;
  final RxList<Animal> recentAnimals = <Animal>[].obs;
  final Rx<Animal?> selectedAnimal = Rx<Animal?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadRecentAnimals();

    // Setup search debounce
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Load recently used animals
  Future<void> _loadRecentAnimals() async {
    isLoading.value = true;
    try {
      final animals = await _animalRepo.getRecentAnimals();
      recentAnimals.value = animals;
    } catch (e) {
      // Use cached data
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle search input changes with debounce
  void _onSearchChanged() {
    final query = searchController.text.trim();

    _debounceTimer?.cancel();

    if (query.isEmpty) {
      searchQuery.value = '';
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    searchQuery.value = query;

    // Debounce search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  /// Perform search
  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;

    try {
      final results = await _animalRepo.searchAnimals(query);
      searchResults.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isSearching.value = false;
    }
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  /// Select an animal
  void selectAnimal(Animal animal) {
    selectedAnimal.value = animal;
    _sessionController.currentAnimal.value = animal;

    // Navigate to collar scan
    Get.toNamed(Routes.collarScan);
  }

  /// Navigate to add new pet
  void addNewPet() {
    Get.toNamed(Routes.addPet);
  }

  /// Check if animal is displayed (in search results or recent)
  List<Animal> get displayedAnimals {
    if (searchQuery.isNotEmpty) {
      return searchResults;
    }
    return recentAnimals;
  }

  /// Check if showing search results
  bool get isShowingSearchResults => searchQuery.isNotEmpty;
}

/// Controller for Add Pet screen
class AddPetController extends GetxController {
  final AnimalRepository _animalRepo = Get.find<AnimalRepository>();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final nameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final ownerPhoneController = TextEditingController();
  final ownerEmailController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();
  final notesController = TextEditingController();

  // Form state
  final Rx<Species> species = Species.dog.obs;
  final RxString breed = ''.obs;
  final Rx<Sex> sex = Sex.male.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    ownerNameController.dispose();
    ownerPhoneController.dispose();
    ownerEmailController.dispose();
    weightController.dispose();
    ageController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Get breed list based on species
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

  /// Save new pet
  Future<void> savePet() async {
    if (!formKey.currentState!.validate()) return;

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

      // Select the new pet and go to collar scan
      final sessionController = Get.find<SessionController>();
      sessionController.currentAnimal.value = animal;

      Get.offNamed(Routes.collarScan);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create pet');
    } finally {
      isLoading.value = false;
    }
  }

  // Validators
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pet name is required';
    }
    return null;
  }

  String? validateOwnerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner name is required';
    }
    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0 || weight > 150) {
      return 'Enter valid weight (0-150 kg)';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = double.tryParse(value);
    if (age == null || age < 0 || age > 30) {
      return 'Enter valid age (0-30 years)';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    if (!GetUtils.isEmail(value)) {
      return 'Enter valid email';
    }
    return null;
  }
}
