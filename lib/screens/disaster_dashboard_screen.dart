import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';
import '../services/supabase_service.dart';

/// Per-disaster event dashboard.
/// Shows event info and a list of worksites (site_assessments).
/// Staff tap "Add Worksite" to launch the worksite setup wizard.
class DisasterDashboardScreen extends StatefulWidget {
  final String disasterId;
  final String disasterName;

  const DisasterDashboardScreen({
    Key? key,
    required this.disasterId,
    required this.disasterName,
  }) : super(key: key);

  @override
  State<DisasterDashboardScreen> createState() =>
      _DisasterDashboardScreenState();
}

class _DisasterDashboardScreenState
    extends State<DisasterDashboardScreen> {
  Map<String, dynamic>? _disaster;
  List<Map<String, dynamic>> _worksites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final disaster = await SupabaseService.client
          .from('disasters')
          .select(
              'id, name, type, location_name, start_date, base_camp_addr, description, status, image_url')
          .eq('id', widget.disasterId)
          .single();

      final worksites = await SupabaseService.client
          .from('worksites')
          .select(
              'id, owner_name, address, property_type, created_at, notes')
          .eq('disaster_id', widget.disasterId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _disaster = Map<String, dynamic>.from(disaster);
          _worksites =
              List<Map<String, dynamic>>.from(worksites);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'tornado':    return 'Tornado';
      case 'flood':      return 'Flood';
      case 'fire':       return 'Fire';
      case 'hurricane':  return 'Hurricane';
      case 'earthquake': return 'Earthquake';
      default:           return t[0].toUpperCase() + t.substring(1);
    }
  }

  String _propertyTypeLabel(String? t) {
    switch (t) {
      case 'single_family': return 'Single Family';
      case 'mobile_home':   return 'Mobile Home';
      case 'multi_family':  return 'Multi-Family';
      case 'commercial':    return 'Commercial';
      case 'church':        return 'Church / Non-Profit';
      default:              return t ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.staffDashboard),
        ),
        title: Text(
          widget.disasterName,
          style: context.textStyles.titleMedium?.bold,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.worksiteSetup, extra: {
            'disasterId': widget.disasterId,
            'disasterName': widget.disasterName,
          });
          // Refresh worksites after returning
          _load();
        },
        icon: const Icon(Icons.add_home_work_rounded),
        label: const Text('Add Worksite'),
        backgroundColor: const Color(0xFF1B3A5C),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    // ── Event header ──────────────────────────────
                    if (_disaster != null) _buildHeader(),

                    // ── Worksites list ────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Worksites',
                              style: context
                                  .textStyles.titleMedium?.bold),
                          Text(
                            '${_worksites.length} site${_worksites.length == 1 ? '' : 's'}',
                            style: context.textStyles.bodySmall
                                ?.copyWith(
                                    color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    if (_worksites.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            Icon(Icons.home_work_outlined,
                                size: 52,
                                color: Colors.grey[400]),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'No worksites yet.',
                              style: context.textStyles.bodyMedium
                                  ?.copyWith(
                                      color: Colors.grey[600]),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Tap "Add Worksite" to begin documenting a property.',
                              style: context.textStyles.bodySmall
                                  ?.copyWith(
                                      color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ..._worksites.map((w) => _buildWorksiteCard(w)),

                    SizedBox(height: 100), // FAB clearance
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final d = _disaster!;
    final imageUrl = d['image_url'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          SizedBox(
            height: 160,
            child: Image.network(imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[200])),
          ),
        Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3A5C)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _typeLabel(d['type'] ?? ''),
                      style: context.textStyles.labelSmall
                          ?.copyWith(
                              color: const Color(0xFF1B3A5C),
                              fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A6741)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: context.textStyles.labelSmall
                          ?.copyWith(
                              color: const Color(0xFF4A6741),
                              fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    d['location_name'] ?? '',
                    style: context.textStyles.bodySmall
                        ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                  ),
                ],
              ),
              if (d['start_date'] != null) ...[
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Started ${d['start_date']}',
                      style: context.textStyles.bodySmall
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                    ),
                  ],
                ),
              ],
              if ((d['description'] as String?)?.isNotEmpty ==
                  true) ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  d['description'],
                  style: context.textStyles.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        Divider(
            height: 1,
            color: Theme.of(context).dividerColor),
      ],
    );
  }

  Widget _buildWorksiteCard(Map<String, dynamic> w) {
    final ownerName =
        (w['owner_name'] as String?)?.isNotEmpty == true
            ? w['owner_name'] as String
            : 'Unnamed Worksite';
    final address = w['address'] as String? ?? '';
    final propType = w['property_type'] as String?;

    return Container(
      margin: EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border:
            Border.all(color: Theme.of(context).dividerColor),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1B3A5C)
              .withOpacity(0.1),
          child: const Icon(
              Icons.home_work_rounded,
              color: Color(0xFF1B3A5C),
              size: 20),
        ),
        title: Text(ownerName,
            style: context.textStyles.labelSmall?.bold),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (address.isNotEmpty)
              Text(address,
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            if (propType != null)
              Text(_propertyTypeLabel(propType),
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: Colors.grey[500])),
          ],
        ),
        trailing: Icon(Icons.chevron_right_rounded,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant),
        onTap: () => context.push(
          AppRoutes.worksiteDetail,
          extra: {'worksiteId': w['id'] as String},
        ),
      ),
    );
  }
}
