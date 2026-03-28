import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class StaffStatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color border;
  final Color textColor;

  const StaffStatusChip({
    super.key,
    required this.label,
    required this.bg,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: context.textStyles.labelSmall?.bold.copyWith(color: textColor),
      ),
    );
  }
}

class TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool completed;
  final bool last;

  const TimelineStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed ? const Color(0xFF2E7D32) : Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed ? const Color(0xFF2E7D32) : Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                completed ? Icons.check : Icons.circle,
                size: 14,
                color: completed ? Colors.white : Theme.of(context).dividerColor,
              ),
            ),
            if (!last)
              Container(
                width: 2,
                height: 40,
                color: Theme.of(context).dividerColor,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textStyles.bodyMedium?.semiBold.copyWith(
                  color: completed ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: context.textStyles.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (!last) const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ],
    );
  }
}

class StaffMaterialItem extends StatelessWidget {
  final bool checked;
  final String name;
  final String needed;
  final String status;

  const StaffMaterialItem({
    super.key,
    required this.checked,
    required this.name,
    required this.needed,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUrgent = status == "Urgent";
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
          Checkbox(
            value: checked,
            onChanged: (val) {},
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  needed,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StaffStatusChip(
            label: status,
            bg: isUrgent ? const Color(0xFFFFEBEE) : Theme.of(context).scaffoldBackgroundColor,
            border: isUrgent ? const Color(0xFFBA1A1A) : Theme.of(context).dividerColor,
            textColor: isUrgent ? const Color(0xFFBA1A1A) : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class VolunteerAvatar extends StatelessWidget {
  final String desc;

  const VolunteerAvatar({super.key, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        desc,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ProjectDetailStaffScreen extends StatelessWidget {
  const ProjectDetailStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Project #882-J",
                              style: context.textStyles.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              "Smith Family Residence",
                              style: context.textStyles.titleMedium?.bold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Damage Assessment Photos",
                          style: context.textStyles.titleSmall?.bold,
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                          ),
                          child: Text(
                            "View All (12)",
                            style: context.textStyles.labelLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            margin: const EdgeInsets.only(right: AppSpacing.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  "assets/images/hurricane_damaged_roof_blue_tarp_blue_1774661723716.jpg",
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.cancel, color: const Color(0xCCFFFFFF), size: 20),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 140,
                            height: 140,
                            margin: const EdgeInsets.only(right: AppSpacing.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  "assets/images/flooded_living_room_interior_gray_1774661724183.jpg",
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(Icons.cancel, color: const Color(0xCCFFFFFF), size: 20),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2,
                              ), // Ideally dashed border
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 28,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  "Upload",
                                  style: context.textStyles.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Project Timeline",
                          style: context.textStyles.titleSmall?.bold,
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.ganttChart),
                          child: const StaffStatusChip(
                            label: "IN PROGRESS",
                            bg: Color(0xFFE3F2FD),
                            border: Color(0xFFBBDEFB),
                            textColor: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const TimelineStep(
                      title: "Debris Removal",
                      subtitle: "Completed Oct 12 by Team Alpha",
                      completed: true,
                      last: false,
                    ),
                    const TimelineStep(
                      title: "Muck & Gut",
                      subtitle: "Completed Oct 15 by Team Alpha",
                      completed: true,
                      last: false,
                    ),
                    const TimelineStep(
                      title: "Structural Drying",
                      subtitle: "Current Phase - Est. 3 days left",
                      completed: false,
                      last: false,
                    ),
                    const TimelineStep(
                      title: "Roof Repair",
                      subtitle: "Scheduled for Oct 22",
                      completed: false,
                      last: true,
                    ),
                  ],
                ),
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
                          "Materials Checklist",
                          style: context.textStyles.titleSmall?.bold,
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("Add Item"),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const StaffMaterialItem(
                      checked: true,
                      name: "Plywood Sheets (4x8)",
                      needed: "12 units",
                      status: "On-site",
                    ),
                    const StaffMaterialItem(
                      checked: false,
                      name: "Roofing Shingles (Charcoal)",
                      needed: "20 bundles",
                      status: "Urgent",
                    ),
                    const StaffMaterialItem(
                      checked: false,
                      name: "Industrial Fans",
                      needed: "4 units",
                      status: "In Transit",
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
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Assigned Volunteers",
                      style: context.textStyles.titleSmall?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const VolunteerAvatar(desc: "assets/images/man_in_construction_vest_orange_1774661725163.jpg"),
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: const VolunteerAvatar(desc: "assets/images/woman_with_safety_glasses_gray_1774661725598.jpg"),
                            ),
                            Transform.translate(
                              offset: const Offset(-16, 0),
                              child: const VolunteerAvatar(desc: "assets/images/young_man_smiling_gray_1774661726355.jpg"),
                            ),
                            Transform.translate(
                              offset: const Offset(-24, 0),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "+5",
                                  style: context.textStyles.labelSmall?.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text("Manage Crew"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(color: Theme.of(context).dividerColor),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text("Update Status"),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size.fromHeight(50),
                          elevation: 2,
                        ),
                        child: const Text("Complete Stage"),
                      ),
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
