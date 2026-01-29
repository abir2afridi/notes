import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Developer',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, 'Profile'),
                Card(
                  elevation: 0,
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Abir Hasan Siam',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flutter Developer',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildInfoRow('Born', '17 November 2002'),
                        _buildInfoRow('Age', '22 years'),
                        _buildInfoRow('From', 'Tangail, Bangladesh'),
                        _buildInfoRow('Location', 'Gazipur, Dhaka'),
                        _buildInfoRow('Blood Group', 'B+'),
                      ],
                    ),
                  ),
                ),

                _buildSectionHeader(context, 'Education'),
                _buildCardGroup(context, [
                  _buildEducationTile(
                    'Independent University, Bangladesh',
                    'BSc in Computer Science',
                    '2021 - Present',
                  ),
                  _buildEducationTile(
                    'Misir Ali Khan Memorial College',
                    'Higher Secondary Certificate',
                    '2019 - 2020',
                  ),
                ]),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Skills'),
                _buildCardGroup(context, [
                  _buildSkillRow('Languages', 'Dart (Flutter), Python, JS'),
                  _buildSkillRow('Frameworks', 'Flutter, React.js'),
                  _buildSkillRow('Tools', 'Git, VS Code, Android Studio'),
                  _buildSkillRow('Design', 'Material 3, UI/UX Principles'),
                ]),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Traits & Practices'),
                _buildCardGroup(context, [
                  _buildTraitTile('Detail-oriented and curious'),
                  _buildTraitTile('Clean project structure'),
                  _buildTraitTile('Focus on first-time experience'),
                  _buildTraitTile('Cross-platform compatibility'),
                ]),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Contact'),
                _buildCardGroup(context, [
                  _buildContactTile(
                    context,
                    'GitHub',
                    '@abir2afridi',
                    Icons.code,
                    'https://github.com/abir2afridi',
                  ),
                  _buildContactTile(
                    context,
                    'Portfolio',
                    'abir2afridi.vercel.app',
                    Icons.web,
                    'https://abir2afridi.vercel.app/',
                  ),
                  _buildContactTile(
                    context,
                    'Email',
                    'abir2afridi@gmail.com',
                    Icons.email,
                    'mailto:abir2afridi@gmail.com',
                  ),
                ]),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    '© 2026 Abir Hasan Siam\nBuilt with ❤️ using Flutter',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCardGroup(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEducationTile(String institution, String degree, String period) {
    return ListTile(
      title: Text(
        institution,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(degree),
          Text(
            period,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildSkillRow(String category, String skills) {
    return ListTile(
      title: Text(
        category,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(skills),
      dense: true,
    );
  }

  Widget _buildTraitTile(String trait) {
    return ListTile(
      leading: const Icon(Icons.check_circle, size: 20, color: Colors.green),
      title: Text(trait, style: const TextStyle(fontSize: 14)),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    String url,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      trailing: const Icon(Icons.launch, size: 16),
      onTap: () async {
        try {
          await launchUrl(Uri.parse(url));
        } catch (_) {}
      },
    );
  }
}
