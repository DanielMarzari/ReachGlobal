import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.bg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: context.textStyles.labelSmall?.bold.copyWith(color: textColor),
      ),
    );
  }
}

class MaterialItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final double progress;
  final String current;
  final String total;
  final String unit;

  const MaterialItem({
    super.key,
    required this.icon,
    required this.name,
    required this.progress,
    required this.current,
    required this.total,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.textStyles.bodyMedium?.semiBold,
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Theme.of(context).dividerColor,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$current / $total",
                style: context.textStyles.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                unit,
                style: context.textStyles.labelSmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VolunteerSlot extends StatelessWidget {
  final String day;
  final String date;
  final String role;
  final String time;

  const VolunteerSlot({
    super.key,
    required this.day,
    required this.date,
    required this.role,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day,
                style: context.textStyles.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                date,
                style: context.textStyles.titleMedium?.bold,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: context.textStyles.bodyMedium?.semiBold,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      time,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }
}

class ProjectDetailPublicScreen extends StatelessWidget {
  const ProjectDetailPublicScreen({super.key, this.disaster});

  /// Optional disaster/response payload passed via `GoRouterState.extra`.
  /// Expected keys: id, name, location_name, type, image_url.
  final Map<String, dynamic>? disaster;

  @override
  Widget build(BuildContext context) {
    final name = (disaster?['name'] as String?) ?? 'Project Details';
    final locationName = (disaster?['location_name'] as String?) ?? 'Unknown location';
    final type = (disaster?['type'] as String?) ?? '';
    final imageUrl = (disaster?['image_url'] as String?);

    final headerSubtitle = type.isNotEmpty ? '$locationName • $type' : locationName;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 48, AppSpacing.lg, AppSpacing.md),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shadowColor: Colors.black26,
                      elevation: 2,
                    ),
                  ),
                  Text(
                    "Project Details",
                    style: context.textStyles.titleMedium?.bold,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shadowColor: Colors.black26,
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/images/hurricane_damaged_house_roof_repair_gray_1774661715888.jpg",
                    fit: BoxFit.cover,
                  ),
                  if (imageUrl != null)
                    Positioned.fill(
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: AppSpacing.paddingLg,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xAA000000),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StatusChip(
                            label: "IN PROGRESS",
                            bg: Color(0xFFE67E22),
                            textColor: Colors.white,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            name,
                            style: context.textStyles.headlineMedium?.bold.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white, size: 16),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                headerSubtitle,
                                style: context.textStyles.bodySmall?.copyWith(color: Colors.white),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "65%",
                        style: context.textStyles.titleLarge?.bold.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Complete",
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor),
                  Column(
                    children: [
                      Text(
                        "12",
                        style: context.textStyles.titleLarge?.bold,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Volunteers",
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor),
                  Column(
                    children: [
                      Text(
                        "4d",
                        style: context.textStyles.titleLarge?.bold,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Remaining",
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.horizontalLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Assessment",
                    style: context.textStyles.titleMedium?.bold,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "Severe roof damage and water intrusion in the primary living area. Structural integrity is sound, but immediate tarping and interior mucking are required to prevent mold growth.",
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            "assets/images/damaged_living_room_flood_gray_1774661716545.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            "assets/images/broken_roof_shingles_gray_1774661717386.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            "assets/images/disaster_debris_yard_gray_1774661718111.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Divider(color: Theme.of(context).dividerColor),
            ),
            Padding(
              padding: AppSpacing.horizontalLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Materials Needed",
                        style: context.textStyles.titleMedium?.bold,
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.donationFlow),
                        child: Text(
                          "Donate Items",
                          style: context.textStyles.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const MaterialItem(
                    icon: Icons.roofing,
                    name: "Blue Tarps (20x30)",
                    progress: 0.8,
                    current: "8",
                    total: "10",
                    unit: "units",
                  ),
                  const MaterialItem(
                    icon: Icons.inventory_2,
                    name: "Plywood Sheets",
                    progress: 0.4,
                    current: "12",
                    total: "30",
                    unit: "sheets",
                  ),
                  const MaterialItem(
                    icon: Icons.format_paint,
                    name: "Mold Remediator",
                    progress: 1.0,
                    current: "5",
                    total: "5",
                    unit: "gallons",
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
                    "Open Volunteer Slots",
                    style: context.textStyles.titleMedium?.bold,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const VolunteerSlot(
                    day: "SAT",
                    date: "21",
                    role: "Debris Removal",
                    time: "08:00 AM - 12:00 PM",
                  ),
                  const VolunteerSlot(
                    day: "SAT",
                    date: "21",
                    role: "General Labor",
                    time: "01:00 PM - 05:00 PM",
                  ),
                  const VolunteerSlot(
                    day: "SUN",
                    date: "22",
                    role: "Roof Tarping Team",
                    time: "08:00 AM - 02:00 PM",
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push(AppRoutes.donationFlow),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2B48C),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Donate Funds",
                          style: context.textStyles.labelLarge?.bold.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InkWell(
                      onTap: () => context.go(AppRoutes.volunteerRegister),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Volunteer Now",
                          style: context.textStyles.labelLarge?.bold.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
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
