import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/features/profile/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: StreamBuilder<UserProfile?>(
        stream: firestoreService.watchCurrentUserProfile(),
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

          final displayName = profile.displayName.trim().isEmpty
              ? 'Neimenovan uporabnik'
              : profile.displayName.trim();

          final locationParts = [
            if (profile.city.trim().isNotEmpty) profile.city.trim(),
            if (profile.country.trim().isNotEmpty) profile.country.trim(),
          ];

          final location = locationParts.join(', ');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 46,
                backgroundImage: profile.photoUrl.trim().isEmpty
                    ? null
                    : NetworkImage(profile.photoUrl),
                child: profile.photoUrl.trim().isEmpty
                    ? const Icon(Icons.person, size: 46)
                    : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  profile.email.isNotEmpty
                      ? profile.email
                      : authUser?.email ?? 'Neznan uporabnik',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18),
                      const SizedBox(width: 4),
                      Text(location),
                    ],
                  ),
                ),
              ],
              if (profile.bio.trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      profile.bio.trim(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _ProfileStatRow(
                        icon: Icons.star_outline,
                        label: 'Ocena',
                        value: profile.rating.toStringAsFixed(1),
                      ),
                      const Divider(),
                      _ProfileStatRow(
                        icon: Icons.handshake_outlined,
                        label: 'Zaključene menjave',
                        value: profile.completedTrades.toString(),
                      ),
                      const Divider(),
                      _ProfileStatRow(
                        icon: profile.isPublic
                            ? Icons.public
                            : Icons.lock_outline,
                        label: 'Vidnost profila',
                        value: profile.isPublic ? 'Javen' : 'Zaseben',
                      ),
                      const Divider(),
                      _ProfileStatRow(
                        icon: Icons.language,
                        label: 'Mednarodne menjave',
                        value: profile.allowInternationalTrades
                            ? 'Dovoljene'
                            : 'Niso dovoljene',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Uredi profil'),
                  subtitle: const Text('Ime, mesto, opis in zasebnost'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Nastavitve'),
                  subtitle: const Text('Nastavitve aplikacije'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nastavitve bodo dodane pozneje.'),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Odjava'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
