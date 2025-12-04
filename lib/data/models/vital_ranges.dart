import 'enums.dart';

/// Range definition for a vital sign
class VitalRange {
  final double min;
  final double max;
  
  const VitalRange({required this.min, required this.max});
  
  /// Check if a value is within range
  bool isInRange(double value) => value >= min && value <= max;
  
  /// Check if a value is below range
  bool isBelowRange(double value) => value < min;
  
  /// Check if a value is above range
  bool isAboveRange(double value) => value > max;
  
  /// Get the midpoint of the range
  double get midpoint => (min + max) / 2;
  
  /// Get range display string
  String get displayString => '${min.toInt()}-${max.toInt()}';
  
  @override
  String toString() => 'VitalRange($min - $max)';
}

/// Vital ranges for an animal based on species, breed, weight, and age
class VitalRanges {
  final VitalRange heartRate;
  final VitalRange respiratoryRate;
  final VitalRange temperature;
  
  const VitalRanges({
    required this.heartRate,
    required this.respiratoryRate,
    required this.temperature,
  });
  
  /// Get breed-specific vital ranges
  factory VitalRanges.forBreed({
    required Species species,
    required String breed,
    required double weightKg,
    required double ageYears,
  }) {
    // Cat ranges
    if (species == Species.cat) {
      return const VitalRanges(
        heartRate: VitalRange(min: 120, max: 180),
        respiratoryRate: VitalRange(min: 20, max: 40),
        temperature: VitalRange(min: 38.0, max: 39.2),
      );
    }
    
    // Dog ranges - based on weight categories
    // Small dogs (<10kg)
    if (weightKg < 10) {
      return _adjustForAge(
        base: const VitalRanges(
          heartRate: VitalRange(min: 80, max: 140),
          respiratoryRate: VitalRange(min: 15, max: 30),
          temperature: VitalRange(min: 38.0, max: 39.2),
        ),
        ageYears: ageYears,
      );
    }
    
    // Medium dogs (10-25kg)
    if (weightKg < 25) {
      return _adjustForAge(
        base: const VitalRanges(
          heartRate: VitalRange(min: 70, max: 120),
          respiratoryRate: VitalRange(min: 14, max: 22),
          temperature: VitalRange(min: 38.0, max: 39.2),
        ),
        ageYears: ageYears,
      );
    }
    
    // Large dogs (25-45kg)
    if (weightKg < 45) {
      return _adjustForAge(
        base: const VitalRanges(
          heartRate: VitalRange(min: 60, max: 100),
          respiratoryRate: VitalRange(min: 10, max: 20),
          temperature: VitalRange(min: 37.5, max: 39.0),
        ),
        ageYears: ageYears,
      );
    }
    
    // Giant dogs (>45kg)
    return _adjustForAge(
      base: const VitalRanges(
        heartRate: VitalRange(min: 50, max: 90),
        respiratoryRate: VitalRange(min: 8, max: 18),
        temperature: VitalRange(min: 37.5, max: 39.0),
      ),
      ageYears: ageYears,
    );
  }
  
  /// Adjust ranges for age (puppies have higher heart rates)
  static VitalRanges _adjustForAge({
    required VitalRanges base,
    required double ageYears,
  }) {
    // Puppies (<1 year) have higher heart rates
    if (ageYears < 1) {
      return VitalRanges(
        heartRate: VitalRange(
          min: base.heartRate.min + 20,
          max: base.heartRate.max + 40,
        ),
        respiratoryRate: VitalRange(
          min: base.respiratoryRate.min + 5,
          max: base.respiratoryRate.max + 10,
        ),
        temperature: base.temperature,
      );
    }
    
    // Senior dogs (>8 years) may have slightly different ranges
    if (ageYears > 8) {
      return VitalRanges(
        heartRate: VitalRange(
          min: base.heartRate.min - 5,
          max: base.heartRate.max + 10,
        ),
        respiratoryRate: base.respiratoryRate,
        temperature: base.temperature,
      );
    }
    
    return base;
  }
  
