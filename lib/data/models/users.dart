/// User/Observer model for authentication
class User {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? organizationId;
  final String? organizationName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.organizationId,
    this.organizationName,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      organizationId: json['organization_id']?.toString(),
      organizationName: json['organization_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'organization_id': organizationId,
      'organization_name': organizationName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  /// Copy with
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? organizationId,
    String? organizationName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Observer (User) model for authentication sessions
class Observer {
  final String id;
  final String name;
  final String email;
  final String clinicId;
  final String clinicName;
  final DateTime createdAt;

  Observer({
    required this.id,
    required this.name,
    required this.email,
    required this.clinicId,
    required this.clinicName,
    required this.createdAt,
  });

  /// Create from JSON
  factory Observer.fromJson(Map<String, dynamic> json) {
    return Observer(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      clinicId:
          json['clinic_id']?.toString() ??
          json['clinicId']?.toString() ??
          json['organization_id']?.toString() ??
          '1',
      clinicName:
          json['clinic_name'] as String? ??
          json['clinicName'] as String? ??
          json['organization_name'] as String? ??
          'Default Clinic',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with
  Observer copyWith({
    String? id,
    String? name,
    String? email,
    String? clinicId,
    String? clinicName,
    DateTime? createdAt,
  }) {
    return Observer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Observer(id: $id, name: $name, email: $email, clinicId: $clinicId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Observer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Auth token model
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime expiresAt;
  final Observer observer;

  AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresAt,
    required this.observer,
  });

  /// Create from JSON
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final user = data['user'] as Map<String, dynamic>;

    // Calculate expiry
    final expiresIn = data['expires_in'] as int? ?? 28800; // Default 8 hours
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    return AuthToken(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String?,
      tokenType: data['token_type'] as String? ?? 'bearer',
      expiresAt: expiresAt,
      observer: Observer.fromJson(user),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_at': expiresAt.toIso8601String(),
      'observer': observer.toJson(),
    };
  }

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token is valid
  bool get isValid => !isExpired;

  /// Time until expiry
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  @override
  String toString() {
    return 'AuthToken(tokenType: $tokenType, expiresAt: $expiresAt, observer: ${observer.name})';
  }
}
