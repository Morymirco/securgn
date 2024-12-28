import 'package:cloud_firestore/cloud_firestore.dart';

// Structure d'un message d'urgence
class EmergencyMessage {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final String status;  // 'pending', 'received', 'responded'
  final String serviceId;
  final String serviceName;
  final Location? location;
  final String? replyTo;  // ID du message auquel on répond
  final String priority;  // 'low', 'medium', 'high'

  EmergencyMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    required this.status,
    required this.serviceId,
    required this.serviceName,
    this.location,
    this.replyTo,
    this.priority = 'medium',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'location': location?.toMap(),
      'replyTo': replyTo,
      'priority': priority,
    };
  }

  factory EmergencyMessage.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyMessage(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      location: map['location'] != null 
          ? Location.fromMap(map['location'] as Map<String, dynamic>)
          : null,
      replyTo: map['replyTo'],
      priority: map['priority'] ?? 'medium',
    );
  }
}

// Structure de la localisation
class Location {
  final double latitude;
  final double longitude;
  final String? address;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
    );
  }
}

// Structure d'une réponse de service
class ServiceResponse {
  final String serviceId;
  final String serviceName;
  final String message;
  final DateTime timestamp;
  final String status; // 'en route', 'arrivé', 'terminé'
  final EstimatedArrival? eta;

  ServiceResponse({
    required this.serviceId,
    required this.serviceName,
    required this.message,
    required this.timestamp,
    required this.status,
    this.eta,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'eta': eta?.toMap(),
    };
  }

  factory ServiceResponse.fromMap(Map<String, dynamic> map) {
    return ServiceResponse(
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: map['status'] ?? '',
      eta: map['eta'] != null 
          ? EstimatedArrival.fromMap(map['eta'] as Map<String, dynamic>)
          : null,
    );
  }
}

// Structure pour l'estimation d'arrivée
class EstimatedArrival {
  final DateTime estimatedTime;
  final double distance; // en mètres
  final int duration; // en secondes

  EstimatedArrival({
    required this.estimatedTime,
    required this.distance,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'estimatedTime': Timestamp.fromDate(estimatedTime),
      'distance': distance,
      'duration': duration,
    };
  }

  factory EstimatedArrival.fromMap(Map<String, dynamic> map) {
    return EstimatedArrival(
      estimatedTime: (map['estimatedTime'] as Timestamp).toDate(),
      distance: (map['distance'] as num).toDouble(),
      duration: map['duration'] as int,
    );
  }
} 