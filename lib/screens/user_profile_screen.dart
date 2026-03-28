import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStat({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: context.textStyles.titleMedium?.bold,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class BadgeCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const BadgeCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF5E6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD2B48C), width: 2),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: const Color(0xFF5D3A1A),
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF228B22),
                            Color(0xFF5D3A1A),
                          ],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            right: -50,
                            bottom: -50,
                            child: Icon(
                              Icons.terrain,
                              color: Colors.white.withOpacity(0.1),
                              size: 300,
                            ),
                          ),
                          Positioned(
                            top: AppSpacing.sm,
                            left: AppSpacing.sm,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Theme.of(context).colorScheme.surface, width: 4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              "assets/images/smiling_man_in_construction_vest_and_cap_outdoors_orange_1774661726824.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "David Richardson",
                                    style: context.textStyles.headlineSmall?.bold,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        size: 14,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        "Houston, TX Chapter",
                                        style: context.textStyles.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: AppSpacing.paddingLg,
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ProfileStat(value: "12", label: "Deployments"),
                    ProfileStat(value: "450", label: "Hours"),
                    ProfileStat(value: "8", label: "Certifications"),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Service Badges",
                          style: context.textStyles.titleMedium?.bold,
                        ),
                        Text(
                          "View All",
                          style: context.textStyles.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          BadgeCard(icon: Icons.tsunami, label: "Flood Response"),
                          BadgeCard(icon: Icons.handyman, label: "Lead Builder"),
                          BadgeCard(icon: Icons.volunteer_activism, label: "100+ Hours"),
                          BadgeCard(icon: Icons.medical_services, label: "First Aid"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Account Settings",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const SettingsItem(
                      icon: Icons.person_outline_rounded,
                      title: "Personal Information",
                      subtitle: "Email, phone, and emergency contact",
                    ),
                    const SettingsItem(
                      icon: Icons.verified_user_outlined,
                      title: "Credentials & Waivers",
                      subtitle: "Background check expires in 4 months",
                    ),
                    const SettingsItem(
                      icon: Icons.notifications_none_rounded,
                      title: "Alert Preferences",
                      subtitle: "Hurricane and Tornado warnings",
                    ),
                    const SettingsItem(
                      icon: Icons.history_rounded,
                      title: "Deployment History",
                      subtitle: "Review past projects and logs",
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Support",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const SettingsItem(
                      icon: Icons.help_outline_rounded,
                      title: "Help Center",
                      subtitle: "Training videos and safety guides",
                    ),
                    const SettingsItem(
                      icon: Icons.info_outline_rounded,
                      title: "About Lighthouse",
                      subtitle: "Version 2.4.0 (Build 108)",
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Sign Out"),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFBA1A1A),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Text(
                        "Serving with love since 1984",
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
