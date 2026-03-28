import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../nav.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

// ── Work phase definitions ────────────────────────────────────────────────────

class _Stage {
  final String id;
  final IconData icon;
  final String label;
  final String description;
  const _Stage(this.id, this.icon, this.label, this.description);
}

const List<_Stage> _kStages = [
  _Stage('emergency_stabilization', Icons.security_rounded,
      'Emergency Stabilization', 'Tarping, boarding, securing the structure'),
  _Stage('debris_removal', Icons.delete_sweep_rounded,
      'Debris Removal', 'Clear storm or fire debris from the property'),
  _Stage('structural_assessment', Icons.search_rounded,
      'Structural Assessment', 'Inspect and document all structural damage'),
  _Stage('demolition', Icons.construction_rounded,
      'Demo / Gut', 'Remove damaged materials (wet drywall, flooring, cabinets)'),
  _Stage('electrical', Icons.electrical_services_rounded,
      'Electrical', 'Repair or replace wiring, panels, and outlets'),
  _Stage('plumbing', Icons.plumbing_rounded,
      'Plumbing', 'Repair pipes, fixtures, and water damage'),
  _Stage('hvac', Icons.air_rounded,
      'HVAC', 'Heating, cooling, and ventilation systems'),
  _Stage('insulation', Icons.layers_rounded,
      'Insulation', 'Replace damaged insulation in walls and ceilings'),
  _Stage('drywall', Icons.grid_on_rounded,
      'Drywall', 'Hang, tape, mud, and finish drywall'),
  _Stage('flooring', Icons.texture_rounded,
      'Flooring', 'Replace damaged flooring (LVP, carpet, tile, subfloor)'),
  _Stage('interior_finish', Icons.format_paint_rounded,
      'Interior Finish', 'Paint, trim, doors, cabinets, and fixtures'),
  _Stage('exterior_roofing', Icons.roofing_rounded,
      'Exterior / Roofing', 'Siding, windows, and roof repair or replacement'),
];

// ── Area model ────────────────────────────────────────────────────────────────

class _Area {
  String? id;
  String name;
  String areaType;
  double lengthFt;
  double widthFt;
  double heightFt;
  String damageLevel;
  Set<String> damageTypes;
  String notes;

  _Area({
    this.id,
    this.name = '',
    this.areaType = 'room',
    this.lengthFt = 12,
    this.widthFt = 12,
    this.heightFt = 8,
    this.damageLevel = 'moderate',
    Set<String>? damageTypes,
    this.notes = '',
  }) : damageTypes = damageTypes ?? {};

  double get floorArea   => lengthFt * widthFt;
  double get ceilingArea => lengthFt * widthFt;
  double get wallArea    => 2 * (lengthFt + widthFt) * heightFt;

  // Only count damaged fraction of surfaces based on severity
  double get damageMultiplier {
    switch (damageLevel) {
      case 'light':    return 0.25;
      case 'moderate': return 0.65;
      case 'severe':   return 1.0;
      default:         return 0.65;
    }
  }

  // Rough volunteer-hour estimate per area based on damage level
  int get estimatedVolunteerHours {
    switch (damageLevel) {
      case 'light':    return 6;
      case 'moderate': return 18;
      case 'severe':   return 40;
      default:         return 18;
    }
  }

  Color get damageColor {
    switch (damageLevel) {
      case 'light':    return const Color(0xFF4A6741);
      case 'moderate': return const Color(0xFFC0582A);
      case 'severe':   return const Color(0xFFBA1A1A);
      default:         return Colors.grey;
    }
  }
}

// ── Photo model ───────────────────────────────────────────────────────────────

class _Photo {
  final Uint8List? bytes; // local bytes not yet uploaded
  final String? url;      // already-uploaded URL
  String photoType;
  String caption;
  _Photo({this.bytes, this.url, this.photoType = 'damage', this.caption = ''});
}

// ── Main screen ───────────────────────────────────────────────────────────────

class ResponseSetupScreen extends StatefulWidget {
  final String disasterId;
  final String disasterName;

