import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/services_firebase/firebase_auth_service.dart';
import 'package:my_app/services_firebase/firestore_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addContact() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF094FC6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_add,
                color: Color(0xFF094FC6),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ajouter un contact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF094FC6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF094FC6)),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF094FC6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF094FC6)),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    controller: _relationController,
                    decoration: InputDecoration(
                      labelText: 'Relation',
                      prefixIcon: const Icon(Icons.people_outline, color: Color(0xFF094FC6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF094FC6)),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final contact = {
                  'name': _nameController.text,
                  'phone': _phoneController.text,
                  'relation': _relationController.text,
                  'createdAt': DateTime.now(),
                };

                try {
                  setState(() => _isLoading = true);
                  await _firestoreService.createDocument(
                    'users/${_authService.currentUser!.uid}/emergency_contacts',
                    DateTime.now().millisecondsSinceEpoch.toString(),
                    contact,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    _clearForm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact ajouté avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de l\'ajout du contact'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF094FC6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Ajouter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _editContact(String contactId, Map<String, dynamic> contact) async {
    _nameController.text = contact['name'];
    _phoneController.text = contact['phone'];
    _relationController.text = contact['relation'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le contact'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationController,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updatedContact = {
                  'name': _nameController.text,
                  'phone': _phoneController.text,
                  'relation': _relationController.text,
                  'updatedAt': DateTime.now(),
                };

                try {
                  await _firestoreService.updateDocument(
                    'users/${_authService.currentUser!.uid}/emergency_contacts',
                    contactId,
                    updatedContact,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    _clearForm();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de la modification')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF094FC6),
            ),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteContact(String contactId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le contact'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce contact ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteDocument(
                  'users/${_authService.currentUser!.uid}/emergency_contacts',
                  contactId,
                );
                
                if (mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erreur lors de la suppression')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _relationController.clear();
  }

  Widget _buildContactCard(Map<String, dynamic> contact, String contactId) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF094FC6).withOpacity(0.1),
                    radius: 25,
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF094FC6),
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact['relation'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined, color: Color(0xFF094FC6)),
                          title: const Text('Modifier'),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            Navigator.pop(context);
                            _editContact(contactId, contact);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline, color: Colors.red),
                          title: const Text('Supprimer'),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            Navigator.pop(context);
                            _deleteContact(contactId);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF094FC6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF094FC6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      contact['phone'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF094FC6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Contacts d\'urgence',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF094FC6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_authService.currentUser!.uid)
            .collection('emergency_contacts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contact_phone_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun contact d\'urgence',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final contact = doc.data() as Map<String, dynamic>;
              return _buildContactCard(contact, doc.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContact,
        backgroundColor: const Color(0xFF094FC6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter un contact', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }
} 