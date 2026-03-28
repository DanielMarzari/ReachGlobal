import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

  final _coverPicker = ImagePicker();
  Uint8List? _coverBytes;
  String? _coverPublicUrl;
  bool _coverUploading = false;

  final TextEditingController _eventNameController =
      TextEditingController();
  final TextEditingController _locationController =
      TextEditingController();
  final TextEditingController _baseCampController =
      TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _coverImageController =
      TextEditingController();

  String _selectedDisasterType = 'tornado';
  DateTime? _selectedStartDate;
  bool _isPublic = true;
  String _selectedStatus = 'active';
  bool _isSaving = false;

  final List<String> _disasterTypes = [
    'tornado',
    'flood',
    'fire',
    'hurricane',
    'earthquake',
    'other'
  ];

  final List<String> _statuses = ['active', 'winding_down', 'closed'];

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
    _coverImageController.dispose();
    super.dispose();
  }

  String _getDisasterLabel(String type) {
    switch (type) {
      case 'tornado':
        return 'Tornado';
      case 'flood':
        return 'Flood';
      case 'fire':
        return 'Fire';
      case 'hurricane':
        return 'Hurricane';
      case 'earthquake':
        return 'Earthquake';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'winding_down':
        return 'Winding Down';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF4A90E2);
      case 'winding_down':
        return const Color(0xFFC0582A);
      case 'closed':
        return const Color(0xFF4A6741);
      default:
        return const Color(0xFF999999);
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
      setState(() {
        _selectedStartDate = picked;
      });
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
      final coverUrl = (_coverPublicUrl ?? _coverImageController.text).trim();
      final result = await SupabaseService.client.from('disasters').insert({
        'name': _eventNameController.text.trim(),
        'type': _selectedDisasterType,
        'location_name': _locationController.text.trim(),
        'start_date': _selectedStartDate!.toIso8601String().substring(0, 10),
        'base_camp_addr': _baseCampController.text.trim(),
        'description': _descriptionController.text.trim(),
        'public_visible': _isPublic,
        'status': _selectedStatus,
        'created_by': userId,
        if (coverUrl.isNotEmpty) 'cover_image_url': coverUrl,
      }).select('id, name').single();

      if (mounted) {
        // Navigate into the setup wizard so staff can document the site,
        // select work phases, and measure rooms before coordinating resources.
        context.go(AppRoutes.responseSetup, extra: {
          'disasterId': result['id'] as String,
          'disasterName': result['name'] as String,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _pickCoverImage(ImageSource source) async {
    if (_coverUploading) return;
    try {
      // image_picker is not supported on every Flutter target.
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.windows)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image picking isn\'t supported on this platform.')),
        );
        return;
      }

      final file = await _coverPicker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() {
        _coverUploading = true;
        _coverBytes = null;
        _coverPublicUrl = null;
      });

      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      final uid = context.read<AuthService>().userId;
      final path = 'disasters/drafts/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await SupabaseService.storage.from('project-photos').uploadBinary(path, bytes);
      final url = SupabaseService.storage.from('project-photos').getPublicUrl(path);

      if (!mounted) return;
      setState(() {
        _coverUploading = false;
        _coverBytes = bytes;
        _coverPublicUrl = url;
        _coverImageController.text = url;
      });
    } on MissingPluginException catch (e) {
      debugPrint('Image picker plugin missing: $e');
      if (!mounted) return;
      setState(() => _coverUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image picker is unavailable in this build. Try a full restart, or run on web/mobile.'),
        ),
      );
    } catch (e) {
      debugPrint('Cover upload failed: $e');
      if (!mounted) return;
      setState(() => _coverUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cover upload failed: $e')),
      );
    }
  }

  void _showCoverSourceSheet() {
    if (kIsWeb) {
      _pickCoverImage(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a photo'),
              onTap: () {
                ctx.pop();
                _pickCoverImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () {
                ctx.pop();
                _pickCoverImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeCover() {
    setState(() {
      _coverBytes = null;
      _coverPublicUrl = null;
      _coverImageController.clear();
    });
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
              // Event Name
              Text(
                'Event Name',
                style: context.textStyles.labelSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  hintText: 'Enter event name',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Event name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),
              // Disaster Type
              Text(
                'Disaster Type',
                style: context.textStyles.labelSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _selectedDisasterType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                items: _disasterTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_getDisasterLabel(value)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDisasterType = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: AppSpacing.lg),
              // Location Name
              Text(
                'Location Name',
                style: context.textStyles.labelSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Enter location',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),
              // Start Date
              Text(
                'Start Date',
                style: context.textStyles.labelSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
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
                            ? '${_selectedStartDate!.year}-${_selectedStartDate!.month.toString().padLeft(2, '0')}-${_selectedStartDate!.day.toString().padLeft(2, '0')}'
                            : 'Select date',
                        style: context.textStyles.bodySmall,
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Base Camp Address
              Text(
                'Base Camp Address',
                style: context.textStyles.labelSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _baseCampController,
                decoration: InputDecoration(
                  hintText: 'Enter base camp address',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Base camp address is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),
              // Description
              Text(
                'Description',
                style: context.textStyles.labelSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter event description',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),
              // Public Visibility
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface,
                  borderRadius:
                      BorderRadius.circular(AppRadius.md),
                  border:
                      Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Public Visibility',
                          style:
                              context.textStyles.labelSmall?.bold,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Make this event visible to public',
                          style: context.textStyles.bodySmall,
                        ),
                      ],
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Status
              Text(
                'Status',
                style: context.textStyles.labelSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                items: _statuses.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_getStatusLabel(value)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: AppSpacing.lg),
              Text('Cover Image (optional)', style: context.textStyles.labelSmall?.bold),
              SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _showCoverSourceSheet,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: Theme.of(context).dividerColor),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: (_coverPublicUrl != null && _coverPublicUrl!.isNotEmpty)
                            ? Image.network(_coverPublicUrl!, fit: BoxFit.cover)
                            : (_coverBytes != null)
                                ? Image.memory(_coverBytes!, fit: BoxFit.cover)
                                : Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.06),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cloud_upload_rounded,
                                            size: 36,
                                            color: Theme.of(context).colorScheme.primary),
                                        SizedBox(height: AppSpacing.sm),
                                        Text('Upload cover image',
                                            style: context.textStyles.bodyMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(height: 4),
                                        Text('JPG/PNG • Tap to choose',
                                            style: context.textStyles.bodySmall
                                                ?.copyWith(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                      ),
                      if (_coverUploading)
                        Container(
                          color: Colors.black.withValues(alpha: 0.25),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      if (!_coverUploading && (_coverPublicUrl?.isNotEmpty ?? false))
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.filled(
                                onPressed: _showCoverSourceSheet,
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filled(
                                onPressed: _removeCover,
                                icon: const Icon(Icons.close_rounded, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Tip: You can also add site photos in the next step — the first site photo becomes the cover image.',
                style: context.textStyles.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: AppSpacing.xl),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A5C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
