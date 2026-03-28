import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

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

  String _selectedDisasterType = 'tornado';
  DateTime? _selectedStartDate;
  bool _isPublic = true;
  String _selectedStatus = 'active';

  final List<String> _disasterTypes = [
    'tornado',
    'flood',
    'fire',
    'hurricane',
    'other'
  ];

  final List<String> _statuses = ['active', 'winding_down', 'closed'];

  final List<Map<String, dynamic>> _mockCoordinators = [
    {
      'id': '1',
      'name': 'John Martinez',
      'email': 'john@example.com',
    },
    {
      'id': '2',
      'name': 'Sarah Chen',
      'email': 'sarah@example.com',
    },
  ];

  List<Map<String, dynamic>> _coordinators = [];

  @override
  void initState() {
    super.initState();
    _coordinators = List.from(_mockCoordinators);
    // Initialize form with mock data
    _eventNameController.text = 'Springfield Tornado Relief - March 2025';
    _locationController.text = 'Springfield, IL';
    _baseCampController.text = '2500 Industrial Drive, Springfield, IL';
    _descriptionController.text =
        'Disaster relief operations for the March 15th tornado. Coordinating debris removal, structural repairs, and rebuilding efforts.';
    _selectedStartDate = DateTime(2025, 3, 15);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _baseCampController.dispose();
    _descriptionController.dispose();
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

  void _addCoordinator() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController emailController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Staff Coordinator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  setState(() {
                    _coordinators.add({
                      'id': DateTime.now().toString(),
                      'name': nameController.text,
                      'email': emailController.text,
                    });
                  });
                  context.pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeCoordinator(String id) {
    setState(() {
      _coordinators.removeWhere((c) => c['id'] == id);
    });
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
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
          'Event Details',
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
              SizedBox(height: AppSpacing.xl),
              // Staff Coordinators Section
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface,
                  borderRadius:
                      BorderRadius.circular(AppRadius.lg),
                  border:
                      Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Staff Coordinators',
                          style:
                              context.textStyles.labelSmall?.bold,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: _addCoordinator,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ],
                    ),
                    if (_coordinators.isEmpty)
                      Text(
                        'No coordinators assigned yet',
                        style: context.textStyles.bodySmall,
                      )
                    else
                      Column(
                        children: _coordinators.map((coordinator) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.sm),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        coordinator['name'],
                                        style: context
                                            .textStyles
                                            .labelSmall
                                            ?.bold,
                                      ),
                                      Text(
                                        coordinator['email'],
                                        style: context
                                            .textStyles
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.delete_outline),
                                  onPressed: () =>
                                      _removeCoordinator(
                                          coordinator['id']),
                                  color: const Color(0xFFBA1A1A),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: const Text('Save Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
