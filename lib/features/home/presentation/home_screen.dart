import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../../shared/widgets/illustrations.dart';
import '../../../shared/widgets/jobdecode_logo.dart';
import '../../../shared/widgets/ui_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  final _urlFocusNode = FocusNode();

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _analyze() {
    final url = _urlController.text.trim();
    final uri = Uri.tryParse(url);
    final isValidUrl =
        uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (!isValidUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a valid job link to continue.')),
      );
      return;
    }

    context.go('/loading?url=${Uri.encodeComponent(url)}');
  }

  void _openMenu() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * .82;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 430, maxHeight: maxHeight),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const JobDecodeLogo(compact: true),
                      const SizedBox(height: 6),
                      Text(
                        'Understand any job in seconds',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MenuTile(
                        icon: Icons.link_rounded,
                        color: AppColors.primary,
                        title: 'Paste Job Link',
                        subtitle: 'Start a new analysis',
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          _urlFocusNode.requestFocus();
                        },
                      ),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.history_rounded,
                        color: AppColors.secondary,
                        title: 'History',
                        subtitle: 'Open previous jobs',
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go('/history');
                        },
                      ),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.bookmark_rounded,
                        color: AppColors.violet,
                        title: 'Saved',
                        subtitle: 'Review saved jobs',
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go('/saved');
                        },
                      ),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.person_rounded,
                        color: AppColors.accent,
                        title: 'Profile',
                        subtitle: 'Manage your account',
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go('/profile');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      currentIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Menu',
                  onPressed: _openMenu,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  icon: const Icon(Icons.menu_rounded),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Premium',
                  onPressed: () => context.go('/premium'),
                  color: AppColors.accent,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  icon: const Icon(Icons.workspace_premium_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const JobDecodeLogo(showTagline: true),
            const SizedBox(height: 20),
            const HomeIllustration(),
            const SizedBox(height: 14),
            Text(
              'Paste any job link',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 21),
            ),
            const SizedBox(height: 9),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: Text(
                "We'll extract and explain what the job wants, in simple words.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _urlController,
              focusNode: _urlFocusNode,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _analyze(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.1),
              decoration: const InputDecoration(
                hintText: 'Paste job link here...',
                suffixIcon: Icon(Icons.link_rounded),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryAction(
              label: 'Analyze Job',
              height: 48,
              onPressed: _analyze,
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 17,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'We only read the job description. Your data is safe.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return JDCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
