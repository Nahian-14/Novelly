import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Temporary landing screen shown right after a successful sign-in or
/// registration. This is just a placeholder so there's somewhere for a
/// signed-in user to land — replace/expand this with the real home page
/// (book list, feed, etc.) as that part of the app gets built.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.appUser});

  /// The MongoDB-backed profile for the signed-in user, if it was
  /// available at navigation time (e.g. straight after login/register).
  final AppUser? appUser;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = AuthService.instance.currentUser;
    final displayName = appUser?.name.isNotEmpty == true
        ? appUser!.name
        : (firebaseUser?.displayName ?? firebaseUser?.email ?? 'there');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novelly'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome, $displayName!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              if (appUser != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Signed in as ${userRoleToLabel(appUser!.role)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'This is a placeholder home screen — the real pages '
                '(books, writers, publishers, chat, etc.) go here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
