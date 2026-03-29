import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

// ── Granular work-phase definitions ──────────────────────────────────────────

class _Phase {
  final String id;
  final String category;
  final IconData icon;
  final String label;
  final String description;
  const _Phase(this.id, this.category, this.icon, this.label,
      this.description);
}

const List<_Phase> _kPhases = [
  // Emergency / Demo
  _Phase('emergency_stabilization', 'Emergency',
      Icons.security_rounded, 'Emergency Stabilization',
      'Tarp, board up, make structure safe to enter'),
  _Phase('debris_removal', 'Emergency',
      Icons.delete_sweep_rounded, 'Debris Removal',
      'Clear storm, fire, or flood debris from property'),
  _Phase('mold_remediation', 'Emergency',
      Icons.masks_rounded, 'Mold Remediation',
      'Treat and remove mold; dry out structural materials'),
  _Phase('structural_assessment', 'Emergency',
      Icons.search_rounded, 'Structural Assessment',
      'Inspect, document, and photograph all damage'),
  _Phase('demo_gut', 'Emergency',
      Icons.construction_rounded, 'Demo / Gut',
      'Remove wet drywall, flooring, cabinets, insulation'),

  // Foundation & Structural
  _Phase('foundation_repair', 'Structural',
      Icons.foundation_rounded, 'Foundation Repair',
      'Crack repair, leveling, waterproofing'),
  _Phase('framing', 'Structural',
      Icons.grid_4x4_rounded, 'Framing / Structural Repairs',
      'Sister joists, replace studs, reinforce structure'),

  // MEP Rough-In
  _Phase('electrical_rough', 'Mechanical / Electrical / Plumbing',
      Icons.electrical_services_rounded, 'Electrical Rough-In',
      'Run wire, install boxes, panel work'),
  _Phase('plumbing_rough', 'Mechanical / Electrical / Plumbing',
      Icons.plumbing_rounded, 'Plumbing Rough-In',
      'Repair or replace supply and drain lines'),
  _Phase('hvac', 'Mechanical / Electrical / Plumbing',
      Icons.air_rounded, 'HVAC',
      'Ductwork, furnace, AC unit, ventilation'),

  // Insulation & Envelope
  _Phase('vapor_barrier', 'Insulation & Envelope',
      Icons.water_rounded, 'Vapor Barrier',
      'Crawlspace or slab moisture barrier'),
  _Phase('insulation_walls', 'Insulation & Envelope',
      Icons.layers_rounded, 'Insulation – Walls',
      'Batt or spray-foam in wall cavities'),
  _Phase('insulation_attic', 'Insulation & Envelope',
      Icons.roofing_rounded, 'Insulation – Attic / Ceiling',
      'Blown-in or batt attic insulation'),

  // Drywall
  _Phase('drywall_hang', 'Drywall',
      Icons.grid_on_rounded, 'Drywall – Hang',
      'Screw up drywall sheets on walls and ceilings'),
  _Phase('drywall_tape_mud', 'Drywall',
      Icons.brush_rounded, 'Drywall – Tape & Mud',
      'First and second coats of joint compound'),
  _Phase('drywall_sand_prime', 'Drywall',
      Icons.format_paint_rounded, 'Drywall – Sand & Prime',
      'Sand smooth, apply drywall primer'),

  // Paint & Finish
  _Phase('paint_ceilings', 'Paint & Finish',
      Icons.format_color_fill_rounded, 'Paint – Ceilings',
      'Roll ceiling with two coats'),
  _Phase('paint_walls', 'Paint & Finish',
      Icons.format_color_fill_rounded, 'Paint – Walls',
      'Cut in and roll walls; two coats'),
  _Phase('paint_trim', 'Paint & Finish',
      Icons.border_style_rounded, 'Paint – Trim & Doors',
      'Semi-gloss on all trim, baseboards, and doors'),

  // MEP Finish
  _Phase('electrical_finish', 'MEP Finish',
      Icons.outlet_rounded, 'Electrical – Finish',
      'Install outlets, switches, fixtures, panels'),
  _Phase('plumbing_fixtures', 'MEP Finish',
      Icons.faucet_rounded, 'Plumbing – Fixtures',
      'Set toilets, sinks, tubs, shower valves'),

  // Interior Finish
  _Phase('door_trim', 'Interior Finish',
      Icons.door_back_door_rounded, 'Door Frames & Trim',
      'Hang doors, install casing and baseboards'),
  _Phase('window_trim', 'Interior Finish',
      Icons.window_rounded, 'Window Trim & Sills',
      'Interior casing and sill installation'),
  _Phase('cabinets_kitchen', 'Interior Finish',
      Icons.kitchen_rounded, 'Cabinetry – Kitchen',
      'Install upper and lower kitchen cabinets'),
  _Phase('cabinets_bath', 'Interior Finish',
      Icons.bathroom_rounded, 'Cabinetry – Bathroom',
      'Vanities and medicine cabinets'),
  _Phase('countertops', 'Interior Finish',
      Icons.table_restaurant_rounded, 'Countertops',
      'Laminate, butcher block, or stone install'),

  // Flooring
  _Phase('subfloor', 'Flooring',
      Icons.view_compact_rounded, 'Subfloor Repair / Replace',
      'Sistering, OSB replacement, leveling'),
  _Phase('flooring_lvp', 'Flooring',
      Icons.texture_rounded, 'Flooring – LVP / Laminate',
      'Click-lock vinyl plank or laminate'),
  _Phase('flooring_tile', 'Flooring',
      Icons.grid_3x3_rounded, 'Flooring – Tile',
      'Floor and wall tile (bathroom, kitchen)'),
  _Phase('flooring_carpet', 'Flooring',
      Icons.hotel_rounded, 'Flooring – Carpet',
      'Stretch and install carpet and pad'),
  _Phase('flooring_hardwood', 'Flooring',
      Icons.park_rounded, 'Flooring – Hardwood',
      'Nail-down or floating hardwood floors'),

  // Exterior
  _Phase('roofing', 'Exterior',
      Icons.roofing_rounded, 'Roofing',
      'Shingle, metal, or flat roof repair / replacement'),
  _Phase('siding', 'Exterior',
      Icons.home_rounded, 'Exterior Siding',
      'Vinyl, fiber cement, or wood siding'),
  _Phase('windows_exterior', 'Exterior',
      Icons.window_rounded, 'Windows & Doors (Exterior)',
      'Install or replace windows and exterior doors'),

  // Site / Final
  _Phase('landscaping_cleanup', 'Site / Final',
      Icons.grass_rounded, 'Landscaping & Site Cleanup',
      'Grade, seed, clean driveway and yard'),
  _Phase('deep_clean', 'Site / Final',
      Icons.cleaning_services_rounded, 'Final Deep Clean',
      'Wipe down all surfaces; construction cleaning'),
];