  const ResponseSetupScreen({
    super.key,
    required this.disasterId,
    required this.disasterName,
  });

  @override
  State<ResponseSetupScreen> createState() => _ResponseSetupScreenState();
}

class _ResponseSetupScreenState extends State<ResponseSetupScreen> {
  int _step = 0;
  bool _loading = true;
  bool _saving = false;
  String? _assessmentId;

  // Step 1 – Photos
  final List<_Photo> _photos = [];
  final _picker = ImagePicker();

  // Step 2 – Work phases
  final Set<String> _selectedStages = {};

  // Step 3 – Affected areas
  final List<_Area> _areas = [];

  static const List<String> _stepTitles = [
    'Document the Site',
    'Select Work Phases',
    'Measure Affected Areas',
    'Resource Estimates',
  ];

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  Future<void> _loadAssessment() async {
    try {
      final row = await SupabaseService.client
          .from('site_assessments')
          .select('id, selected_stages')
          .eq('disaster_id', widget.disasterId)
          .maybeSingle();

      if (row != null) {
        _assessmentId = row['id'] as String;
        final stages = (row['selected_stages'] as List<dynamic>?) ?? [];
        _selectedStages.addAll(stages.cast<String>());

        final areas = await SupabaseService.client
            .from('assessment_areas')
            .select()
            .eq('assessment_id', _assessmentId!)
            .order('created_at');
        for (final a in areas as List<dynamic>) {
          _areas.add(_Area(
            id: a['id'] as String,
            name: a['area_name'] as String,
            areaType: a['area_type'] as String,
            lengthFt: (a['length_ft'] as num).toDouble(),
            widthFt: (a['width_ft'] as num).toDouble(),
            heightFt: (a['height_ft'] as num).toDouble(),
            damageLevel: a['damage_level'] as String,
            damageTypes: Set<String>.from((a['damage_types'] as List<dynamic>?) ?? []),
            notes: a['notes'] as String? ?? '',
          ));
        }

        final photos = await SupabaseService.client
            .from('site_photos')
            .select('public_url, caption, photo_type')
            .eq('disaster_id', widget.disasterId)
            .order('taken_at');
        for (final p in photos as List<dynamic>) {
          _photos.add(_Photo(
            url: p['public_url'] as String?,
            photoType: p['photo_type'] as String? ?? 'damage',
            caption: p['caption'] as String? ?? '',
          ));
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // ── Photo upload ─────────────────────────────────────────────────────────────

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final ext  = file.name.split('.').last.toLowerCase();
      final path = 'disasters/${widget.disasterId}/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await SupabaseService.client.storage
          .from('project-photos')
          .uploadBinary(path, bytes);

      final url = SupabaseService.client.storage
          .from('project-photos')
          .getPublicUrl(path);

      await SupabaseService.client.from('site_photos').insert({
        'disaster_id':  widget.disasterId,
        'storage_path': path,
        'public_url':   url,
        'photo_type':   'damage',
        'uploaded_by':  context.read<AuthService>().userId,
      });

      // First photo becomes the disaster cover image
      if (_photos.isEmpty) {
        await SupabaseService.client
            .from('disasters')
            .update({'cover_image_url': url})
            .eq('id', widget.disasterId);
      }

      setState(() => _photos.add(_Photo(url: url, bytes: bytes, photoType: 'damage')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _showPhotoSourceSheet() {
    if (kIsWeb) {
      _pickPhoto(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a photo'),
              onTap: () { Navigator.pop(context); _pickPhoto(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () { Navigator.pop(context); _pickPhoto(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  // ── Assessment helpers ───────────────────────────────────────────────────────

  Future<String> _ensureAssessment() async {
    if (_assessmentId != null) return _assessmentId!;
    final existing = await SupabaseService.client
        .from('site_assessments')
        .select('id')
        .eq('disaster_id', widget.disasterId)
        .maybeSingle();
    if (existing != null) {
      _assessmentId = existing['id'] as String;
      return _assessmentId!;
    }
    final row = await SupabaseService.client
        .from('site_assessments')
        .insert({'disaster_id': widget.disasterId, 'selected_stages': []})
        .select('id')
        .single();
    _assessmentId = row['id'] as String;
    return _assessmentId!;
  }

  Future<void> _saveStages() async {
    setState(() => _saving = true);
    try {
      await _ensureAssessment();
      await SupabaseService.client
          .from('site_assessments')
          .update({'selected_stages': _selectedStages.toList()})
          .eq('id', _assessmentId!);
    } catch (_) {}
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _saveArea(_Area area) async {
    final aid = await _ensureAssessment();
    final data = {
      'area_name':    area.name,
      'area_type':    area.areaType,
      'length_ft':    area.lengthFt,
      'width_ft':     area.widthFt,
      'height_ft':    area.heightFt,
      'damage_level': area.damageLevel,
      'damage_types': area.damageTypes.toList(),
      'notes':        area.notes,
    };
    if (area.id == null) {
      final row = await SupabaseService.client
          .from('assessment_areas')
          .insert({'assessment_id': aid, ...data})
          .select('id')
          .single();
      area.id = row['id'] as String;
    } else {
      await SupabaseService.client
          .from('assessment_areas')
          .update(data)
          .eq('id', area.id!);
    }
  }

  Future<void> _deleteArea(_Area area) async {
    if (area.id != null) {
      await SupabaseService.client
          .from('assessment_areas')
          .delete()
          .eq('id', area.id!);
    }
    setState(() => _areas.remove(area));
  }

  // ── Resource estimation ──────────────────────────────────────────────────────

  Map<String, dynamic> _buildEstimates() {
    double totalFloor = 0, totalWall = 0, totalCeiling = 0;
    int totalHours = 0;

    for (final a in _areas) {
      final m = a.damageMultiplier;
      totalFloor   += a.floorArea;
      totalWall    += a.wallArea * m;
      totalCeiling += a.ceilingArea * m;
      totalHours   += a.estimatedVolunteerHours;
    }

    final drywallArea = totalWall + totalCeiling;
    return {
      'totalFloor':     totalFloor,
      'totalWall':      totalWall,
      'totalHours':     totalHours,
      'drywallSheets':  (drywallArea  * 1.10 / 32).ceil(),   // 4×8 sheet = 32 sq ft, +10% waste
      'insulationSqFt': (totalWall    * 1.10).ceil(),         // walls only
      'paintGallons':   (drywallArea  * 1.10 / 350).ceil(),   // ~350 sq ft/gallon
      'flooringSqFt':   (totalFloor   * 1.10).ceil(),         // +10% waste
    };
  }

  // ── Finalize setup ───────────────────────────────────────────────────────────

  Future<void> _finalizeSetup() async {
    setState(() => _saving = true);
    try {
      await _ensureAssessment();
      final est = _buildEstimates();

      final items = [
        {'name': 'Drywall Sheets (4×8)', 'qty': est['drywallSheets'],  'unit': 'sheets'},
        {'name': 'Insulation',           'qty': est['insulationSqFt'], 'unit': 'sq ft'},
        {'name': 'Paint',                'qty': est['paintGallons'],   'unit': 'gallons'},
        {'name': 'Flooring',             'qty': est['flooringSqFt'],   'unit': 'sq ft'},
      ];

      for (final item in items) {
        final qty = (item['qty'] as int).toDouble();
        if (qty > 0) {
          await SupabaseService.client.from('inventory').insert({
            'disaster_id':    widget.disasterId,
            'item_name':      item['name'],
            'quantity':       qty,
            'unit':           item['unit'],
            'location_notes': 'Auto-estimated from site assessment',
          });
        }
      }

      await SupabaseService.client
          .from('site_assessments')
          .update({'setup_complete': true})
          .eq('id', _assessmentId!);
      await SupabaseService.client
          .from('disasters')
          .update({'setup_complete': true})
          .eq('id', widget.disasterId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setup complete! Inventory baseline created.')),
        );
        context.go(AppRoutes.staffDashboard);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.go(AppRoutes.staffDashboard);
    }
  }

  void _goNext() async {
    if (_step == 1) await _saveStages();
    if (_step < 3) setState(() => _step++);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Response Setup  ${_step + 1}/4',
                style: context.textStyles.titleSmall?.bold),
            Text(widget.disasterName,
                style: context.textStyles.labelSmall
                    ?.copyWith(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 4,
            backgroundColor: Colors.grey[200],
          ),
        ),
      ),
      body: IndexedStack(
        index: _step,
        children: [
          _buildPhotosStep(),
          _buildStagesStep(),
          _buildAreasStep(),
          _buildSummaryStep(),
        ],
      ),
    );
  }

  // ── Step 1: Site Photos ──────────────────────────────────────────────────────

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepHeader(Icons.camera_alt_rounded,
                    'Document the Site',
                    'Photos create the project timeline and help estimate damage. '
                    'The first photo becomes the response cover image.'),
                const SizedBox(height: AppSpacing.lg),
                if (_photos.isEmpty)
                  GestureDetector(
                    onTap: _showPhotoSourceSheet,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            style: BorderStyle.solid,
                            width: 2),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Tap to add site photos',
                              style: context.textStyles.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _photos.length + 1, // +1 for add button
                    itemBuilder: (ctx, i) {
                      if (i == _photos.length) {
                        return GestureDetector(
                          onTap: _showPhotoSourceSheet,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.05),
                            ),
                            child: Icon(Icons.add_rounded,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        );
                      }
                      final photo = _photos[i];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: photo.url != null
                                ? Image.network(photo.url!, fit: BoxFit.cover)
                                : photo.bytes != null
                                    ? Image.memory(photo.bytes!, fit: BoxFit.cover)
                                    : Container(color: Colors.grey[300]),
                          ),
                          if (i == 0)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Cover',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10)),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Tip: Add photos showing exterior damage, each affected room, '
                  'roof condition, and any structural concerns. More photos = '
                  'better documentation for insurance and project planning.',
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        _bottomNav(
          onNext: _goNext,
          nextLabel: 'Next: Work Phases',
          skipLabel: 'Skip Photos',
        ),
      ],
    );
  }

  // ── Step 2: Work Phases ──────────────────────────────────────────────────────

  Widget _buildStagesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepHeader(Icons.checklist_rounded,
                    'Select Work Phases',
                    'Check every stage this response will require. This drives '
                    'project creation, volunteer needs, and scheduling.'),
                const SizedBox(height: AppSpacing.lg),
                ..._kStages.map((stage) {
                  final selected = _selectedStages.contains(stage.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedStages.remove(stage.id);
                        } else {
                          _selectedStages.add(stage.id);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.08)
                              : Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Icon(stage.icon,
                                size: 22,
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[600]),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stage.label,
                                      style: context.textStyles.labelMedium
                                          ?.copyWith(
                                              fontWeight: selected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)),
                                  Text(stage.description,
                                      style: context.textStyles.bodySmall
                                          ?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: selected,
                              onChanged: (_) => setState(() {
                                if (selected) {
                                  _selectedStages.remove(stage.id);
                                } else {
                                  _selectedStages.add(stage.id);
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        _bottomNav(
          onNext: _goNext,
          nextLabel: _saving ? null : 'Next: Measure Areas',
          loading: _saving,
        ),
      ],
    );
  }

  // ── Step 3: Affected Areas ───────────────────────────────────────────────────

  Widget _buildAreasStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepHeader(Icons.straighten_rounded,
                    'Measure Affected Areas',
                    'Add each room or area needing work. Dimensions let us '
                    'auto-calculate drywall, insulation, paint, and flooring needs.'),
                const SizedBox(height: AppSpacing.lg),
                if (_areas.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.add_home_work_rounded,
                            size: 40, color: Colors.grey[400]),
                        const SizedBox(height: AppSpacing.sm),
                        Text('No areas added yet',
                            style: context.textStyles.bodyMedium
                                ?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  )
                else
                  ..._areas.map((area) => _areaCard(area)),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => _showAddAreaDialog(null),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Area / Room'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Common areas: Living Room, Kitchen, Bedroom, Bathroom, '
                  'Hallway, Basement, Attic, Garage, Exterior.',
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        _bottomNav(
          onNext: _goNext,
          nextLabel: 'Next: Review Estimates',
          skipLabel: 'Skip Measurements',
        ),
      ],
    );
  }

  Widget _areaCard(_Area area) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.name,
                    style: context.textStyles.labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  '${area.lengthFt.toStringAsFixed(0)}′ × '
                  '${area.widthFt.toStringAsFixed(0)}′ × '
                  '${area.heightFt.toStringAsFixed(0)}′  •  '
                  '${area.floorArea.toStringAsFixed(0)} sq ft floor',
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: area.damageColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: area.damageColor.withOpacity(0.4)),
            ),
            child: Text(
              area.damageLevel.toUpperCase(),
              style: TextStyle(
                  color: area.damageColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => _showAddAreaDialog(area),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18,
                color: Color(0xFFBA1A1A)),
            onPressed: () => _deleteArea(area),
          ),
        ],
      ),
    );
  }

