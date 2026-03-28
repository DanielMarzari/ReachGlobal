import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class ActiveDisasterCard extends StatelessWidget {
  final String title;
  final String location;
  final String imagePath;
  final String progress;
  final double progressVal;
  final String status;

  const ActiveDisasterCard({
    super.key,
    required this.title,
    required this.location,
    required this.imagePath,
    required this.progress,
    required this.progressVal,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ],
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x88000000),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          location,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.textStyles.titleMedium?.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        status,
                        style: context.textStyles.labelSmall?.bold.copyWith(
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Relief Progress",
                          style: context.textStyles.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          "$progress%",
                          style: context.textStyles.bodySmall?.bold,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 8,
                        backgroundColor: Theme.of(context).dividerColor,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.login),
                        icon: const Icon(Icons.volunteer_activism),
                        label: const Text("Volunteer"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.donationFlow),
                        icon: const Icon(Icons.payments),
                        label: const Text("Donate"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImpactStat extends StatelessWidget {
  final String value;
  final String label;

  const ImpactStat({
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
            style: context.textStyles.titleLarge?.bold.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lighthouse",
                          style: context.textStyles.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                            height: 1,
                          ),
                        ),
                        Text(
                          "Disaster Relief Coordination",
                          style: context.textStyles.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.userProfile),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        child: const Icon(Icons.person_outline),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Global Impact",
                      style: context.textStyles.titleSmall?.bold.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ImpactStat(value: "12", label: "Active Fronts"),
                        ImpactStat(value: "842", label: "Volunteers"),
                        ImpactStat(value: "2.4k", label: "Families Fed"),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Active Responses",
                      style: context.textStyles.titleLarge?.bold,
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.eventOverview),
                      child: Row(
                        children: [
                          Text(
                            "View Map",
                            style: context.textStyles.labelLarge?.bold.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.map,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ActiveDisasterCard(
                      title: "Hurricane Idalia Recovery",
                      location: "Florida, USA",
                      imagePath: "assets/images/flooded_street_with_destroyed_houses_gray_1774661707841.jpg",
                      progress: "64",
                      progressVal: 0.64,
                      status: "ACTIVE",
                    ),
                    ActiveDisasterCard(
                      title: "Maui Wildfire Relief",
                      location: "Lahaina, HI",
                      imagePath: "assets/images/burnt_trees_and_buildings_landscape_gray_1774661708379.jpg",
                      progress: "32",
                      progressVal: 0.32,
                      status: "URGENT",
                    ),
                    ActiveDisasterCard(
                      title: "Midwest Tornado Response",
                      location: "Arkansas, USA",
                      imagePath: "assets/images/debris_from_tornado_damage_gray_1774661709111.jpg",
                      progress: "88",
                      progressVal: 0.88,
                      status: "STABILIZING",
                    ),
                  ],
                ),
              ),
              Container(
                margin: AppSpacing.paddingLg,
                padding: AppSpacing.paddingXl,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.church,
                          size: 120,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ready to serve?",
                          style: context.textStyles.titleLarge?.bold.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          "Join our rapid response network to receive alerts when disasters strike near you.",
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton(
                          onPressed: () => context.go(AppRoutes.volunteerRegister),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: const Text(
                            "Register as Volunteer",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: const Text("Staff Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
