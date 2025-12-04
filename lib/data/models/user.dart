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
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, 2).toUpperCase();
  }

  /// Get first name
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.first;
  }

  factory Observer.fromJson(Map<String, dynamic> json) {
    return Observer(
      id: json['observer_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      clinicId: json['clinic_id'] as String,
      clinicName: json['clinic_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
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
    final expiresIn = json['expires_in'] as int? ?? 28800; // Default 8 hours

    return AuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      observer: Observer.fromJson(json['observer'] as Map<String, dynamic>),
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
