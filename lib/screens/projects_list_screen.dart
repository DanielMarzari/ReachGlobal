import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  String _viewMode = 'list'; // 'list' or 'map'
  String _statusFilter = 'all';

  final List<Map<String, dynamic>> _mockProjects = [
    {
      'id': '1',
      'address': '1247 Maple Street, Springfield, IL',
      'type': 'debris_removal',
      'status': 'in_progress',
      'volunteers': 3,
      'priority': 'high',
    },
    {
      'id': '2',
      'address': '523 Oak Avenue, Springfield, IL',
      'type': 'structural_repair',
      'status': 'assessed',
      'volunteers': 1,
      'priority': 'high',
    },
    {
      'id': '3',
      'address': '891 Elm Drive, Springfield, IL',
      'type': 'rebuild',
      'status': 'intake',
      'volunteers': 0,
      'priority': 'medium',
    },
    {
      'id': '4',
      'address': '2156 Pine Road, Springfield, IL',
      'type': 'utilities',
      'status': 'complete',
      'volunteers': 2,
      'priority': 'medium',
    },
  ];

  List<Map<String, dynamic>> get _filteredProjects {
    if (_statusFilter == 'all') {
      return _mockProjects;
    }
    return _mockProjects
        .where((p) => p['status'] == _statusFilter)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'intake':
        return const Color(0xFF4A90E2);
      case 'assessed':
        return const Color(0xFFC0582A);
      case 'scheduled':
        return const Color(0xFFFFA500);
      case 'in_progress':
        return const Color(0xFF2196F3);
      case 'punch_list':
        return const Color(0xFFFF9800);
      case 'complete':
        return const Color(0xFF4A6741);
      default:
        return const Color(0xFF999999);
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'debris_removal':
        return const Color(0xFF795548);
      case 'structural_repair':
        return const Color(0xFFF57C00);
      case 'rebuild':
        return const Color(0xFF1976D2);
      case 'interior':
        return const Color(0xFF7B1FA2);
      case 'utilities':
        return const Color(0xFF00796B);
      default:
        return const Color(0xFF616161);
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'debris_removal':
        return 'Debris Removal';
      case 'structural_repair':
        return 'Structural Repair';
      case 'rebuild':
        return 'Rebuild';
      case 'interior':
        return 'Interior';
      case 'utilities':
        return 'Utilities';
      default:
        return type;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'intake':
        return 'Intake';
      case 'assessed':
        return 'Assessed';
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'punch_list':
        return 'Punch List';
      case 'complete':
        return 'Complete';
      default:
        return status;
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
          'Projects',
          style: context.textStyles.titleMedium?.bold,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // View toggle
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'list',
                        label: Text('List'),
                        icon: Icon(Icons.list),
                      ),
                      ButtonSegment(
                        value: 'map',
                        label: Text('Map'),
                        icon: Icon(Icons.map),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _viewMode = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Status filter chips
          if (_viewMode == 'list')
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _statusFilter == 'all',
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = selected ? 'all' : _statusFilter;
                      });
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),
                  FilterChip(
                    label: const Text('Intake'),
                    selected: _statusFilter == 'intake',
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = selected ? 'intake' : 'all';
                      });
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),
                  FilterChip(
                    label: const Text('In Progress'),
                    selected: _statusFilter == 'in_progress',
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = selected ? 'in_progress' : 'all';
                      });
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),
                  FilterChip(
                    label: const Text('Complete'),
                    selected: _statusFilter == 'complete',
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = selected ? 'complete' : 'all';
                      });
                    },
                  ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: _viewMode == 'list'
                ? ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
                      return GestureDetector(
                        onTap: () =>
                            context.push(AppRoutes.projectDetailStaff),
                        child: Container(
                          margin: EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Address
                                Text(
                                  project['address'],
                                  style: context.textStyles.labelSmall?.bold,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: AppSpacing.sm),
                                // Badges row
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(
                                                project['type'])
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.sm),
                                      ),
                                      child: Text(
                                        _getTypeLabel(project['type']),
                                        style: context.textStyles.labelSmall
                                            ?.copyWith(
                                          color:
                                              _getTypeColor(project['type']),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                                project['status'])
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.sm),
                                      ),
                                      child: Text(
                                        _getStatusLabel(project['status']),
                                        style: context.textStyles.labelSmall
                                            ?.copyWith(
                                          color: _getStatusColor(
                                              project['status']),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.sm),
                                // Bottom row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.group,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        SizedBox(width: AppSpacing.xs),
                                        Text(
                                          '${project['volunteers']} volunteers',
                                          style: context.textStyles.labelSmall,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: project['priority'] == 'high'
                                            ? const Color(0xFFBA1A1A)
                                            : const Color(0xFFFFA500),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                            color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Map View',
                            style: context.textStyles.titleMedium?.bold,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Map functionality coming soon.\nSwitch to List view to see projects.',
                            textAlign: TextAlign.center,
                            style: context.textStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _viewMode == 'list'
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add new project')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
