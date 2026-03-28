import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class OnboardingChecklistItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool completed;

  const OnboardingChecklistItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: completed ? const Color(0xFF2E7D32) : Theme.of(context).dividerColor,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFFE8F5E9) : Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              completed ? Icons.check_circle : icon,
              color: completed ? const Color(0xFF2E7D32) : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.bodyMedium?.semiBold,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (!completed)
            FilledButton.tonal(
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text("Start"),
            ),
        ],
      ),
    );
  }
}

class VolunteerOnboardingScreen extends StatelessWidget {
  const VolunteerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Onboarding"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome to Lighthouse!",
                style: context.textStyles.headlineSmall?.bold,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Before you can deploy to a disaster zone, please complete the following mandatory requirements. Your safety is our top priority.",
                style: context.textStyles.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: 0.25,
                            backgroundColor: Theme.of(context).dividerColor,
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 6,
                          ),
                        ),
                        Text(
                          "25%",
                          style: context.textStyles.titleMedium?.bold,
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Progress",
                            style: context.textStyles.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            "1 of 4 completed",
                            style: context.textStyles.titleMedium?.bold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                "Required Steps",
                style: context.textStyles.titleMedium?.bold,
              ),
              const SizedBox(height: AppSpacing.md),
              const OnboardingChecklistItem(
                icon: Icons.person,
                title: "Basic Profile Information",
                description: "Emergency contacts, medical alerts, and skills.",
                completed: true,
              ),
              const OnboardingChecklistItem(
                icon: Icons.gavel,
                title: "Liability & Safety Waiver",
                description: "Review and electronically sign our standard volunteer agreement.",
                completed: false,
              ),
              const OnboardingChecklistItem(
                icon: Icons.play_circle_outline,
                title: "Safety Training Video",
                description: "Watch a 15-minute introductory video on disaster site protocols.",
                completed: false,
              ),
              const OnboardingChecklistItem(
                icon: Icons.verified_user,
                title: "Background Check Consent",
                description: "Authorize a standard background check for working with vulnerable populations.",
                completed: false,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => context.push(AppRoutes.volunteerDashboard),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text("Go to Volunteer Dashboard"),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
