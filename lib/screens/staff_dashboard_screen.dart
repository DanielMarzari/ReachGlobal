import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';
import '../services/supabase_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

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
  final String? imgDesc;
  final String? coverImageUrl;
  final String status;
  final String progress;
  final double progressDecimal;
  final bool isUrgent;
  final String? disasterId;

  const EventSummaryCard({
    super.key,
    required this.title,
    required this.location,
    this.imgDesc,
    this.coverImageUrl,
    required this.status,
    required this.progress,
    required this.progressDecimal,
    required this.isUrgent,
    this.disasterId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disasterId != null
          ? () => context.push(AppRoutes.responseSetup,
              extra: {'disasterId': disasterId, 'disasterName': title})
          : null,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
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
                if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                  Image.network(
                    coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(context),
                  )
                else if (imgDesc != null)
                  Image.asset(imgDesc!, fit: BoxFit.cover)
                else
                  _imagePlaceholder(context),
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
                      onPressed: disasterId != null
                          ? () => context.push(AppRoutes.projectDetailStaff, extra: {'id': disasterId, 'name': title})
                          : null,
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
    )); // InkWell + Container
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.report_problem_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
      ),
    );
  }
}

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  List<Map<String, dynamic>> _disasters = [];
  bool _loadingDisasters = true;

  @override
  void initState() {
    super.initState();
    _loadDisasters();
  }

  Future<void> _loadDisasters() async {
    try {
      final auth = context.read<AuthService>();
      List<dynamic> data;
      if (auth.isSuperAdmin) {
        // Super admin sees all active disasters
        data = await SupabaseService.client
            .from('disasters')
            .select('id, name, type, location_name, status, cover_image_url')
            .eq('status', 'active')
            .order('created_at', ascending: false);
      } else {
        // Coordinator sees only assigned disasters
        data = await SupabaseService.client
            .from('disasters')
            .select('id, name, type, location_name, status, cover_image_url, staff_event_permissions!inner(user_id)')
            .eq('status', 'active')
            .eq('staff_event_permissions.user_id', SupabaseService.currentUser?.id ?? '');
      }
      if (mounted) setState(() { _disasters = List<Map<String, dynamic>>.from(data); _loadingDisasters = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingDisasters = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Command Center"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
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
                    Row(
                      children: [
                        QuickAction(
                          icon: Icons.add_location_alt_rounded,
                          label: "Create Response",
                          onTap: () => context.push(AppRoutes.staffEvent),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        QuickAction(
                          icon: Icons.person_add_rounded,
                          label: "Add Staff",
                          onTap: () => context.push('/staff/add-staff'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        QuickAction(
                          icon: Icons.inventory_2_rounded,
                          label: "Log Supplies",
                          onTap: () => context.push(AppRoutes.staffMaterials),
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
                          "Active Responses",
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
                    if (_loadingDisasters)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(),
                      ))
                    else if (_disasters.isEmpty)
                      Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Center(child: Text('No active responses.', style: context.textStyles.bodyMedium)),
                      )
                    else
                      ...(_disasters.map((d) => EventSummaryCard(
                        title: d['name'] as String,
                        location: d['location_name'] as String,
                        coverImageUrl: d['cover_image_url'] as String?,
                        imgDesc: null,
                        status: (d['status'] as String).toUpperCase(),
                        progress: '—',
                        progressDecimal: 0.0,
                        isUrgent: false,
                        disasterId: d['id'] as String,
                      )).toList()),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go(AppRoutes.staffProjects);
              break;
            case 2:
              context.go(AppRoutes.staffVolunteers);
              break;
            case 3:
              context.go(AppRoutes.staffMaterials);
              break;
            case 4:
              context.go(AppRoutes.staffFinancial);
              break;
            case 5:
              context.go(AppRoutes.staffReports);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Projects",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "Volunteers",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Materials",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Financial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: "Reports",
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
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