  // ── Add / Edit Area Dialog ───────────────────────────────────────────────────

  void _showAddAreaDialog(_Area? existing) {
    final isEdit = existing != null;
    final area = existing ?? _Area();

    final nameCtrl = TextEditingController(text: area.name);
    String areaType    = area.areaType;
    String damageLevel = area.damageLevel;
    final Set<String> damageTypes = Set.from(area.damageTypes);

    // Use string controllers so users can type decimal values
    final lenCtrl = TextEditingController(text: area.lengthFt.toStringAsFixed(0));
    final widCtrl = TextEditingController(text: area.widthFt.toStringAsFixed(0));
    final htCtrl  = TextEditingController(text: area.heightFt.toStringAsFixed(0));
    final notesCtrl = TextEditingController(text: area.notes);

    const quickNames = [
      'Living Room', 'Kitchen', 'Bedroom', 'Master Bedroom',
      'Bathroom', 'Hallway', 'Basement', 'Attic', 'Garage', 'Exterior',
    ];
    const damageTypeOptions = [
      'walls', 'ceiling', 'floor', 'roof', 'windows', 'doors',
      'electrical', 'plumbing',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isEdit ? 'Edit Area' : 'Add Area',
                    style: context.textStyles.titleMedium?.bold),
                const SizedBox(height: AppSpacing.lg),

                // Quick-select chips
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: quickNames.map((n) => ActionChip(
                    label: Text(n, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      nameCtrl.text = n;
                      setModal(() {});
                    },
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),

                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Area Name *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Dimensions
                Row(children: [
                  Expanded(child: TextField(
                    controller: lenCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Length (ft)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  )),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: TextField(
                    controller: widCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Width (ft)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  )),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: TextField(
                    controller: htCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Height (ft)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  )),
                ]),
                const SizedBox(height: AppSpacing.md),

