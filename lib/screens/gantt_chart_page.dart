import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class GanttTask {
  final String title;
  final int startDay;
  final int durationDays;
  final Color color;
  final bool isCompleted;

  GanttTask({
    required this.title,
    required this.startDay,
    required this.durationDays,
    required this.color,
    this.isCompleted = false,
  });
}

class GanttChartPage extends StatelessWidget {
  const GanttChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      GanttTask(title: "Assessment", startDay: 0, durationDays: 2, color: const Color(0xFF2E7D32), isCompleted: true),
      GanttTask(title: "Debris Removal", startDay: 1, durationDays: 3, color: const Color(0xFF2E7D32), isCompleted: true),
      GanttTask(title: "Muck & Gut", startDay: 3, durationDays: 4, color: const Color(0xFF2E7D32), isCompleted: true),
      GanttTask(title: "Structural Drying", startDay: 6, durationDays: 5, color: Theme.of(context).colorScheme.primary),
      GanttTask(title: "Mold Remediation", startDay: 10, durationDays: 3, color: Theme.of(context).colorScheme.primary),
      GanttTask(title: "Roof Repair", startDay: 12, durationDays: 4, color: Theme.of(context).colorScheme.secondary),
      GanttTask(title: "Final Inspection", startDay: 15, durationDays: 1, color: Theme.of(context).colorScheme.secondary),
    ];

    const int totalDays = 16;
    const double dayWidth = 40.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Timeline"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Smith Family Residence",
                style: context.textStyles.headlineSmall?.bold,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Estimated completion: Oct 28",
                style: context.textStyles.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Header
                    Row(
                      children: List.generate(totalDays, (index) {
                        return Container(
                          width: dayWidth,
                          alignment: Alignment.center,
                          child: Text(
                            "Day\n${index + 1}",
                            style: context.textStyles.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Timeline Tasks
                    ...tasks.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: totalDays * dayWidth,
                              height: 40,
                              child: Stack(
                                children: [
                                  // Background grid
                                  Row(
                                    children: List.generate(totalDays, (index) {
                                      return Container(
                                        width: dayWidth,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Theme.of(context).dividerColor.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  // Task bar
                                  Positioned(
                                    left: task.startDay * dayWidth,
                                    width: task.durationDays * dayWidth,
                                    child: Container(
                                      height: 32,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: task.color.withOpacity(task.isCompleted ? 0.7 : 1.0),
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                                      child: Text(
                                        task.title,
                                        style: context.textStyles.labelSmall?.bold.copyWith(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(context, const Color(0xFF2E7D32), "Completed"),
                  const SizedBox(width: AppSpacing.md),
                  _buildLegendItem(context, Theme.of(context).colorScheme.primary, "In Progress"),
                  const SizedBox(width: AppSpacing.md),
                  _buildLegendItem(context, Theme.of(context).colorScheme.secondary, "Upcoming"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
