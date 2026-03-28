import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class VolunteerManagementScreen extends StatefulWidget {
  const VolunteerManagementScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerManagementScreen> createState() =>
      _VolunteerManagementScreenState();
}

class _VolunteerManagementScreenState extends State<VolunteerManagementScreen> {
  String _selectedSkillFilter = 'All';
  TextEditingController _searchController = TextEditingController();

  final List<String> _skillFilters = [
    'All',
    'Carpentry',
    'Electrical',
    'Roofing',
    'Plumbing',
    'General Labor',
    'Meals'
  ];

  final List<Map<String, dynamic>> _mockVolunteers = [
    {
      'id': '1',
      'name': 'John Martinez',
      'skills': ['Carpentry', 'General Labor'],
      'onboarding': true,
      'assignments': 2,
      'affiliation': 'First Baptist Church',
    },
    {
      'id': '2',
      'name': 'Sarah Chen',
      'skills': ['Electrical', 'Roofing'],
      'onboarding': true,
      'assignments': 1,
      'affiliation': 'Springfield Community Group',
    },
    {
      'id': '3',
      'name': 'Michael O\'Brien',
      'skills': ['Plumbing', 'General Labor'],
      'onboarding': false,
      'assignments': 0,
      'affiliation': 'Local Volunteer Corps',
    },
    {
      'id': '4',
      'name': 'Emily Rodriguez',
      'skills': ['Meals', 'General Labor'],
      'onboarding': true,
      'assignments': 3,
      'affiliation': 'St. Mary\'s Catholic Church',
    },
    {
      'id': '5',
      'name': 'David Thompson',
      'skills': ['Carpentry', 'Roofing', 'General Labor'],
      'onboarding': true,
      'assignments': 2,
      'affiliation': 'First Baptist Church',
    },
    {
      'id': '6',
      'name': 'Jessica Lee',
      'skills': ['Electrical', 'General Labor'],
      'onboarding': false,
      'assignments': 1,
      'affiliation': 'Springfield Community Group',
    },
  ];

  List<Map<String, dynamic>> get _filteredVolunteers {
    List<Map<String, dynamic>> filtered = _mockVolunteers;

    // Filter by skill
    if (_selectedSkillFilter != 'All') {
      filtered = filtered
          .where((v) => v['skills'].contains(_selectedSkillFilter))
          .toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((v) => v['name'].toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  void _showVolunteerDetails(Map<String, dynamic> volunteer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    child: Text(
                      volunteer['name']
                          .split(' ')
                          .map((n) => n[0])
                          .join(),
                      style: context.textStyles.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          volunteer['name'],
                          style: context.textStyles.titleMedium?.bold,
                        ),
                        Text(
                          volunteer['affiliation'],
                          style: context.textStyles.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              // Skills
              Text(
                'Skills',
                style: context.textStyles.labelSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: (volunteer['skills'] as List<String>)
                    .map(
                      (skill) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          skill,
                          style: context.textStyles.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: AppSpacing.lg),
              // Onboarding status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Onboarding Status',
                    style: context.textStyles.labelSmall?.bold,
                  ),
                  Row(
                    children: [
                      Icon(
                        volunteer['onboarding']
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: volunteer['onboarding']
                            ? const Color(0xFF4A6741)
                            : Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        volunteer['onboarding'] ? 'Complete' : 'Incomplete',
                        style: context.textStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              // Hours and assignments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hours Logged',
                        style: context.textStyles.labelSmall?.bold,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '${24 + (volunteer['id'].hashCode % 20)} hours',
                        style: context.textStyles.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Assignments',
                        style: context.textStyles.labelSmall?.bold,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '${volunteer['assignments']} project(s)',
                        style: context.textStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              // Emergency contact
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contact',
                      style: context.textStyles.labelSmall?.bold,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Phone: (217) 555-${String.fromCharCode(65 + (volunteer['id'].hashCode % 26))}${String.fromCharCode(65 + ((volunteer['id'].hashCode + 1) % 26))}01',
                      style: context.textStyles.bodySmall,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Email: ${volunteer['name'].toLowerCase().replaceAll(' ', '.')}@email.com',
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Assign ${volunteer['name']} to project'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_assignment),
                  label: const Text('Assign to Project'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Volunteers',
          style: context.textStyles.titleMedium?.bold,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search volunteers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          // Skill filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _skillFilters.length,
              itemBuilder: (context, index) {
                final skill = _skillFilters[index];
                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(skill),
                    selected: _selectedSkillFilter == skill,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSkillFilter =
                            selected ? skill : 'All';
                      });
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Volunteer list
          Expanded(
            child: _filteredVolunteers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'No volunteers found',
                          style: context.textStyles.titleMedium?.bold,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: _filteredVolunteers.length,
                    itemBuilder: (context, index) {
                      final volunteer = _filteredVolunteers[index];
                      return GestureDetector(
                        onTap: () =>
                            _showVolunteerDetails(volunteer),
                        child: Container(
                          margin: EdgeInsets.only(bottom: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color:
                                  Theme.of(context).dividerColor,
                            ),
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      child: Text(
                                        volunteer['name']
                                            .split(' ')
                                            .map((n) => n[0])
                                            .join(),
                                        style: context
                                            .textStyles.labelSmall
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            volunteer['name'],
                                            style: context
                                                .textStyles
                                                .labelSmall
                                                ?.bold,
                                          ),
                                          Text(
                                            volunteer['affiliation'],
                                            style: context
                                                .textStyles
                                                .bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow
                                                .ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      volunteer['onboarding']
                                          ? Icons.check_circle
                                          : Icons
                                              .radio_button_unchecked,
                                      color: volunteer['onboarding']
                                          ? const Color(0xFF4A6741)
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.sm),
                                // Skills chips
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: (volunteer['skills']
                                          as List<String>)
                                      .map(
                                        (skill) => Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                AppSpacing.sm,
                                            vertical:
                                                AppSpacing.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              AppRadius.sm,
                                            ),
                                          ),
                                          child: Text(
                                            skill,
                                            style: context
                                                .textStyles
                                                .labelSmall
                                                ?.copyWith(
                                              fontSize: 11,
                                              color: Theme.of(
                                                      context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                // Assignment count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${volunteer['assignments']} assignment(s)',
                                      style: context.textStyles
                                          .labelSmall,
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
