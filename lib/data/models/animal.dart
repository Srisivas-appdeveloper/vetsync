import 'enums.dart';
import 'vital_ranges.dart';

/// Animal (pet) model
class Animal {
  final String id;
  final String name;
  final Species species;
  final String breed;
  final double ageYears;
  final double weightKg;
  final Sex sex;
  final String ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final String? medicalNotes;
  final String clinicId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    required this.sex,
    required this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.medicalNotes,
    required this.clinicId,
    required this.createdAt,
    required this.updatedAt,
  });
  
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
    if (ageYears < 1) {
      final months = (ageYears * 12).round();
      return '$months month${months == 1 ? '' : 's'}';
    }
    final years = ageYears.floor();
    final months = ((ageYears - years) * 12).round();
    if (months == 0) {
      return '$years year${years == 1 ? '' : 's'}';
    }
    return '$years yr ${months} mo';
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
        return '♂✓';
      case Sex.spayed:
        return '♀✓';
    }
  }
  
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['animal_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      species: Species.fromString(json['species'] as String),
      breed: json['breed'] as String,
      ageYears: (json['age_years'] as num).toDouble(),
      weightKg: (json['weight_kg'] as num).toDouble(),
      sex: Sex.fromString(json['sex'] as String),
      ownerName: json['owner_name'] as String,
      ownerPhone: json['owner_phone'] as String?,
      ownerEmail: json['owner_email'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      clinicId: json['clinic_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'animal_id': id,
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
      'clinic_id': clinicId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Animal copyWith({
    String? id,
    String? name,
    Species? species,
    String? breed,
    double? ageYears,
    double? weightKg,
    Sex? sex,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? medicalNotes,
    String? clinicId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      sex: sex ?? this.sex,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      clinicId: clinicId ?? this.clinicId,
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