// ── Property types ────────────────────────────────────────────────────────────
const List<Map<String, String>> _kPropertyTypes = [
  {'value': 'single_family', 'label': 'Single Family Residence'},
  {'value': 'mobile_home',   'label': 'Mobile Home'},
  {'value': 'multi_family',  'label': 'Multi-Family'},
  {'value': 'commercial',    'label': 'Commercial'},
  {'value': 'church',        'label': 'Church / Non-Profit'},
  {'value': 'other',         'label': 'Other'},
];

// ── Site photo entry ──────────────────────────────────────────────────────────
class _PhotoEntry {
  TextEditingController urlController;
  TextEditingController captionController;
  _PhotoEntry()
      : urlController = TextEditingController(),
        captionController = TextEditingController();
  void dispose() {
    urlController.dispose();
    captionController.dispose();
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class WorksiteSetupScreen extends StatefulWidget {
  final String disasterId;
  final String disasterName;

  const WorksiteSetupScreen({
    Key? key,
    required this.disasterId,
    required this.disasterName,
  }) : super(key: key);

  @override
  State<WorksiteSetupScreen> createState() =>
      _WorksiteSetupScreenState();
}

class _WorksiteSetupScreenState extends State<WorksiteSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _saving = false;

  // ── Step 1: Property info ─────────────────────────────────────────────────
  final _step1Key = GlobalKey<FormState>();
  final _ownerNameCtrl   = TextEditingController();
  final _addressCtrl     = TextEditingController();
  final _latCtrl         = TextEditingController();
  final _lngCtrl         = TextEditingController();
  final _notesCtrl       = TextEditingController();
  String _propertyType   = 'single_family';

  // ── Step 2: Photos ────────────────────────────────────────────────────────
  final List<_PhotoEntry> _photos = [_PhotoEntry()];

  // ── Step 3: Work phases ───────────────────────────────────────────────────
  final Set<String> _selectedPhases = {};

  @override
  void dispose() {
    _pageController.dispose();
    _ownerNameCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _notesCtrl.dispose();
    for (final p in _photos) p.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final userId = context.read<AuthService>().userId;
      final lat = double.tryParse(_latCtrl.text.trim());
      final lng = double.tryParse(_lngCtrl.text.trim());

      // Insert worksite row
      final result = await SupabaseService.client
          .from('worksites')
          .insert({
            'disaster_id':   widget.disasterId,
            'assessor_id':   userId,
            'owner_name':    _ownerNameCtrl.text.trim(),
            'address':       _addressCtrl.text.trim(),
            if (lat != null) 'lat': lat,
            if (lng != null) 'lng': lng,
            'property_type': _propertyType,
            'notes':         _notesCtrl.text.trim(),
            'work_phases':   _selectedPhases.toList(),
          })
          .select('id')
          .single();

      final worksiteId = result['id'] as String;

      // Insert photos
      final photoRows = _photos
          .where((p) => p.urlController.text.trim().isNotEmpty)
          .map((p) => {
                'worksite_id': worksiteId,
                'url':         p.urlController.text.trim(),
                'caption':     p.captionController.text.trim(),
              })
          .toList();

      if (photoRows.isNotEmpty) {
        await SupabaseService.client
            .from('worksite_photos')
            .insert(photoRows);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Worksite',
          style: context.textStyles.titleMedium?.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor:
                Theme.of(context).dividerColor,
            color: const Color(0xFF1B3A5C),
          ),
        ),
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
        ],
      ),
    );
  }

  // ── Step 1: Property info ─────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepHeader('Step 1 of 3',
                'Property Info',
                'Quick — just the basics. You can add more later.'),
            SizedBox(height: AppSpacing.lg),

            _label('Owner / Org Name'),
            SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _ownerNameCtrl,
              decoration: _inputDeco('Full name or organization'),
              textCapitalization:
                  TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: AppSpacing.lg),

            _label('Property Address'),
            SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _addressCtrl,
              decoration:
                  _inputDeco('123 Main St, City, State, ZIP'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: AppSpacing.lg),

            _label('Property Type'),
            SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _propertyType,
              decoration: _inputDeco(null),
              items: _kPropertyTypes
                  .map((t) => DropdownMenuItem(
                      value: t['value'],
                      child: Text(t['label']!)))
                  .toList(),
              onChanged: (v) {
                if (v != null)
                  setState(() => _propertyType = v);
              },
            ),
            SizedBox(height: AppSpacing.lg),

            _label('GPS Coordinates (optional)'),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latCtrl,
                    decoration: _inputDeco('Latitude'),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _lngCtrl,
                    decoration: _inputDeco('Longitude'),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            _label('Notes (optional)'),
            SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _notesCtrl,
              decoration: _inputDeco(
                  'Access notes, hazards, contact info…'),
              maxLines: 3,
            ),
            SizedBox(height: AppSpacing.xl),

            _nextButton('Next: Site Photos', () {
              if (_step1Key.currentState!.validate()) {
                _goTo(1);
              }
            }),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Photos ────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader('Step 2 of 3',
              'Site Photos',
              'Paste image URLs. Take photos on your phone and upload to your storage, then paste the link.'),
          SizedBox(height: AppSpacing.lg),

          ..._photos.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                    color: Theme.of(context).dividerColor),
                borderRadius:
                    BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Photo ${i + 1}',
                          style: context
                              .textStyles.labelSmall?.bold),
                      if (_photos.length > 1)
                        IconButton(
                          icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20),
                          color: Colors.red[400],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(
                              () => _photos.removeAt(i)),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: p.urlController,
                    keyboardType: TextInputType.url,
                    decoration: _inputDeco('Image URL (https://…)'),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: p.captionController,
                    decoration:
                        _inputDeco('Caption (e.g., "Front of house")'),
                  ),
                ],
              ),
            );
          }),

          TextButton.icon(
            onPressed: () =>
                setState(() => _photos.add(_PhotoEntry())),
            icon: const Icon(Icons.add_photo_alternate_rounded,
                size: 18),
            label: const Text('Add Another Photo'),
          ),
          SizedBox(height: AppSpacing.xl),

          Row(
            children: [
              Expanded(child: _backButton(() => _goTo(0))),
              SizedBox(width: AppSpacing.md),
              Expanded(
                  child: _nextButton(
                      'Next: Work Phases', () => _goTo(2))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 3: Work phases ───────────────────────────────────────────────────

  Widget _buildStep3() {
    // Group phases by category
    final categories = <String, List<_Phase>>{};
    for (final p in _kPhases) {
      categories.putIfAbsent(p.category, () => []).add(p);
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stepHeader('Step 3 of 3',
                    'Work Phases',
                    'Select every phase needed at this site. You can adjust later.'),
                SizedBox(height: AppSpacing.lg),

                ...categories.entries.map((cat) =>
                    _buildCategorySection(cat.key, cat.value)),

                SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                        child: _backButton(() => _goTo(1))),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1B3A5C),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppRadius.md),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                              )
                            : const Text('Save Worksite'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
      String category, List<_Phase> phases) {
    final allSelected =
        phases.every((p) => _selectedPhases.contains(p.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.toUpperCase(),
                style: context.textStyles.labelSmall
                    ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      for (final p in phases) {
                        _selectedPhases.remove(p.id);
                      }
                    } else {
                      for (final p in phases) {
                        _selectedPhases.add(p.id);
                      }
                    }
                  });
                },
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap),
                child: Text(
                  allSelected
                      ? 'Deselect all'
                      : 'Select all',
                  style: context.textStyles.labelSmall
                      ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .primary),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
                color: Theme.of(context).dividerColor),
            borderRadius:
                BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: phases.asMap().entries.map((e) {
              final i = e.key;
              final phase = e.value;
              final selected =
                  _selectedPhases.contains(phase.id);
              return Column(
                children: [
                  InkWell(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedPhases.remove(phase.id);
                      } else {
                        _selectedPhases.add(phase.id);
                      }
                    }),
                    borderRadius: BorderRadius.circular(
                        AppRadius.md),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(phase.icon,
                              size: 20,
                              color: selected
                                  ? const Color(0xFF1B3A5C)
                                  : Colors.grey[400]),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phase.label,
                                  style: context
                                      .textStyles.labelSmall
                                      ?.copyWith(
                                          fontWeight:
                                              FontWeight.w600,
                                          color: selected
                                              ? const Color(
                                                  0xFF1B3A5C)
                                              : null),
                                ),
                                Text(
                                  phase.description,
                                  style: context
                                      .textStyles.bodySmall
                                      ?.copyWith(
                                          color: Colors
                                              .grey[600]),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: selected,
                            onChanged: (_) => setState(() {
                              if (selected) {
                                _selectedPhases.remove(phase.id);
                              } else {
                                _selectedPhases.add(phase.id);
                              }
                            }),
                            activeColor:
                                const Color(0xFF1B3A5C),
                            materialTapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < phases.length - 1)
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
        SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _stepHeader(
      String step, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step,
            style: context.textStyles.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant)),
        SizedBox(height: AppSpacing.xs),
        Text(title, style: context.textStyles.titleLarge?.bold),
        SizedBox(height: AppSpacing.xs),
        Text(subtitle,
            style: context.textStyles.bodySmall
                ?.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  Widget _label(String text) =>
      Text(text, style: context.textStyles.labelSmall?.bold);

  InputDecoration _inputDeco(String? hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      );

  Widget _nextButton(String label, VoidCallback onTap) =>
      ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B3A5C),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        child: Text(label),
      );

  Widget _backButton(VoidCallback onTap) =>
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        child: const Text('Back'),
      );
}
