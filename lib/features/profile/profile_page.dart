import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/auth_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/features/profile/account_security_page.dart';
import 'package:swapstash/features/profile/edit_profile_page.dart';
import 'package:swapstash/features/settings/settings_page.dart';
import 'package:swapstash/features/users/widgets/completed_trades_value.dart';
import 'package:swapstash/features/users/widgets/user_rating_list.dart';
import 'package:swapstash/features/users/widgets/user_rating_summary.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmSignOut(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.signOutConfirmationTitle),
          content: Text(localizations.signOutConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.signOut),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      await AuthService().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.profile)),
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
                  '${localizations.profileLoadError}\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = snapshot.data;

          if (profile == null) {
            return Center(child: Text(localizations.profileMissing));
          }

          final displayName = profile.displayName.trim().isEmpty
              ? localizations.unnamedUser
              : profile.displayName.trim();

          final locationParts = [
            if (profile.city.trim().isNotEmpty) profile.city.trim(),
            if (profile.country.trim().isNotEmpty) profile.country.trim(),
          ];

          final location = locationParts.join(', ');

          return LayoutBuilder(
            builder: (context, constraints) {
              const maxContentWidth = 1000.0;

              final horizontalPadding = constraints.maxWidth >= 900
                  ? 24.0
                  : 16.0;
              final availableWidth =
                  constraints.maxWidth - (horizontalPadding * 2);
              final contentWidth = availableWidth > maxContentWidth
                  ? maxContentWidth
                  : availableWidth;
              final useDesktopLayout = contentWidth >= 820;

              final profileHeader = Column(
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
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email.isNotEmpty
                        ? profile.email
                        : authUser?.email ?? localizations.unknownUser,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 4),
                        Flexible(child: Text(location)),
                      ],
                    ),
                  ],
                ],
              );

              final profileDetails = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (profile.bio.trim().isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          profile.bio.trim(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _ProfileStatRow(
                            icon: Icons.star_outline,
                            label: localizations.rating,
                            value: UserRatingSummary(
                              userId: profile.uid,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          _ProfileStatRow(
                            icon: Icons.handshake_outlined,
                            label: localizations.completedTrades,
                            value: CompletedTradesValue(
                              userId: profile.uid,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          _ProfileStatRow(
                            icon: profile.isPublic
                                ? Icons.public
                                : Icons.lock_outline,
                            label: localizations.profileVisibility,
                            value: Text(
                              profile.isPublic
                                  ? localizations.publicProfile
                                  : localizations.privateProfile,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          _ProfileStatRow(
                            icon: Icons.language,
                            label: localizations.internationalTrades,
                            value: Text(
                              profile.allowInternationalTrades
                                  ? localizations.allowed
                                  : localizations.notAllowed,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  UserRatingList(userId: profile.uid, limit: 5),
                ],
              );

              final profileActions = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(localizations.editProfile),
                      subtitle: Text(localizations.editProfileSubtitle),
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
                  const SizedBox(height: 10),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text(localizations.settings),
                      subtitle: Text(localizations.applicationSettings),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(
                        authUser?.emailVerified == true
                            ? Icons.security_outlined
                            : Icons.mark_email_unread_outlined,
                      ),
                      title: Text(localizations.accountSecurityTitle),
                      subtitle: Text(
                        authUser?.emailVerified == true
                            ? localizations.accountSecuritySubtitle
                            : localizations.emailVerificationReminder,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AccountSecurityPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(localizations.signOut),
                      onTap: () =>
                          _confirmSignOut(context, localizations),
                    ),
                  ),
                ],
              );

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
                          profileHeader,
                          const SizedBox(height: 24),
                          if (useDesktopLayout)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 6, child: profileDetails),
                                const SizedBox(width: 20),
                                Expanded(flex: 5, child: profileActions),
                              ],
                            )
                          else ...[
                            profileDetails,
                            const SizedBox(height: 16),
                            profileActions,
                          ],
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

class _ProfileStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;

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
        value,
      ],
    );
  }
}
