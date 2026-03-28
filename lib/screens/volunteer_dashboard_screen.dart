import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class VolStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const VolStatCard({
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
                    style: context.textStyles.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: context.textStyles.titleLarge?.bold,
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final String tag;
  final String date;
  final String title;
  final String location;

  const AssignmentCard({
    super.key,
    required this.tag,
    required this.date,
    required this.title,
    required this.location,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  tag,
                  style: context.textStyles.labelSmall?.bold.copyWith(color: const Color(0xFF2E7D32)),
                ),
              ),
              Text(
                date,
                style: context.textStyles.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: context.textStyles.titleMedium?.bold,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(color: Theme.of(context).dividerColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFD2B48C),
                    child: Text("JD", style: TextStyle(fontSize: 10, color: Colors.black)),
                  ),
                  Transform.translate(
                    offset: const Offset(-8, 0),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF87CEEB),
                      child: Text("MS", style: TextStyle(fontSize: 10, color: Colors.black)),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-16, 0),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "+3",
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.projectDetailPublic),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text("View Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingItem extends StatelessWidget {
  final String label;
  final bool done;

  const OnboardingItem({
    super.key,
    required this.label,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF2E7D32) : Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: done ? const Color(0xFF2E7D32) : Theme.of(context).dividerColor,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              done ? Icons.check_rounded : Icons.circle_outlined,
              color: done ? Colors.white : Theme.of(context).dividerColor,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color: done ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurface,
                decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go(AppRoutes.login),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: AppSpacing.paddingLg,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7C9CB4),
                      Color(0xFF1B5E20),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back,",
                              style: context.textStyles.bodyMedium?.copyWith(color: const Color(0xFFE8F5E9)),
                            ),
                            Text(
                              "Volunteer Sarah",
                              style: context.textStyles.headlineMedium?.bold.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: const Color(0x33FFFFFF), width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            "assets/images/portrait_of_a_smiling_female_volunteer_in_a_green_vest_green_1774661719528.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Row(
                      children: [
                        VolStatCard(
                          icon: Icons.timer_rounded,
                          label: "Total Hours",
                          value: "124",
                        ),
                        SizedBox(width: AppSpacing.md),
                        VolStatCard(
                          icon: Icons.home_repair_service_rounded,
                          label: "Projects",
                          value: "8",
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
                          "Onboarding Status",
                          style: context.textStyles.titleMedium?.bold,
                        ),
                        Text(
                          "75% Complete",
                          style: context.textStyles.labelLarge?.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.75,
                              minHeight: 8,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const OnboardingItem(label: "Safety Training Video", done: true),
                          const OnboardingItem(label: "Liability Waiver Signed", done: true),
                          const OnboardingItem(label: "Background Check", done: true),
                          const OnboardingItem(label: "Site Leader Orientation", done: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Upcoming Assignments",
                          style: context.textStyles.titleMedium?.bold,
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text("Find More"),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const AssignmentCard(
                      tag: "HURRICANE RESPONSE",
                      date: "Oct 24, 08:00 AM",
                      title: "Debris Removal & Tarping",
                      location: "124 Coastal Way, Gulfport",
                    ),
                    const AssignmentCard(
                      tag: "FLOOD RELIEF",
                      date: "Oct 27, 09:00 AM",
                      title: "Supply Distribution",
                      location: "Central Baptist Hub, Mobile",
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
                      "Activity History",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      height: 220,
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Hours per month",
                            style: context.textStyles.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 40,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const labels = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
                                        final index = value.toInt();
                                        if (index >= 0 && index < labels.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              labels[index],
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                fontSize: 10,
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
                                  horizontalInterval: 10,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  _makeBarData(context, 0, 12),
                                  _makeBarData(context, 1, 18),
                                  _makeBarData(context, 2, 8),
                                  _makeBarData(context, 3, 24),
                                  _makeBarData(context, 4, 32),
                                  _makeBarData(context, 5, 14),
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
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.push(AppRoutes.volunteerOnboarding);
              break;
            case 2:
              context.push(AppRoutes.userProfile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Assignments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Onboarding",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
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
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
