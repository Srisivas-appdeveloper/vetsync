import 'package:drift/drift.dart';
import 'package:get/get.dart' hide Value;

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';
import '../../core/constants/app_config.dart';

/// Animal repository
class AnimalRepository {
  final ApiService _api = Get.find<ApiService>();
  final DatabaseService _database = Get.find<DatabaseService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  
  /// Search animals
  Future<List<Animal>> searchAnimals(String query) async {
    if (_connectivity.isOnline.value) {
      try {
        final response = await _api.get(
          ApiEndpoints.searchAnimals,
          queryParameters: {'q': query, 'limit': 20},
        );
        
        final animals = (response.data['animals'] as List)
            .map((json) => Animal.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Cache the results
        for (final animal in animals) {
          await _cacheAnimal(animal);
        }
        
        return animals;
      } catch (e) {
        // Fall back to cache on error
        return _searchCachedAnimals(query);
      }
    } else {
      return _searchCachedAnimals(query);
    }
  }
  
  /// Get recent animals
  Future<List<Animal>> getRecentAnimals() async {
    if (_connectivity.isOnline.value) {
      try {
        final response = await _api.get(
          ApiEndpoints.recentAnimals,
          queryParameters: {'limit': AppConfig.maxRecentAnimals},
        );
        
        final animals = (response.data['animals'] as List)
            .map((json) => Animal.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Cache the results
        for (final animal in animals) {
          await _cacheAnimal(animal);
        }
        
        return animals;
      } catch (e) {
        return _getRecentCachedAnimals();
      }
    } else {
      return _getRecentCachedAnimals();
    }
  }
  
  /// Get animal by ID
  Future<Animal?> getAnimal(String id) async {
    if (_connectivity.isOnline.value) {
      try {
        final response = await _api.get(ApiEndpoints.animal(id));
        final animal = Animal.fromJson(response.data as Map<String, dynamic>);
        await _cacheAnimal(animal);
        return animal;
      } catch (e) {
        return _getCachedAnimal(id);
      }
    } else {
      return _getCachedAnimal(id);
    }
  }
  
  /// Create new animal
  Future<Animal> createAnimal({
    required String name,
    required Species species,
    required String breed,
    required double ageYears,
    required double weightKg,
    required Sex sex,
    required String ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? medicalNotes,
  }) async {
    final response = await _api.post(
      ApiEndpoints.animals,
      data: {
        'name': name,
        'species': species.value,
        'breed': breed,
        'age_years': ageYears,
        'weight_kg': weightKg,
        'sex': sex.value,
        'owner_name': ownerName,
        'owner_phone': ownerPhone,
        'owner_email': ownerEmail,
        'medical_notes': medicalNotes,
      },
    );
    
    final animal = Animal.fromJson(response.data as Map<String, dynamic>);
    await _cacheAnimal(animal);
    return animal;
  }
  
  /// Update animal
  Future<Animal> updateAnimal(String id, Map<String, dynamic> updates) async {
    final response = await _api.patch(
      ApiEndpoints.animal(id),
      data: updates,
    );
    
    final animal = Animal.fromJson(response.data as Map<String, dynamic>);
    await _cacheAnimal(animal);
    return animal;
  }
  
  // ============================================================
  // Cache Operations
  // ============================================================
  
  Future<void> _cacheAnimal(Animal animal) async {
    await _database.db.cacheAnimal(CachedAnimalsCompanion(
      id: Value(animal.id),
      name: Value(animal.name),
      species: Value(animal.species.value),
      breed: Value(animal.breed),
      ageYears: Value(animal.ageYears),
      weightKg: Value(animal.weightKg),
      sex: Value(animal.sex.value),
      ownerName: Value(animal.ownerName),
      ownerPhone: Value(animal.ownerPhone),
      clinicId: Value(animal.clinicId),
      cachedAt: Value(DateTime.now()),
    ));
  }
  
  Future<List<Animal>> _searchCachedAnimals(String query) async {
    final cached = await _database.db.searchCachedAnimals(query);
    return cached.map(_cachedToAnimal).toList();
  }
  
  Future<List<Animal>> _getRecentCachedAnimals() async {
    final cached = await _database.db.getRecentAnimals(limit: AppConfig.maxRecentAnimals);
    return cached.map(_cachedToAnimal).toList();
  }
  
  Future<Animal?> _getCachedAnimal(String id) async {
    final cached = await _database.db.getCachedAnimalById(id);
    if (cached == null) return null;
    return _cachedToAnimal(cached);
  }
  
  Animal _cachedToAnimal(CachedAnimal cached) {
    return Animal(
      id: cached.id,
      name: cached.name,
      species: Species.fromString(cached.species),
      breed: cached.breed,
      ageYears: cached.ageYears,
      weightKg: cached.weightKg,
      sex: Sex.fromString(cached.sex),
      ownerName: cached.ownerName,
      ownerPhone: cached.ownerPhone,
      clinicId: cached.clinicId,
      createdAt: cached.cachedAt,
      updatedAt: cached.cachedAt,
    );
  }
}
