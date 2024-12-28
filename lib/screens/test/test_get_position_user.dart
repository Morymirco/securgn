import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class TestGetPositionUser extends StatefulWidget {
  const TestGetPositionUser({super.key});

  @override
  State<TestGetPositionUser> createState() => _TestGetPositionUserState();
}

class _TestGetPositionUserState extends State<TestGetPositionUser> {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _error = 'Les services de localisation sont désactivés. Veuillez les activer dans les paramètres.';
      });
      return false;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Les permissions de localisation sont refusées';
        });
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _error = 'Les permissions de localisation sont définitivement refusées, nous ne pouvons pas demander les permissions.';
      });
      return false;
    }

    return true;
  }

  Future<void> _getCurrentPosition() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      await _getAddressFromLatLng();
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la récupération de la position: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      if (_currentPosition == null) return;

      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la récupération de l\'adresse: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Test Position',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône et titre
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF094FC6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 50,
                    color: Color(0xFF094FC6),
                  ),
                ),
                const SizedBox(height: 30),

                // Position actuelle
                if (_currentPosition != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Latitude',
                          _currentPosition!.latitude.toString(),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          'Longitude',
                          _currentPosition!.longitude.toString(),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          'Altitude',
                          '${_currentPosition!.altitude.toString()} m',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          'Précision',
                          '${_currentPosition!.accuracy.toString()} m',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Adresse actuelle
                if (_currentAddress != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_city,
                          color: Color(0xFF094FC6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Message d'erreur
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Bouton de rafraîchissement
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getCurrentPosition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF094FC6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isLoading ? 'Chargement...' : 'Actualiser la position',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 