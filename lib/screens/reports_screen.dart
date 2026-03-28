import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': '1',
      'title': 'Event Summary Report',
      'description': 'Overview of all activities, volunteers, and outcomes',
      'icon': Icons.summarize,
    },
    {
      'id': '2',
      'title': 'Donor Report',
      'description': 'Detailed list of all donors and their contributions',
      'icon': Icons.people,
    },
    {
      'id': '3',
      'title': 'Material Donations Report',
      'description': 'Inventory of all donated materials and value',
      'icon': Icons.inventory_2,
    },
    {
      'id': '4',
      'title': 'Expense Breakdown',
      'description': 'Detailed breakdown of all expenses by category',
      'icon': Icons.bar_chart,
    },
    {
      'id': '5',
      'title': 'Volunteer Hours Report',
      'description': 'Summary of volunteer hours by person and skill',
      'icon': Icons.schedule,
    },
  ];

  final List<Map<String, dynamic>> _monthlyData = [
    {'month': 'Jan', 'donations': 12000, 'expenses': 8500},
    {'month': 'Feb', 'donations': 15000, 'expenses': 10200},
    {'month': 'Mar', 'donations': 18500, 'expenses': 12000},
  ];

  void _generateReport(String reportTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $reportTitle...'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate report generation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$reportTitle exported as PDF'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: context.textStyles.titleMedium?.bold,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary card
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border:
                      Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Summary',
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          context,
                          'Total Raised',
                          '\$45,500',
                          Icons.money,
                        ),
                        _buildSummaryItem(
                          context,
                          'Total Spent',
                          '\$32,150',
                          Icons.credit_card,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          context,
                          'Volunteer Hours',
                          '1,240 hrs',
                          Icons.schedule,
                        ),
                        _buildSummaryItem(
                          context,
                          'Projects Complete',
                          '1 of 4',
                          Icons.check_circle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Chart section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border:
                      Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Donations vs Expenses',
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 200,
                      child: _buildSimpleChart(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            // Report cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: _reportTypes.map((report) {
                  return GestureDetector(
                    onTap: () =>
                        _generateReport(report['title']),
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface,
                        borderRadius:
                            BorderRadius.circular(
                              AppRadius.lg,
                            ),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color:
                                Color(0x0D000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                          AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    AppSpacing
                                        .sm,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: Theme.of(
                                            context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(
                                          0.1,
                                        ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                              AppRadius
                                                  .md,
                                            ),
                                  ),
                                  child: Icon(
                                    report[
                                        'icon'],
                                    color: Theme.of(
                                            context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      AppSpacing
                                          .md,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        report[
                                            'title'],
                                        style: context
                                            .textStyles
                                            .labelSmall
                                            ?.bold,
                                      ),
                                      SizedBox(
                                        height:
                                            AppSpacing
                                                .xs,
                                      ),
                                      Text(
                                        report[
                                            'description'],
                                        style: context
                                            .textStyles
                                            .bodySmall,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height:
                                  AppSpacing
                                      .md,
                            ),
                            SizedBox(
                              width:
                                  double
                                      .infinity,
                              child:
                                  OutlinedButton
                                      .icon(
                                onPressed: () =>
                                    _generateReport(
                                      report[
                                          'title'],
                                    ),
                                icon: const Icon(
                                  Icons
                                      .file_download,
                                ),
                                label:
                                    const Text(
                                  'Export PDF',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 5,
        onTap: (index) {
          switch (index) {
            case 0: context.go(AppRoutes.staffDashboard); break;
            case 1: context.go(AppRoutes.staffProjects); break;
            case 2: context.go(AppRoutes.staffVolunteers); break;
            case 3: context.go(AppRoutes.staffMaterials); break;
            case 4: context.go(AppRoutes.staffFinancial); break;
            case 5: context.go(AppRoutes.staffReports); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Volunteers"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Materials"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Financial"),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: "Reports"),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: context.textStyles.labelSmall,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style:
                context.textStyles.titleMedium?.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    final maxValue =
        _monthlyData.fold<double>(0, (max, item) {
      final donations = item['donations'] as int;
      return donations > max ? donations.toDouble() : max;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _monthlyData.map((data) {
        final donationHeight =
            (data['donations'] as int) / maxValue * 150;
        final expenseHeight =
            (data['expenses'] as int) / maxValue * 150;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Legend
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '\$${(data['donations'] / 1000).toStringAsFixed(0)}k',
                  style: context.textStyles.labelSmall,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            // Bars
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Donation bar
                Container(
                  width: 20,
                  height: donationHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                // Expense bar
                Container(
                  width: 20,
                  height: expenseHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0582A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              data['month'],
              style: context.textStyles.labelSmall,
            ),
          ],
        );
      }).toList(),
    );
  }
}
