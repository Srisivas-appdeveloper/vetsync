import 'enums.dart';
import 'vital_ranges.dart';

/// Animal (pet) model
class Animal {
  final String id;
  final String name;
  final Species species;
  final String breed;
  final DateTime dateOfBirth;
  final double weightKg;
  final Sex sex;
  final String? microchipNumber;
  final String? color;
  final List<String>? medicalConditions;
  final List<String>? allergies;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final String? medicalNotes;
  final String organizationId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.dateOfBirth,
    required this.weightKg,
    required this.sex,
    this.microchipNumber,
    this.color,
    this.medicalConditions,
    this.allergies,
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.medicalNotes,
    required this.organizationId,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate age in years from date of birth
  double get ageYears {
    final now = DateTime.now();
    final difference = now.difference(dateOfBirth);
    return difference.inDays / 365.25;
  }

  /// Get breed-specific vital ranges for this animal
  VitalRanges get vitalRanges {
    return VitalRanges.forBreed(
      species: species,
      breed: breed,
      weightKg: weightKg,
      ageYears: ageYears,
    );
  }

  /// Get age display string
  String get ageDisplay {
    final years = ageYears;
    if (years < 1) {
      final months = (years * 12).round();
      return '$months month${months == 1 ? '' : 's'}';
    }
    final wholeYears = years.floor();
    final months = ((years - wholeYears) * 12).round();
    if (months == 0) {
      return '$wholeYears year${wholeYears == 1 ? '' : 's'}';
    }
    return '$wholeYears yr ${months} mo';
  }

  /// Get date of birth display string
  String get dateOfBirthDisplay {
    return '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}';
  }

  /// Get weight display string
  String get weightDisplay => '${weightKg.toStringAsFixed(1)} kg';

  /// Get sex icon
  String get sexIcon {
    switch (sex) {
      case Sex.male:
        return '♂';
      case Sex.female:
        return '♀';
      case Sex.neutered:
      case Sex.neuteredMale:
        return '♂✓';
      case Sex.spayed:
      case Sex.spayedFemale:
        return '♀✓';
    }
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    // Handle ID - can be int or string
    String id;
    if (json['animal_id'] != null) {
      id = json['animal_id'].toString();
    } else if (json['id'] != null) {
      id = json['id'].toString();
    } else {
      id = '';
    }

    // Handle organization/clinic ID
    String orgId;
    if (json['organization_id'] != null) {
      orgId = json['organization_id'].toString();
    } else if (json['clinic_id'] != null) {
      orgId = json['clinic_id'].toString();
    } else {
      orgId = '';
    }

    // Handle date of birth - could be string or might have age_years for backwards compatibility
    DateTime dob;
    if (json['date_of_birth'] != null) {
      dob = DateTime.parse(json['date_of_birth'] as String);
    } else if (json['age_years'] != null) {
      // Backwards compatibility: calculate DOB from age
      final ageYears = (json['age_years'] as num).toDouble();
      dob = DateTime.now().subtract(
        Duration(days: (ageYears * 365.25).round()),
      );
    } else {
      dob = DateTime.now();
    }

    // Handle timestamps
    DateTime createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at'] as String);
    } else {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    if (json['updated_at'] != null) {
      updatedAt = DateTime.parse(json['updated_at'] as String);
    } else {
      updatedAt = DateTime.now();
    }

    // Handle medical conditions and allergies lists
    List<String>? medicalConditions;
    if (json['medical_conditions'] != null) {
      medicalConditions = (json['medical_conditions'] as List)
          .map((e) => e.toString())
          .toList();
    }

    List<String>? allergies;
    if (json['allergies'] != null) {
      allergies = (json['allergies'] as List).map((e) => e.toString()).toList();
    }

    return Animal(
      id: id,
      name: json['name'] as String? ?? '',
      species: Species.fromString(json['species'] as String? ?? 'canine'),
      breed: json['breed'] as String? ?? '',
      dateOfBirth: dob,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      sex: Sex.fromString(json['sex'] as String? ?? 'male'),
      microchipNumber: json['microchip_number'] as String?,
      color: json['color'] as String?,
      medicalConditions: medicalConditions,
      allergies: allergies,
      ownerName: json['owner_name'] as String?,
      ownerPhone: json['owner_phone'] as String?,
      ownerEmail: json['owner_email'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      organizationId: orgId,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species.value,
      'breed': breed,
      'date_of_birth': dateOfBirthDisplay,
      'weight_kg': weightKg,
      'sex': sex.value,
      if (microchipNumber != null) 'microchip_number': microchipNumber,
      if (color != null) 'color': color,
      if (medicalConditions != null) 'medical_conditions': medicalConditions,
      if (allergies != null) 'allergies': allergies,
      if (ownerName != null) 'owner_name': ownerName,
      if (ownerPhone != null) 'owner_phone': ownerPhone,
      if (ownerEmail != null) 'owner_email': ownerEmail,
      if (medicalNotes != null) 'medical_notes': medicalNotes,
    };
  }

  /// Full JSON including all fields (for storage)
  Map<String, dynamic> toFullJson() {
    return {
      'animal_id': id,
      'name': name,
      'species': species.value,
      'breed': breed,
      'date_of_birth': dateOfBirthDisplay,
      'weight_kg': weightKg,
      'sex': sex.value,
      'microchip_number': microchipNumber,
      'color': color,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'owner_email': ownerEmail,
      'medical_notes': medicalNotes,
      'organization_id': organizationId,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Animal copyWith({
    String? id,
    String? name,
    Species? species,
    String? breed,
    DateTime? dateOfBirth,
    double? weightKg,
    Sex? sex,
    String? microchipNumber,
    String? color,
    List<String>? medicalConditions,
    List<String>? allergies,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? medicalNotes,
    String? organizationId,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
      sex: sex ?? this.sex,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      color: color ?? this.color,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      organizationId: organizationId ?? this.organizationId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Animal(id: $id, name: $name, breed: $breed)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Animal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
