import 'enums.dart';

/// Observer (user) model
class Observer {
  final String id;
  final String name;
  final String email;
  final String clinicId;
  final String clinicName;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  Observer({
    required this.id,
    required this.name,
    required this.email,
    required this.clinicId,
    required this.clinicName,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
  });

  /// Get initials for avatar fallback
  String get initials {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return '?';

    final parts = trimmedName.split(' ');
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }

    // Single word name - take first 1-2 characters
    if (trimmedName.length >= 2) {
      return trimmedName.substring(0, 2).toUpperCase();
    }
    return trimmedName[0].toUpperCase();
  }

  /// Get first name
  String get firstName {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return 'User';
    final parts = trimmedName.split(' ');
    return parts.first;
  }

  factory Observer.fromJson(Map<String, dynamic> json) {
    // Handle clinic as either flat fields or nested object
    String clinicId;
    String clinicName;

    if (json['clinic'] != null && json['clinic'] is Map) {
      // Nested clinic object: { "clinic": { "id": "...", "name": "..." } }
      final clinic = json['clinic'] as Map<String, dynamic>;
      clinicId = _toString(clinic['clinic_id'] ?? clinic['id'] ?? '');
      clinicName =
          clinic['clinic_name'] as String? ?? clinic['name'] as String? ?? '';
    } else {
      // Flat fields: { "clinic_id": "...", "clinic_name": "..." }
      clinicId = _toString(json['clinic_id'] ?? '');
      clinicName = json['clinic_name'] as String? ?? '';
    }

    // Handle created_at - might be string or might be missing
    DateTime createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at'] as String);
    } else {
      createdAt = DateTime.now();
    }

    // Get name from various possible fields
    String name =
        json['name'] as String? ??
        json['full_name'] as String? ??
        json['username'] as String? ??
        '';

    return Observer(
      id: _toString(json['observer_id'] ?? json['id'] ?? json['user_id'] ?? ''),
      name: name,
      email: json['email'] as String? ?? '',
      clinicId: clinicId,
      clinicName: clinicName,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: createdAt,
    );
  }

  /// Helper to convert any value to String
  static String _toString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'observer_id': id,
      'name': name,
      'email': email,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Observer(id: $id, name: $name)';
}

/// Authentication token model
class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final Observer observer;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.observer,
  });

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token will expire soon (within 5 minutes)
  bool get willExpireSoon {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    // Handle wrapped response: { "success": true, "data": { ... } }
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final expiresIn = data['expires_in'] as int? ?? 28800; // Default 8 hours

    // Handle observer - might be nested in 'user' or 'observer'
    Map<String, dynamic> observerJson;
    if (data['observer'] != null) {
      observerJson = data['observer'] as Map<String, dynamic>;
    } else if (data['user'] != null) {
      observerJson = data['user'] as Map<String, dynamic>;
    } else {
      // Observer data might be at root level
      observerJson = data;
    }

    return AuthToken(
      accessToken:
          data['access_token'] as String? ?? data['token'] as String? ?? '',
      refreshToken: data['refresh_token'] as String? ?? '',
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      observer: Observer.fromJson(observerJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'observer': observer.toJson(),
    };
  }
}

/// Login request model
class LoginRequest {
  final String observerId;
  final String password;
  final String deviceId;
  final String appVersion;

  LoginRequest({
    required this.observerId,
    required this.password,
    required this.deviceId,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'observer_id': observerId,
      'password': password,
      'device_id': deviceId,
      'app_version': appVersion,
    };
  }
}

/// Session participant (for multi-observer support)
class SessionParticipant {
  final String observerId;
  final String observerName;
  final ObserverRole role;
  final DateTime joinedAt;

  SessionParticipant({
    required this.observerId,
    required this.observerName,
    required this.role,
    required this.joinedAt,
  });

  bool get isPrimary => role == ObserverRole.primary;

  factory SessionParticipant.fromJson(Map<String, dynamic> json) {
    return SessionParticipant(
      observerId: json['observer_id'] as String,
      observerName: json['observer_name'] as String,
      role: ObserverRole.fromString(json['role'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'observer_id': observerId,
      'observer_name': observerName,
      'role': role.value,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

/// Join code for multi-observer session
class JoinCode {
  final String code;
  final String qrData;
  final String sessionId;
  final DateTime expiresAt;

  JoinCode({
    required this.code,
    required this.qrData,
    required this.sessionId,
    required this.expiresAt,
  });

  /// Check if code is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get remaining time
  Duration get remainingTime {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory JoinCode.fromJson(Map<String, dynamic> json) {
    return JoinCode(
      code: json['code'] as String,
      qrData: json['qr_data'] as String,
      sessionId: json['session_id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}
