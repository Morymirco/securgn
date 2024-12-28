import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyService {
  final String id;
  final String serviceId;
  final String name;
  final String type;
  final List<String> phone;
  final String address;
  final bool available24h;
  final List<String> services;
  final GeoPoint coordinates;
  final String email;
  final String username;  // Identifiant de connexion
  final String password;  // Mot de passe (à hasher avant stockage)
  final bool isActive;    // État du compte
  final String role;      // Role du service (par défaut 'SERVICE')
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyService({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.type,
    required this.phone,
    required this.address,
    required this.available24h,
    required this.services,
    required this.coordinates,
    required this.email,
    required this.username,
    required this.password,
    required this.isActive,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'name': name,
      'type': type,
      'phone': phone,
      'address': address,
      'available24h': available24h,
      'services': services,
      'coordinates': coordinates,
      'email': email,
      'username': username,
      'password': password,  // À hasher avant stockage
      'isActive': isActive,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory EmergencyService.fromMap(Map<String, dynamic> map, String id) {
    GeoPoint coordinates;
    if (map['coordinates'] is GeoPoint) {
      coordinates = map['coordinates'] as GeoPoint;
    } else if (map['coordinates'] is Map) {
      final coordMap = map['coordinates'] as Map<String, dynamic>;
      coordinates = GeoPoint(
        coordMap['latitude'] as double,
        coordMap['longitude'] as double,
      );
    } else {
      coordinates = const GeoPoint(0, 0);
    }

    return EmergencyService(
      id: id,
      serviceId: map['serviceId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      phone: List<String>.from(map['phone'] ?? []),
      address: map['address'] ?? '',
      available24h: map['available24h'] ?? false,
      services: List<String>.from(map['services'] ?? []),
      coordinates: coordinates,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      isActive: map['isActive'] ?? false,
      role: map['role'] ?? 'SERVICE',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Mise à jour de copyWith
  EmergencyService copyWith({
    String? id,
    String? serviceId,
    String? name,
    String? type,
    List<String>? phone,
    String? address,
    bool? available24h,
    List<String>? services,
    GeoPoint? coordinates,
    String? email,
    String? username,
    String? password,
    bool? isActive,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyService(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      available24h: available24h ?? this.available24h,
      services: services ?? this.services,
      coordinates: coordinates ?? this.coordinates,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 