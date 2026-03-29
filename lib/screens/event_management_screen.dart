import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'dart:typed_data';
import '../theme.dart';
import '../nav.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({Key? key}) : super(key: key);

  @override
  State<EventManagementScreen> createState() =>
      _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _eventNameController =
      TextEditingController();
  final TextEditingController _locationController =
      TextEditingController();
  final TextEditingController _baseCampController =
      TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _imageUrlController =
      TextEditingController();

  Uint8List? _coverImageBytes;
  String? _coverImageUrl;
  bool _isUploadingCover = false;

  String _selectedDisasterType = 'tornado';
  DateTime? _selectedStartDate;
  bool _isPublic = true;
  bool _isSaving = false;

  final List<String> _disasterTypes = [
    'tornado',
    'flood',
    'fire',
    'hurricane',
    'earthquake',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStartDate = DateTime.now();
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _baseCampController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadCoverImage() async {
    if (_isUploadingCover) return;

    setState(() => _isUploadingCover = true);
    try {
      final userId = context.read<AuthService>().userId;
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to upload images.')),
          );
        }
        return;
      }

      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2400,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final parts = file.name.split('.');
      final ext = (parts.length > 1 ? parts.last : 'jpg').toLowerCase();
      final safeExt = (ext == 'png' || ext == 'webp' || ext == 'jpeg' || ext == 'jpg') ? ext : 'jpg';
      final contentType = switch (safeExt) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'jpeg' => 'image/jpeg',
        'jpg' => 'image/jpeg',
        _ => 'image/jpeg',
      };

      final rand = Random().nextInt(1 << 32);
      final path = 'responses/$userId/${DateTime.now().millisecondsSinceEpoch}-$rand.$safeExt';

      await SupabaseService.storage.from('project-photos').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: contentType),
      );

      final publicUrl = SupabaseService.storage.from('project-photos').getPublicUrl(path);

      if (!mounted) return;
      setState(() {
        _coverImageBytes = bytes;
        _coverImageUrl = publicUrl;
        _imageUrlController.text = publicUrl;
      });
    } on MissingPluginException catch (e) {
      debugPrint('Image picker plugin missing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image picking is not available on this platform.')),
        );
      }
    } catch (e) {
      debugPrint('Failed to pick/upload cover image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  void _removeCoverImage() {
    setState(() {
      _coverImageBytes = null;
      _coverImageUrl = null;
      _imageUrlController.clear();
    });
  }

  String _getDisasterLabel(String type) {
    switch (type) {
      case 'tornado':    return 'Tornado';
      case 'flood':      return 'Flood';
      case 'fire':       return 'Fire';
      case 'hurricane':  return 'Hurricane';
      case 'earthquake': return 'Earthquake';
      case 'other':      return 'Other';
      default:           return type;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() => _selectedStartDate = picked);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = context.read<AuthService>().userId;
      final imageUrl = (_coverImageUrl ?? _imageUrlController.text).trim();
      await SupabaseService.client.from('disasters').insert({
        'name': _eventNameController.text.trim(),
        'type': _selectedDisasterType,
        'location_name': _locationController.text.trim(),
        'start_date':
            _selectedStartDate!.toIso8601String().substring(0, 10),
        'base_camp_addr': _baseCampController.text.trim(),
        'description': _descriptionController.text.trim(),
        'public_visible': _isPublic,
        'status': 'active',
        'created_by': userId,
        if (imageUrl.isNotEmpty) 'image_url': imageUrl,
      });

      if (mounted) context.go(AppRoutes.staffDashboard);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
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
          'Create Response',
          style: context.textStyles.titleMedium?.bold,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Event Name ───────────────────────────────────────────
              Text('Event Name',
                  style: context.textStyles.labelSmall?.bold),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  hintText: 'Enter event name',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md)),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: AppSpacing.lg),

              // ── Disaster Type ────────────────────────────────────────
              Text('Disaster Type',
                  style: context.textStyles.labelSmall?.bold),
              SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _selectedDisasterType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md)),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                ),
                items: _disasterTypes
                    .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(_getDisasterLabel(v))))
                    .toList(),
                onChanged: (v) {
                  if (v != null)
                    setState(() => _selectedDisasterType = v);
                },
              ),
              SizedBox(height: AppSpacing.lg),

              // ── Location ─────────────────────────────────────────────
              Text('Location Name',
                  style: context.textStyles.labelSmall?.bold),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'City, State',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md)),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: AppSpacing.lg),

              // ── Start Date ───────────────────────────────────────────
              Text('Start Date',
                  style: context.textStyles.labelSmall?.bold),
              SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).dividerColor),
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedStartDate != null
                            ? '${_selectedStartDate!.year}-'
                                '${_selectedStartDate!.month.toString().padLeft(2, '0')}-'
                                '${_selectedStartDate!.day.toString().padLeft(2, '0')}'
                            : 'Select date',
                        style: context.textStyles.bodySmall,
                      ),
                      Icon(Icons.calendar_today,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // ── Base Camp ────────────────────────────────────────────
              Text('Base Camp Address',
                  style: context.textStyles.labelSmall?.bold),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _baseCampController,
                decoration: InputDecoration(
                  hintText: 'Enter base camp address',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md)),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: AppSpacing.lg),

              // ── Description ──────────────────────────────────────────
              Text('Description',
                  style: context.textStyles.labelSmall?.bold),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Brief overview of the event',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md)),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: AppSpacing.lg),

              // ── Public Visibility ────────────────────────────────────
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('Public Visibility',
                            style: context
                                .textStyles.labelSmall?.bold),
                        SizedBox(height: AppSpacing.xs),
                        Text('Show on public-facing pages',
                            style:
                                context.textStyles.bodySmall),
                      ],
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: (v) =>
                          setState(() => _isPublic = v),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // ── Cover Image URL (optional) ───────────────────────────
              Text('Cover Image (optional)',
                  style: context.textStyles.labelSmall?.bold),
              SizedBox(height: AppSpacing.sm),
              _CreateResponseCoverUploadBox(
                bytes: _coverImageBytes,
                isUploading: _isUploadingCover,
                onPick: _pickAndUploadCoverImage,
                onRemove: _coverImageUrl == null ? null : _removeCoverImage,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Site photos are added per worksite after the response is created.',
                style: context.textStyles.bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: AppSpacing.xl),

              // ── Save ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A5C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        )
                      : const Text('Create Response'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateResponseCoverUploadBox extends StatefulWidget {
  const _CreateResponseCoverUploadBox({
    required this.bytes,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? bytes;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  State<_CreateResponseCoverUploadBox> createState() =>
      _CreateResponseCoverUploadBoxState();
}

class _CreateResponseCoverUploadBoxState
    extends State<_CreateResponseCoverUploadBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasImage = widget.bytes != null;
    final borderColor = _hovered ? cs.primary : Theme.of(context).dividerColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isUploading ? null : widget.onPick,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 180,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: hasImage
                    ? Image.memory(widget.bytes!, fit: BoxFit.cover)
                    : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded,
                                color: cs.primary, size: 32),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Upload cover image',
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'PNG or JPG recommended',
                              textAlign: TextAlign.center,
                              style: context.textStyles.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: _CoverMiniButton(
                        label: hasImage ? 'Change' : 'Choose photo',
                        icon: Icons.upload_rounded,
                        onPressed: widget.isUploading ? null : widget.onPick,
                      ),
                    ),
                    if (widget.onRemove != null) ...[
                      SizedBox(width: AppSpacing.sm),
                      _CoverMiniButton(
                        label: 'Remove',
                        icon: Icons.delete_outline_rounded,
                        destructive: true,
                        onPressed: widget.isUploading ? null : widget.onRemove,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isUploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverMiniButton extends StatelessWidget {
  const _CoverMiniButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = destructive ? cs.errorContainer : cs.primaryContainer;
    final fg = destructive ? cs.onErrorContainer : cs.onPrimaryContainer;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 140),
        opacity: onPressed == null ? 0.55 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 18),
              SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.labelMedium
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
