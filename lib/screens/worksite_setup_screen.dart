import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      Icons.warning_amber_rounded, 'Mold Remediation',
      'Treat and remove mold; dry out structural materials'),
  _Phase('structural_assessment', 'Emergency',
      Icons.search_rounded, 'Structural Assessment',
      'Inspect, document, and photograph all damage'),
  _Phase('demo_gut', 'Emergency',
      Icons.construction_rounded, 'Demo / Gut',
      'Remove wet drywall, flooring, cabinets, insulation'),

  // Foundation & Structural
  _Phase('foundation_repair', 'Structural',
      Icons.vertical_align_bottom_rounded, 'Foundation Repair',
      'Crack repair, leveling, waterproofing'),
  _Phase('framing', 'Structural',
      Icons.grid_view_rounded, 'Framing / Structural Repairs',
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
      Icons.electrical_services_rounded, 'Electrical – Finish',
      'Install outlets, switches, fixtures, panels'),
  _Phase('plumbing_fixtures', 'MEP Finish',
      Icons.plumbing_rounded, 'Plumbing – Fixtures',
      'Set toilets, sinks, tubs, shower valves'),

  // Interior Finish
  _Phase('door_trim', 'Interior Finish',
      Icons.sensor_door_rounded, 'Door Frames & Trim',
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
      Icons.countertops_rounded, 'Countertops',
      'Laminate, butcher block, or stone install'),

  // Flooring
  _Phase('subfloor', 'Flooring',
      Icons.table_rows_rounded, 'Subfloor Repair / Replace',
      'Sistering, OSB replacement, leveling'),
  _Phase('flooring_lvp', 'Flooring',
      Icons.texture_rounded, 'Flooring – LVP / Laminate',
      'Click-lock vinyl plank or laminate'),
  _Phase('flooring_tile', 'Flooring',
      Icons.grid_on_rounded, 'Flooring – Tile',
      'Floor and wall tile (bathroom, kitchen)'),
  _Phase('flooring_carpet', 'Flooring',
      Icons.king_bed_rounded, 'Flooring – Carpet',
      'Stretch and install carpet and pad'),
  _Phase('flooring_hardwood', 'Flooring',
      Icons.nature_rounded, 'Flooring – Hardwood',
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
      Icons.yard_rounded, 'Landscaping & Site Cleanup',
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
  bool uploading;
  _PhotoEntry()
      : urlController = TextEditingController(),
        captionController = TextEditingController(),
        uploading = false;
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

  static const String _kStorageBucket = 'project-photos';
  final ImagePicker _imagePicker = ImagePicker();

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

  String _generateStoragePath(String worksiteId, String originalName) {
    final ext = (originalName.contains('.')
            ? originalName.split('.').last.toLowerCase()
            : 'jpg')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    final safeExt = (ext.isEmpty || ext.length > 6) ? 'jpg' : ext;
    final rand = Random.secure().nextInt(1 << 32);
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'worksites/$worksiteId/$ts-$rand.$safeExt';
  }

  String _guessContentType(String filename) {
    final ext = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _pickAndUploadPhoto(int index) async {
    if (index < 0 || index >= _photos.length) return;

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Image picking is not supported on Windows/Linux here.')));
      return;
    }

    setState(() => _photos[index].uploading = true);
    try {
      final XFile? file = await _imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;

      final Uint8List bytes = await file.readAsBytes();
      final userId = context.read<AuthService>().userId;
      if (userId == null || userId.isEmpty) {
        throw Exception('You must be signed in to upload photos.');
      }
      final path = _generateStoragePath(userId, file.name);
      await SupabaseService.storage.from(_kStorageBucket).uploadBinary(
          path,
          bytes,
          fileOptions:
              FileOptions(contentType: _guessContentType(file.name), upsert: true));

      final url = SupabaseService.storage.from(_kStorageBucket).getPublicUrl(path);
      if (!mounted) return;
      setState(() => _photos[index].urlController.text = url);
    } on MissingPluginException catch (e) {
      debugPrint('Image picker plugin missing: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Image picking is not available on this platform in Dreamflow Preview.')));
    } catch (e) {
      debugPrint('Failed to pick/upload worksite photo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _photos[index].uploading = false);
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
              'Add 1+ photos for assessment and documentation.'),
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
                  _PhotoUploadBox(
                    url: p.urlController.text.trim().isEmpty
                        ? null
                        : p.urlController.text.trim(),
                    isUploading: p.uploading,
                    onPick: () => _pickAndUploadPhoto(i),
                    onRemove: p.urlController.text.trim().isEmpty
                        ? null
                        : () => setState(() => p.urlController.clear()),
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

class _PhotoUploadBox extends StatelessWidget {
  final String? url;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const _PhotoUploadBox({
    required this.url,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = url != null && url!.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md - 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isUploading ? null : onPick,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    Image.network(
                      url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => const _Placeholder(),
                    )
                  else
                    const _Placeholder(),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniPillButton(
                          label: hasImage ? 'Change' : 'Upload',
                          icon: hasImage
                              ? Icons.photo_library_rounded
                              : Icons.upload_rounded,
                          onTap: isUploading ? null : onPick,
                        ),
                        if (onRemove != null) ...[
                          const SizedBox(width: 8),
                          _MiniPillButton(
                            label: 'Remove',
                            icon: Icons.delete_outline_rounded,
                            onTap: isUploading ? null : onRemove,
                            isDestructive: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isUploading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 6),
            Text('Tap to upload',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _MiniPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _MiniPillButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDestructive
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.primaryContainer;
    final fg = isDestructive
        ? Theme.of(context).colorScheme.onErrorContainer
        : Theme.of(context).colorScheme.onPrimaryContainer;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
