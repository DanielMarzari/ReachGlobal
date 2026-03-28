import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  static const String _edgeFunctionUrl =
      'https://sqhpxtfnnupcdgjjhsgc.supabase.co/functions/v1/create-staff-user';

  // Form fields
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';
  String _tempPassword = '';
  String _selectedRole = 'coordinator';
  List<String> _selectedDisasters = [];
  String _permissionLevel = 'coordinator';
  bool _canAddStaff = false;
  bool _showPassword = false;

  // Loading state
  bool _isLoading = false;
  List<Map<String, dynamic>> _disasters = [];
  bool _loadingDisasters = true;

  @override
  void initState() {
    super.initState();
    _loadDisasters();
  }

  Future<void> _loadDisasters() async {
    try {
      final auth = context.read<AuthService>();
      List<dynamic> data;

      if (auth.isSuperAdmin) {
        // Super admin sees all active disasters
        data = await SupabaseService.client
            .from('disasters')
            .select('id, name, location_name, status')
            .eq('status', 'active')
            .order('created_at', ascending: false);
      } else {
        // Coordinator sees only assigned disasters
        data = await SupabaseService.client
            .from('disasters')
            .select(
                'id, name, location_name, status, staff_event_permissions!inner(user_id)')
            .eq('status', 'active')
            .eq('staff_event_permissions.user_id',
                SupabaseService.currentUser?.id ?? '')
            .order('created_at', ascending: false);
      }

      if (mounted) {
        setState(() {
          _disasters = List<Map<String, dynamic>>.from(data);
          _loadingDisasters = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingDisasters = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading disasters: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDisasters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one disaster assignment')),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // Call the edge function — service role key stays server-side
      final session = SupabaseService.client.auth.currentSession;
      final authResponse = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Authorization': 'Bearer ${session?.accessToken ?? ''}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _email,
          'password': _tempPassword,
          'full_name': _fullName,
          'role': _selectedRole,
          'disaster_id': _selectedDisasters.isNotEmpty ? _selectedDisasters.first : null,
          'permission_level': _permissionLevel,
          'can_add_staff': _canAddStaff,
        }),
      );

      if (authResponse.statusCode != 200) {
        final err = jsonDecode(authResponse.body);
        throw Exception(err['error'] ?? 'Failed to create staff member');
      }

      final responseData = jsonDecode(authResponse.body) as Map<String, dynamic>;
      final newUserId = responseData['user_id'] as String;

      // If multiple disasters selected, add the remaining permissions via client
      if (_selectedDisasters.length > 1) {
        for (final disasterId in _selectedDisasters.skip(1)) {
          await SupabaseService.client.from('staff_event_permissions').insert({
            'user_id': newUserId,
            'disaster_id': disasterId,
            'level': _permissionLevel,
            'can_add_staff': _canAddStaff,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Staff member "$_fullName" created successfully with temporary password'),
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating staff: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Staff'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loadingDisasters
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Note at top
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'A temporary password will be sent to the staff member. Ask them to change it on first login.',
                                style: context.textStyles.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full Name
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Full name is required';
                                }
                                return null;
                              },
                              onSaved: (value) => _fullName = value ?? '',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Email
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                              onSaved: (value) => _email = value ?? '',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Temporary Password
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Temporary Password',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() =>
                                        _showPassword = !_showPassword);
                                  },
                                ),
                              ),
                              obscureText: !_showPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Temporary password is required';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                              onSaved: (value) => _tempPassword = value ?? '',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Role (disabled - always coordinator)
                            TextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                ),
                              ),
                              initialValue: 'Site Coordinator',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Disaster Assignment
                            Text(
                              'Disaster Assignment',
                              style: context.textStyles.labelLarge?.semiBold,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              child: _disasters.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: AppSpacing.paddingMd,
                                        child: Text(
                                          'No active disasters available',
                                          style: context.textStyles.bodySmall,
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: Column(
                                        children: _disasters.map((disaster) {
                                          final disasterId =
                                              disaster['id'] as String;
                                          final disasterName =
                                              disaster['name'] as String;
                                          final isSelected = _selectedDisasters
                                              .contains(disasterId);

                                          return CheckboxListTile(
                                            title: Text(disasterName),
                                            subtitle: Text(
                                              disaster['location_name'] ?? '',
                                              style:
                                                  context.textStyles.bodySmall,
                                            ),
                                            value: isSelected,
                                            onChanged: (_) {
                                              setState(() {
                                                if (isSelected) {
                                                  _selectedDisasters
                                                      .remove(disasterId);
                                                } else {
                                                  _selectedDisasters
                                                      .add(disasterId);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Permission Level
                            Text(
                              'Permission Level',
                              style: context.textStyles.labelLarge?.semiBold,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SegmentedButton<String>(
                              segments: const <ButtonSegment<String>>[
                                ButtonSegment<String>(
                                  value: 'coordinator',
                                  label: Text('Full Access'),
                                ),
                                ButtonSegment<String>(
                                  value: 'read_only',
                                  label: Text('View Only'),
                                ),
                              ],
                              selected: <String>{_permissionLevel},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _permissionLevel = newSelection.first;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Can Add Staff (only show if super admin or has permission)
                            if (auth.isSuperAdmin ||
                                _selectedDisasters.isNotEmpty)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Allow this person to add their own staff',
                                          style: context.textStyles.labelLarge
                                              ?.semiBold,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'If enabled, this staff member can create additional staff members for their assigned disasters.',
                                          style: context.textStyles.bodySmall
                                              ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _canAddStaff,
                                    onChanged: (value) {
                                      setState(() => _canAddStaff = value);
                                    },
                                  ),
                                ],
                              ),
                            const SizedBox(height: AppSpacing.xl),
                            // Submit button
                            FilledButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                backgroundColor:
                                    const Color(0xFF1B3A5C), // Primary color
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text('Create Staff Member'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
