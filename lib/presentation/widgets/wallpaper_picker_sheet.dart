import 'package:flutter/material.dart';

class WallpaperPickerSheet extends StatelessWidget {
  final List<String> wallpapers;
  final String? selectedPath;
  final bool allowNoWallpaper;
  final Function(String?) onWallpaperSelected;

  const WallpaperPickerSheet({
    super.key,
    required this.wallpapers,
    this.selectedPath,
    this.allowNoWallpaper = true,
    required this.onWallpaperSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handle = Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final contentHeight = MediaQuery.of(context).size.height * 0.5;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: handle),
            Text(
              'Choose a wallpaper',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (allowNoWallpaper)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('No wallpaper'),
                subtitle: const Text('Use solid color only'),
                trailing: selectedPath == null
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  onWallpaperSelected(null);
                  Navigator.of(context).pop();
                },
              ),
            if (allowNoWallpaper) const SizedBox(height: 8),
            if (wallpapers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No wallpapers found',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              SizedBox(
                height: contentHeight,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: wallpapers.length,
                  itemBuilder: (context, index) {
                    final path = wallpapers[index];
                    final isSelected = path == selectedPath;
                    return GestureDetector(
                      onTap: () {
                        onWallpaperSelected(path);
                        Navigator.of(context).pop();
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              path,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                color: isSelected
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      )
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: theme.colorScheme.primary,
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