                // Damage level
                Text('Damage Level',
                    style: context.textStyles.labelSmall?.bold),
                const SizedBox(height: AppSpacing.xs),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'light',    label: Text('Light')),
                    ButtonSegment(value: 'moderate', label: Text('Moderate')),
                    ButtonSegment(value: 'severe',   label: Text('Severe')),
                  ],
                  selected: {damageLevel},
                  onSelectionChanged: (v) => setModal(() => damageLevel = v.first),
                ),
                const SizedBox(height: AppSpacing.md),

                // Damage types
                Text('What\'s Damaged',
                    style: context.textStyles.labelSmall?.bold),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: damageTypeOptions.map((t) {
                    final sel = damageTypes.contains(t);
                    return FilterChip(
                      label: Text(t.replaceAll('_', ' '),
                          style: const TextStyle(fontSize: 12)),
                      selected: sel,
                      onSelected: (v) => setModal(() {
                        if (v) damageTypes.add(t); else damageTypes.remove(t);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),

                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A5C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    area.name        = nameCtrl.text.trim();
                    area.areaType    = areaType;
                    area.lengthFt    = double.tryParse(lenCtrl.text) ?? area.lengthFt;
                    area.widthFt     = double.tryParse(widCtrl.text) ?? area.widthFt;
                    area.heightFt    = double.tryParse(htCtrl.text)  ?? area.heightFt;
                    area.damageLevel = damageLevel;
                    area.damageTypes = damageTypes;
                    area.notes       = notesCtrl.text.trim();
                    Navigator.pop(ctx);
                    await _saveArea(area);
                    setState(() {
                      if (!isEdit) _areas.add(area);
                    });
                  },
                  child: Text(isEdit ? 'Save Changes' : 'Add Area'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 4: Resource Summary ─────────────────────────────────────────────────

  Widget _buildSummaryStep() {
    final est = _buildEstimates();
    final hasAreas = _areas.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepHeader(Icons.bar_chart_rounded,
                    'Resource Estimates',
                    hasAreas
                        ? 'Based on your measurements (+10% waste factor). '
                          'These will be added to inventory as baseline needs.'
                        : 'No areas measured — add rooms in step 3 to get '
                          'material estimates.'),
                const SizedBox(height: AppSpacing.lg),

                if (hasAreas) ...[
                  // Area summary
                  _summaryCard(
                    'Site Scope',
                    [
                      _summaryRow('Affected areas', '${_areas.length} rooms/areas'),
                      _summaryRow('Total floor area',
                          '${(est['totalFloor'] as double).toStringAsFixed(0)} sq ft'),
                      _summaryRow('Damaged wall/ceiling area',
                          '${((est['totalWall'] as double) + (est['totalCeiling'] as double)).toStringAsFixed(0)} sq ft'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Materials
                  _summaryCard(
                    'Estimated Materials',
                    [
                      _summaryRow('Drywall sheets (4×8)',
                          '${est['drywallSheets']} sheets'),
                      _summaryRow('Insulation',
                          '${est['insulationSqFt']} sq ft'),
                      _summaryRow('Paint',
                          '${est['paintGallons']} gallons'),
                      _summaryRow('Flooring',
                          '${est['flooringSqFt']} sq ft'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Volunteers
                  _summaryCard(
                    'Estimated Volunteer Needs',
                    [
                      _summaryRow('Volunteer-hours',
                          '~${est['totalHours']} hrs total'),
                      _summaryRow('Approximate teams (4-person)',
                          '~${((est['totalHours'] as int) / 32).ceil()} teams × 8-hr days'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: Color(0xFFF57F17)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'These are rough baselines. Adjust quantities in the '
                            'Materials tab after inspecting each property. Actual '
                            'needs vary by brand, local code, and site conditions.',
                            style: context.textStyles.bodySmall
                                ?.copyWith(color: const Color(0xFFF57F17)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_selectedStages.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Selected Work Phases (${_selectedStages.length})',
                      style: context.textStyles.labelSmall?.bold),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: _selectedStages.map((id) {
                      final stage = _kStages.firstWhere(
                          (s) => s.id == id,
                          orElse: () => _Stage(id, Icons.check, id, ''));
                      return Chip(
                        avatar: Icon(stage.icon, size: 14),
                        label: Text(stage.label,
                            style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _finalizeSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A5C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Complete Setup & Create Inventory',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _saving ? null : () => context.go(AppRoutes.staffDashboard),
                child: Text('Skip for now',
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Shared UI helpers ────────────────────────────────────────────────────────

  Widget _stepHeader(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon,
              color: Theme.of(context).colorScheme.primary, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: context.textStyles.titleMedium?.bold),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle,
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomNav({
    required VoidCallback? onNext,
    String? nextLabel,
    String? skipLabel,
    bool loading = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          if (skipLabel != null)
            TextButton(
              onPressed: loading ? null : _goNext,
              child: Text(skipLabel,
                  style: TextStyle(color: Colors.grey[600])),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: loading ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3A5C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: loading
                ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(nextLabel ?? 'Next'),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ]),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: context.textStyles.labelMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          ...rows,
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.bodySmall),
          Text(value,
              style: context.textStyles.labelSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
