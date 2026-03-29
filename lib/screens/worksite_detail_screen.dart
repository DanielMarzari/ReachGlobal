import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/supabase_service.dart';

// ── Phase label lookup (mirrors worksite_setup_screen) ───────────────────────
const Map<String, String> _kPhaseLabels = {
  'emergency_stabilization': 'Emergency Stabilization',
  'debris_removal':          'Debris Removal',
  'mold_remediation':        'Mold Remediation',
  'structural_assessment':   'Structural Assessment',
  'demo_gut':                'Demo / Gut',
  'foundation_repair':       'Foundation Repair',
  'framing':                 'Framing / Structural Repairs',
  'electrical_rough':        'Electrical Rough-In',
  'plumbing_rough':          'Plumbing Rough-In',
  'hvac':                    'HVAC',
  'vapor_barrier':           'Vapor Barrier',
  'insulation_walls':        'Insulation – Walls',
  'insulation_attic':        'Insulation – Attic / Ceiling',
  'drywall_hang':            'Drywall – Hang',
  'drywall_tape_mud':        'Drywall – Tape & Mud',
  'drywall_sand_prime':      'Drywall – Sand & Prime',
  'paint_ceilings':          'Paint – Ceilings',
  'paint_walls':             'Paint – Walls',
  'paint_trim':              'Paint – Trim & Doors',
  'electrical_finish':       'Electrical – Finish',
  'plumbing_fixtures':       'Plumbing – Fixtures',
  'door_trim':               'Door Frames & Trim',
  'window_trim':             'Window Trim & Sills',
  'cabinets_kitchen':        'Cabinetry – Kitchen',
  'cabinets_bath':           'Cabinetry – Bathroom',
  'countertops':             'Countertops',
  'subfloor':                'Subfloor Repair / Replace',
  'flooring_lvp':            'Flooring – LVP / Laminate',
  'flooring_tile':           'Flooring – Tile',
  'flooring_carpet':         'Flooring – Carpet',
  'flooring_hardwood':       'Flooring – Hardwood',
  'roofing':                 'Roofing',
  'siding':                  'Exterior Siding',
  'windows_exterior':        'Windows & Doors (Exterior)',
  'landscaping_cleanup':     'Landscaping & Site Cleanup',
  'deep_clean':              'Final Deep Clean',
};

const Map<String, String> _kPropertyTypeLabels = {
  'single_family': 'Single Family Residence',
  'mobile_home':   'Mobile Home',
  'multi_family':  'Multi-Family',
  'commercial':    'Commercial',
  'church':        'Church / Non-Profit',
  'other':         'Other',
};

// ── Screen ────────────────────────────────────────────────────────────────────
class WorksiteDetailScreen extends StatefulWidget {
  final String worksiteId;

  const WorksiteDetailScreen({Key? key, required this.worksiteId})
      : super(key: key);

  @override
  State<WorksiteDetailScreen> createState() =>
      _WorksiteDetailScreenState();
}

class _WorksiteDetailScreenState extends State<WorksiteDetailScreen> {
  Map<String, dynamic>? _worksite;
  List<Map<String, dynamic>> _photos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final worksite = await SupabaseService.client
          .from('worksites')
          .select(
              'id, owner_name, address, lat, lng, property_type, work_phases, notes, created_at, disaster_id')
          .eq('id', widget.worksiteId)
          .single();

      final photos = await SupabaseService.client
          .from('worksite_photos')
          .select('id, url, caption')
          .eq('worksite_id', widget.worksiteId)
          .order('created_at');

      if (mounted) {
        setState(() {
          _worksite = Map<String, dynamic>.from(worksite);
          _photos = List<Map<String, dynamic>>.from(photos);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = _worksite;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _loading
              ? 'Loading…'
              : (w?['owner_name'] as String? ?? 'Worksite'),
          style: context.textStyles.titleMedium?.bold,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : w == null
              ? const Center(child: Text('Worksite not found.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoSection(w),
                        if (_photos.isNotEmpty)
                          _buildPhotosSection(),
                        _buildPhasesSection(w),
                        if ((w['notes'] as String?)
                                ?.isNotEmpty ==
                            true)
                          _buildNotesSection(w),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Property info ─────────────────────────────────────────────────────────

  Widget _buildInfoSection(Map<String, dynamic> w) {
    final propType = _kPropertyTypeLabels[w['property_type']] ??
        (w['property_type'] as String? ?? '');
    final lat = w['lat'] as double?;
    final lng = w['lng'] as double?;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property type chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1B3A5C).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              propType,
              style: context.textStyles.labelSmall?.copyWith(
                  color: const Color(0xFF1B3A5C),
                  fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Address
          _infoRow(Icons.location_on_rounded,
              w['address'] as String? ?? ''),

          // GPS
          if (lat != null && lng != null) ...[
            SizedBox(height: AppSpacing.sm),
            _infoRow(Icons.my_location_rounded,
                '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                secondary: true),
          ],

          // Created date
          SizedBox(height: AppSpacing.sm),
          _infoRow(
            Icons.calendar_today_rounded,
            _formatDate(w['created_at'] as String?),
            secondary: true,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text,
      {bool secondary = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 16,
            color: secondary
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.primary),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: secondary
                ? context.textStyles.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant)
                : context.textStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.substring(0, 10);
    }
  }

  // ── Photos ────────────────────────────────────────────────────────────────

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: Text('Site Photos',
              style: context.textStyles.titleSmall?.bold),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg),
            itemCount: _photos.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) {
              final p = _photos[i];
              final url = p['url'] as String? ?? '';
              final caption = p['caption'] as String?;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      url,
                      width: 200,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 200,
                        height: 130,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image_rounded,
                            color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  if (caption != null && caption.isNotEmpty)
                    SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          caption,
                          style: context.textStyles.bodySmall
                              ?.copyWith(
                                  color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: AppSpacing.md),
      ],
    );
  }

  // ── Work phases ───────────────────────────────────────────────────────────

  Widget _buildPhasesSection(Map<String, dynamic> w) {
    final raw = w['work_phases'];
    final phases = raw is List
        ? List<String>.from(raw)
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Work Phases',
                  style: context.textStyles.titleSmall?.bold),
              Text(
                '${phases.length} selected',
                style: context.textStyles.bodySmall
                    ?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        if (phases.isEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0,
                AppSpacing.lg, AppSpacing.md),
            child: Text('No phases selected.',
                style: context.textStyles.bodySmall
                    ?.copyWith(color: Colors.grey[500])),
          )
        else
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0,
                AppSpacing.lg, AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                    color: Theme.of(context).dividerColor),
                borderRadius:
                    BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: phases.asMap().entries.map((e) {
                  final label = _kPhaseLabels[e.value] ??
                      e.value.replaceAll('_', ' ');
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Color(0xFF4A6741)),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(label,
                                  style: context
                                      .textStyles.bodySmall),
                            ),
                          ],
                        ),
                      ),
                      if (e.key < phases.length - 1)
                        Divider(
                            height: 1,
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.5)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  // ── Notes ─────────────────────────────────────────────────────────────────

  Widget _buildNotesSection(Map<String, dynamic> w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: Text('Notes',
              style: context.textStyles.titleSmall?.bold),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0,
              AppSpacing.lg, AppSpacing.md),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                  color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              w['notes'] as String,
              style: context.textStyles.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
