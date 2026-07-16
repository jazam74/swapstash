import 'package:flutter/material.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _displayNameController = TextEditingController();

  final TextEditingController _cityController = TextEditingController();

  final TextEditingController _bioController = TextEditingController();

  bool _isPublic = true;
  bool _allowInternationalTrades = false;
  bool _isSaving = false;
  bool _formInitialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initializeForm(UserProfile profile) {
    if (_formInitialized) {
      return;
    }

    _displayNameController.text = profile.displayName;
    _cityController.text = profile.city;
    _bioController.text = profile.bio;
    _isPublic = profile.isPublic;
    _allowInternationalTrades = profile.allowInternationalTrades;

    _formInitialized = true;
  }

  Future<void> _saveProfile(UserProfile profile) async {
    if (_isSaving) {
      return;
    }

    final displayName = _displayNameController.text.trim();

    if (displayName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vpiši prikazno ime.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedProfile = profile.copyWith(
        displayName: displayName,
        city: _cityController.text.trim(),
        bio: _bioController.text.trim(),
        isPublic: _isPublic,
        allowInternationalTrades: _allowInternationalTrades,
      );

      await _firestoreService.updateCurrentUserProfile(updatedProfile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil je bil uspešno shranjen.')),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profila ni bilo mogoče shraniti: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uredi profil')),
      body: StreamBuilder<UserProfile?>(
        stream: _firestoreService.watchCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Profila ni bilo mogoče naložiti:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = snapshot.data;

          if (profile == null) {
            return const Center(child: Text('Profil ne obstaja.'));
          }

          _initializeForm(profile);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _displayNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Prikazno ime',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Mesto',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Opis',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPublic,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                title: const Text('Javni profil'),
                subtitle: const Text('Drugi uporabniki te lahko najdejo.'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _allowInternationalTrades,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _allowInternationalTrades = value;
                        });
                      },
                title: const Text('Dovolim mednarodne menjave'),
                subtitle: const Text(
                  'Ponudbe lahko prejmeš tudi iz drugih držav.',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : () => _saveProfile(profile),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Shranjujem ...' : 'Shrani'),
              ),
            ],
          );
        },
      ),
    );
  }
}