  /// Default dog ranges (medium-sized adult)
  static const VitalRanges defaultDog = VitalRanges(
    heartRate: VitalRange(min: 70, max: 120),
    respiratoryRate: VitalRange(min: 14, max: 22),
    temperature: VitalRange(min: 38.0, max: 39.2),
  );
  
  /// Default cat ranges
  static const VitalRanges defaultCat = VitalRanges(
    heartRate: VitalRange(min: 120, max: 180),
    respiratoryRate: VitalRange(min: 20, max: 40),
    temperature: VitalRange(min: 38.0, max: 39.2),
  );
  
  @override
  String toString() => 'VitalRanges(HR: $heartRate, RR: $respiratoryRate, T: $temperature)';
}

/// Common dog breeds for selection dropdown
class DogBreeds {
  DogBreeds._();
  
  static const List<String> small = [
    'Chihuahua',
    'Yorkshire Terrier',
    'Pomeranian',
    'Maltese',
    'Shih Tzu',
    'Pug',
    'French Bulldog',
    'Dachshund',
    'Miniature Pinscher',
    'Papillon',
    'Cavalier King Charles Spaniel',
    'Jack Russell Terrier',
    'Boston Terrier',
    'Miniature Schnauzer',
    'Toy Poodle',
  ];
  
  static const List<String> medium = [
    'Beagle',
    'Border Collie',
    'Cocker Spaniel',
    'Bulldog',
    'Australian Shepherd',
    'Basset Hound',
    'Shetland Sheepdog',
    'Brittany',
    'American Staffordshire Terrier',
    'Whippet',
    'Standard Schnauzer',
    'Welsh Corgi',
    'Miniature Poodle',
    'Bull Terrier',
  ];
  
  static const List<String> large = [
    'Labrador Retriever',
    'Golden Retriever',
    'German Shepherd',
    'Boxer',
    'Siberian Husky',
    'Doberman Pinscher',
    'Rottweiler',
    'Australian Cattle Dog',
    'Belgian Malinois',
    'Weimaraner',
    'Vizsla',
    'Rhodesian Ridgeback',
    'Dalmatian',
    'Standard Poodle',
    'Collie',
  ];
  
  static const List<String> giant = [
    'Great Dane',
    'Mastiff',
    'Saint Bernard',
    'Newfoundland',
    'Irish Wolfhound',
    'Great Pyrenees',
    'Bernese Mountain Dog',
    'Leonberger',
    'Scottish Deerhound',
    'Cane Corso',
    'Dogue de Bordeaux',
    'Tibetan Mastiff',
    'Anatolian Shepherd',
  ];
  
  static const List<String> other = [
    'Mixed Breed',
    'Unknown',
    'Other',
  ];
  
  /// Get all breeds sorted alphabetically
  static List<String> get all {
    final breeds = <String>[];
    breeds.addAll(small);
    breeds.addAll(medium);
    breeds.addAll(large);
    breeds.addAll(giant);
    breeds.sort();
    breeds.addAll(other);
    return breeds;
  }
  
  /// Get breed category
  static String getCategory(String breed) {
    if (small.contains(breed)) return 'Small (<10kg)';
    if (medium.contains(breed)) return 'Medium (10-25kg)';
    if (large.contains(breed)) return 'Large (25-45kg)';
    if (giant.contains(breed)) return 'Giant (>45kg)';
    return 'Other';
  }
}

/// Common cat breeds for selection dropdown
class CatBreeds {
  CatBreeds._();
  
  static const List<String> all = [
    'Domestic Shorthair',
    'Domestic Longhair',
    'Persian',
    'Maine Coon',
    'Ragdoll',
    'British Shorthair',
    'Siamese',
    'Bengal',
    'Abyssinian',
    'Scottish Fold',
    'Sphynx',
    'Russian Blue',
    'Norwegian Forest Cat',
    'Birman',
    'Oriental Shorthair',
    'Devon Rex',
    'Burmese',
    'Exotic Shorthair',
    'Himalayan',
    'American Shorthair',
    'Mixed Breed',
    'Unknown',
    'Other',
  ];
}
