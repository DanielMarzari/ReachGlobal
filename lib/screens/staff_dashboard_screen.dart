import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class UrgentFlag extends StatelessWidget {
  final String label;

  const UrgentFlag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: const Color(0xFFFFA39E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.report_problem_rounded,
            color: Color(0xFFBA1A1A),
            size: 14,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelSmall?.bold.copyWith(color: const Color(0xFFBA1A1A)),
          ),
        ],
      ),
    );
  }
}

class StaffStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StaffStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
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
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(height: AppSpacing.xs),
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
      ),
    );
  }
}

class EventSummaryCard extends StatelessWidget {
  final String title;
  final String location;
  final String imgDesc;
  final String status;
  final String progress;
  final double progressDecimal;
  final bool isUrgent;

  const EventSummaryCard({
    super.key,
    required this.title,
    required this.location,
    required this.imgDesc,
    required this.status,
    required this.progress,
    required this.progressDecimal,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 140,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imgDesc,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: Color(0x66000000),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(AppRadius.lg)),
                    ),
                    child: Text(
                      status,
                      style: context.textStyles.labelSmall?.bold.copyWith(color: Colors.white),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.textStyles.titleLarge?.bold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 14,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                location,
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(width: AppSpacing.md),
                      const UrgentFlag(label: "URGENT"),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Recovery Progress",
                                style: context.textStyles.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                "$progress%",
                                style: context.textStyles.labelSmall?.bold,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressDecimal,
                              minHeight: 8,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 32,
                      width: 80,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).dividerColor,
                              backgroundImage: const AssetImage("assets/images/volunteer_man_blue_1774661721668.jpg"),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).dividerColor,
                              backgroundImage: const AssetImage("assets/images/volunteer_woman_blue_1774661722277.jpg"),
                            ),
                          ),
                          Positioned(
                            left: 40,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).dividerColor,
                              backgroundImage: const AssetImage("assets/images/worker_blue_1774661722857.jpg"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push(AppRoutes.projectDetailStaff),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text("Manage Event"),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
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
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: context.textStyles.labelSmall?.semiBold,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.notification_important_rounded),
        label: const Text("Broadcast Alert"),
        backgroundColor: const Color(0xFFBA1A1A),
        foregroundColor: Colors.white,
      ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Command Center",
                          style: context.textStyles.headlineMedium?.bold,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          "Lighthouse Disaster Relief",
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: const Text("JD"),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: const Row(
                  children: [
                    StaffStatCard(
                      icon: Icons.home_work_rounded,
                      value: "124",
                      label: "Active Projects",
                    ),
                    SizedBox(width: AppSpacing.md),
                    StaffStatCard(
                      icon: Icons.groups_rounded,
                      value: "852",
                      label: "Volunteers",
                    ),
                    SizedBox(width: AppSpacing.md),
                    StaffStatCard(
                      icon: Icons.payments_rounded,
                      value: "\$42k",
                      label: "Funds Deployed",
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
                      "Quick Actions",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Row(
                      children: [
                        QuickAction(
                          icon: Icons.add_location_alt_rounded,
                          label: "New Event",
                        ),
                        SizedBox(width: AppSpacing.md),
                        QuickAction(
                          icon: Icons.person_add_rounded,
                          label: "Deploy Team",
                        ),
                        SizedBox(width: AppSpacing.md),
                        QuickAction(
                          icon: Icons.inventory_2_rounded,
                          label: "Log Supplies",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Active Disaster Events",
                          style: context.textStyles.titleMedium?.bold,
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: const Text("See All"),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const EventSummaryCard(
                      title: "Hurricane Idalia Recovery",
                      location: "Perry, Florida",
                      imgDesc: "assets/images/flooded_street_with_fallen_trees_gray_1774661720119.jpg",
                      status: "DEPLOYED",
                      progress: "64",
                      progressDecimal: 0.64,
                      isUrgent: true,
                    ),
                    const EventSummaryCard(
                      title: "Rolling Fork Tornado",
                      location: "Sharkey County, MS",
                      imgDesc: "assets/images/destroyed_wooden_house_debris_gray_1774661720710.jpg",
                      status: "STABILIZING",
                      progress: "38",
                      progressDecimal: 0.38,
                      isUrgent: false,
                    ),
                    const EventSummaryCard(
                      title: "Maui Wildfire Relief",
                      location: "Lahaina, Hawaii",
                      imgDesc: "assets/images/burnt_landscape_with_palm_trees_gray_1774661721154.jpg",
                      status: "ASSESSING",
                      progress: "12",
                      progressDecimal: 0.12,
                      isUrgent: true,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Resource Allocation",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => Theme.of(context).colorScheme.surface,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.round()}%',
                                  TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const labels = ['Food', 'Water', 'Tools', 'Med'];
                                  final index = value.toInt();
                                  if (index >= 0 && index < labels.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        labels[index],
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Theme.of(context).dividerColor.withOpacity(0.5),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _makeBarData(context, 0, 80),
                            _makeBarData(context, 1, 45),
                            _makeBarData(context, 2, 60),
                            _makeBarData(context, 3, 30),
                          ],
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

  BarChartGroupData _makeBarData(BuildContext context, int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Theme.of(context).colorScheme.primary,
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
