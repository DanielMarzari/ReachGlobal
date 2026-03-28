import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';
import '../services/supabase_service.dart';

class ActiveDisasterCard extends StatelessWidget {
  final String disasterId;
  final String title;
  final String location;
  final String? imageUrl;
  final String disasterType;
  final String status;

  const ActiveDisasterCard({
    super.key,
    required this.disasterId,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.disasterType,
    required this.status,
  });

  Widget _typeIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'flood':
        icon = Icons.water_drop;
        color = const Color(0xFF1976D2);
        break;
      case 'fire':
        icon = Icons.local_fire_department;
        color = const Color(0xFFD84315);
        break;
      case 'hurricane':
        icon = Icons.air;
        color = const Color(0xFF0097A7);
        break;
      case 'tornado':
        icon = Icons.tornado;
        color = const Color(0xFF616161);
        break;
      case 'earthquake':
        icon = Icons.landscape;
        color = const Color(0xFF5D4037);
        break;
      default:
        icon = Icons.warning;
        color = const Color(0xFF001F3F);
    }

    return Container(
      color: color,
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return 'Flood Response';
      case 'fire':
        return 'Fire Relief';
      case 'hurricane':
        return 'Hurricane Response';
      case 'tornado':
        return 'Tornado Relief';
      case 'earthquake':
        return 'Earthquake Relief';
      default:
        return 'Disaster Response';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.eventOverview, extra: {'id': disasterId, 'name': title, 'location': location}),
      child: Container(
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
                  imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : _typeIcon(disasterType),
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
                  Text(
                    _getTypeLabel(disasterType),
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  List<Map<String, dynamic>> _disasters = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDisasters();
  }

  Future<void> _loadDisasters() async {
    try {
      final data = await SupabaseService.client
          .from('disasters')
          .select('id, name, type, location_name, status, description, image_url, start_date')
          .eq('public_visible', true)
          .eq('status', 'active')
          .order('start_date', ascending: false);
      if (mounted) setState(() { _disasters = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Lighthouse",
                            style: context.textStyles.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Disaster Relief Coordination",
                            style: context.textStyles.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  // Constrain max width on larger screens so content doesn't stretch.
                  final maxContentWidth = constraints.maxWidth >= 1100
                      ? 1040.0
                      : (constraints.maxWidth >= 800 ? 860.0 : double.infinity);

                  late final Widget cards;

                  if (_loading) {
                    cards = const Center(child: CircularProgressIndicator());
                  } else if (_error != null) {
                    cards = Center(child: Text('Could not load events', style: context.textStyles.bodyMedium));
                  } else if (_disasters.isEmpty) {
                    cards = Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text('No active disaster responses at this time.', style: context.textStyles.bodyMedium, textAlign: TextAlign.center),
                      ),
                    );
                  } else {
                    final isMobile = constraints.maxWidth < 700;
                    final isDesktop = constraints.maxWidth >= 1100;

                    final events = _disasters.map((d) => ActiveDisasterCard(
                      disasterId: d['id'] as String,
                      title: d['name'] as String,
                      location: d['location_name'] as String,
                      imageUrl: d['image_url'] as String?,
                      disasterType: d['type'] as String? ?? 'other',
                      status: d['status'] as String? ?? 'active',
                    )).toList();

                    cards = isMobile
                        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: events)
                        : GridView.count(
                            crossAxisCount: isDesktop ? 3 : 2,
                            mainAxisSpacing: AppSpacing.lg,
                            crossAxisSpacing: AppSpacing.lg,
                            childAspectRatio: isDesktop ? 1.15 : 1.05,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: events,
                          );
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Active Responses",
                                      style: context.textStyles.titleLarge?.bold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push(AppRoutes.eventOverview),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
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
                            cards,
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
