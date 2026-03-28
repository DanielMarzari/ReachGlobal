import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    label,
                    style: context.textStyles.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: context.textStyles.titleMedium?.bold,
            ),
          ],
        ),
      ),
    );
  }
}

class SitePinItem extends StatelessWidget {
  final String address;
  final String status;
  final Color statusColor;
  final String imgDesc;

  const SitePinItem({
    super.key,
    required this.address,
    required this.status,
    required this.statusColor,
    required this.imgDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              imgDesc,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: context.textStyles.bodyMedium?.semiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      status,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class GalleryImage extends StatelessWidget {
  final String desc;

  const GalleryImage({super.key, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        desc,
        fit: BoxFit.cover,
      ),
    );
  }
}

class DisasterEventOverviewScreen extends StatelessWidget {
  const DisasterEventOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Hurricane Idalia Response",
                      style: context.textStyles.headlineMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "Taylor County, Florida",
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 280,
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/topographic_map_with_satellite_view_of_coastal_florida_green_1774661709794.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 280,
                    ),
                    const Positioned(
                      top: 40,
                      left: 60,
                      child: Icon(Icons.location_on, color: Colors.red, size: 32),
                    ),
                    const Positioned(
                      top: 120,
                      right: 100,
                      child: Icon(Icons.location_on, color: Colors.green, size: 32),
                    ),
                    const Positioned(
                      bottom: 80,
                      left: 120,
                      child: Icon(Icons.location_on, color: Colors.orange, size: 32),
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  "Urgent",
                                  style: context.textStyles.labelSmall,
                                ),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  "Cleared",
                                  style: context.textStyles.labelSmall,
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
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Impact Summary",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Row(
                      children: [
                        StatCard(icon: Icons.assessment, label: "Active Projects", value: "42"),
                        SizedBox(width: AppSpacing.md),
                        StatCard(icon: Icons.groups, label: "Volunteers", value: "128"),
                        SizedBox(width: AppSpacing.md),
                        StatCard(icon: Icons.payments, label: "Funds Raised", value: "\$84k"),
                      ],
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
                          "Project Sites",
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
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.projectDetailPublic),
                      child: const SitePinItem(
                        address: "124 Oak Lane, Perry",
                        status: "Debris Removal",
                        statusColor: Colors.red,
                        imgDesc: "assets/images/damaged_house_hurricane_gray_1774661710725.jpg",
                      ),
                    ),
                    const SitePinItem(
                      address: "892 Gulf Rd, Steinhatchee",
                      status: "Roof Tarping",
                      statusColor: Colors.orange,
                      imgDesc: "assets/images/workers_on_roof_gray_1774661711416.jpg",
                    ),
                    const SitePinItem(
                      address: "44 Shoreline Dr",
                      status: "Muck Out Complete",
                      statusColor: Colors.green,
                      imgDesc: "assets/images/cleaned_interior_house_white_1774661712371.jpg",
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Field Gallery",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          GalleryImage(desc: "assets/images/relief_workers_praying_together_gray_1774661712971.jpg"),
                          GalleryImage(desc: "assets/images/chainsaw_crew_clearing_trees_gray_1774661713513.jpg"),
                          GalleryImage(desc: "assets/images/lighthouse_mobile_kitchen_serving_food_gray_1774661714713.jpg"),
                          GalleryImage(desc: "assets/images/volunteers_unloading_supplies_gray_1774661715372.jpg"),
                        ],
                      ),
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
                        onPressed: () => context.push(AppRoutes.donationFlow),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          minimumSize: const Size.fromHeight(56),
                        ),
                        child: const Text("Donate Funds", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.push(AppRoutes.volunteerDashboard),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          minimumSize: const Size.fromHeight(56),
                        ),
                        child: const Text("Volunteer Now", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
