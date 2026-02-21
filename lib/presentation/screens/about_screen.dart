import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'NOTE CRAFT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.note_alt,
                size: 50,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            // App Name and Version
            Text(
              AppConstants.appName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),

            const SizedBox(height: 32),

            // Description
            Text(
              'A Google Keep-inspired note-taking app built with Flutter. '
              'Capture your thoughts, organize with labels, and access your notes anywhere.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Features
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Offline-first architecture'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Material 3 design'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Text and checklist notes'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Label organization'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Dark mode support'),
            ),

            const Spacer(),

            // Copyright
            Text(
              '© 2026 NoteKeeper\nBuilt with ❤️ using Flutter',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
