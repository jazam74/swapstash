import 'package:flutter/material.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

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

    final localizations = AppLocalizations.of(context)!;
    final displayName = _displayNameController.text.trim();

    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.editProfileDisplayNameRequired)),
      );
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

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.editProfileSaved)));

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.editProfileSaveError(error.toString())),
        ),
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.editProfile)),
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
                  localizations.editProfileLoadError(snapshot.error.toString()),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = snapshot.data;

          if (profile == null) {
            return Center(child: Text(localizations.editProfileMissing));
          }

          _initializeForm(profile);

          return LayoutBuilder(
            builder: (context, constraints) {
              const maxContentWidth = 900.0;

              final horizontalPadding = constraints.maxWidth >= 900
                  ? 24.0
                  : 16.0;
              final availableWidth =
                  constraints.maxWidth - (horizontalPadding * 2);
              final contentWidth = availableWidth > maxContentWidth
                  ? maxContentWidth
                  : availableWidth;

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  32,
                ),
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _displayNameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText:
                                  localizations.editProfileDisplayName,
                              prefixIcon:
                                  const Icon(Icons.person_outline),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _cityController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: localizations.editProfileCity,
                              prefixIcon:
                                  const Icon(Icons.location_city),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _bioController,
                            maxLines: 3,
                            maxLength: 300,
                            decoration: InputDecoration(
                              labelText: localizations.editProfileBio,
                              prefixIcon:
                                  const Icon(Icons.notes_outlined),
                              border: const OutlineInputBorder(),
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
                            title: Text(
                              localizations.editProfilePublicTitle,
                            ),
                            subtitle: Text(
                              localizations.editProfilePublicSubtitle,
                            ),
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
                            title: Text(
                              localizations.editProfileInternationalTitle,
                            ),
                            subtitle: Text(
                              localizations
                                  .editProfileInternationalSubtitle,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _isSaving
                                ? null
                                : () => _saveProfile(profile),
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _isSaving
                                  ? localizations.editProfileSaving
                                  : localizations.editProfileSave,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
