import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../nav.dart';
import '../theme.dart';

class TeamRosterScreen extends StatefulWidget {
  const TeamRosterScreen({Key? key}) : super(key: key);

  @override
  State<TeamRosterScreen> createState() => _TeamRosterScreenState();
}

class _TeamRosterScreenState extends State<TeamRosterScreen> {
  String _filterStatus = 'All';

  final List<Map<String, dynamic>> _teamMembers = [
    {
      'name': 'Sarah Johnson',
      'email': 'sarah@email.com',
      'onboarding': true,
      'skills': ['General Labor', 'Meals & Support'],
      'checkedIn': true,
    },
    {
      'name': 'Michael Chen',
      'email': 'michael@email.com',
      'onboarding': true,
      'skills': ['Carpentry', 'Roofing'],
      'checkedIn': true,
    },
    {
      'name': 'Emma Rodriguez',
      'email': 'emma@email.com',
      'onboarding': false,
      'skills': ['General Labor', 'Logistics'],
      'checkedIn': false,
    },
    {
      'name': 'David Thompson',
      'email': 'david@email.com',
      'onboarding': true,
      'skills': ['Electrical', 'Plumbing'],
      'checkedIn': true,
    },
    {
      'name': 'Lisa Martinez',
      'email': 'lisa@email.com',
      'onboarding': false,
      'skills': ['Medical', 'Meals & Support'],
      'checkedIn': false,
    },
    {
      'name': 'James Wilson',
      'email': 'james@email.com',
      'onboarding': true,
      'skills': ['Demo/Debris', 'General Labor'],
      'checkedIn': true,
    },
    {
      'name': 'Amanda Lee',
      'email': 'amanda@email.com',
      'onboarding': false,
      'skills': ['Logistics', 'Meals & Support'],
      'checkedIn': false,
    },
    {
      'name': 'Robert Taylor',
      'email': 'robert@email.com',
      'onboarding': true,
      'skills': ['Carpentry', 'General Labor'],
      'checkedIn': true,
    },
    {
      'name': 'Jennifer Brown',
      'email': 'jennifer@email.com',
      'onboarding': true,
      'skills': ['Plumbing', 'Electrical'],
      'checkedIn': true,
    },
    {
      'name': 'Christopher Davis',
      'email': 'chris@email.com',
      'onboarding': false,
      'skills': ['General Labor', 'Roofing'],
      'checkedIn': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredMembers {
    if (_filterStatus == 'All') {
      return _teamMembers;
    } else if (_filterStatus == 'Onboarding Complete') {
      return _teamMembers.where((m) => m['onboarding'] == true).toList();
    } else {
      return _teamMembers.where((m) => m['onboarding'] == false).toList();
    }
  }

  int get _onboardingCompleteCount {
    return _teamMembers.where((m) => m['onboarding'] == true).length;
  }

  void _showMemberDetails(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                member['name'],
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                member['email'],
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Skills',
                style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: (member['skills'] as List<String>)
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill,
                          style: context.textStyles.labelSmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: context.textStyles.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(
                      member['onboarding'] ? 'Complete' : 'Pending',
                      style: context.textStyles.labelSmall?.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: member['onboarding']
                        ? const Color(0xFF4A6741)
                        : Colors.orange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              if (member['checkedIn'])
                Chip(
                  label: const Text('Checked In'),
                  labelStyle: context.textStyles.labelSmall?.copyWith(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                  backgroundColor: const Color(0xFF4A6741),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              SizedBox(height: AppSpacing.md),
              if (!member['onboarding'])
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Onboarding marked complete'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6741),
                    ),
                    child: Text(
                      'Mark Onboarding Complete',
                      style: context.textStyles.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (!member['onboarding']) SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Remove from Team?'),
                          content: Text(
                            'Are you sure you want to remove ${member['name']} from the team?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.pop();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${member['name']} removed from team'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBA1A1A),
                  ),
                  child: Text(
                    'Remove from Team',
                    style: context.textStyles.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMemberDialog() {
    late TextEditingController nameController;
    late TextEditingController emailController;

    nameController = TextEditingController();
    emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add Member',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invite sent!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Team Roster',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'export') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Generating PDF roster...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Roster'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Baptist Church of Dallas',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Dallas Tornado Relief • 3/28 - 4/15',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Total Members: ${_teamMembers.length}',
                    style: context.textStyles.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Onboarding Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Onboarding Progress',
                      style: context.textStyles.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_onboardingCompleteCount of ${_teamMembers.length} complete',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: _onboardingCompleteCount / _teamMembers.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4A6741),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Filter Chips
            Wrap(
              spacing: AppSpacing.sm,
              children: ['All', 'Onboarding Complete', 'Pending'].map((status) {
                return FilterChip(
                  label: Text(status),
                  selected: _filterStatus == status,
                  onSelected: (selected) {
                    setState(() => _filterStatus = selected ? status : 'All');
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.lg),

            // Team Members List
            Column(
              children: _filteredMembers.map((member) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: Theme.of(context).dividerColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _showMemberDetails(member),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        member['name'],
                                        style: context.textStyles.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.xs),
                                      Icon(
                                        member['onboarding']
                                            ? Icons.check_circle
                                            : Icons.pending,
                                        size: 16,
                                        color: member['onboarding']
                                            ? const Color(0xFF4A6741)
                                            : Colors.orange,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    member['email'],
                                    style: context.textStyles.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (member['checkedIn'])
                              Chip(
                                label: const Text('In'),
                                labelStyle: context.textStyles.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                                backgroundColor: const Color(0xFF4A6741),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: (member['skills'] as List<String>)
                              .map(
                                (skill) => Chip(
                                  label: Text(
                                    skill,
                                    style: context.textStyles.labelSmall?.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        backgroundColor: const Color(0xFF1B3A5C),
        child: const Icon(Icons.add),
      ),
    );
  }
}
