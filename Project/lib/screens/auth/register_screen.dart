import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/blood_banks_data.dart';
import '../../data/hospitals_data.dart';
import '../../models/blood_availability.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../main/main_shell.dart';

/// Registration screen: name, email, phone, blood group, area, password.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _bloodGroup;
  String? _area;
  UserRole _role = UserRole.donor;
  String? _facilityId;
  bool _loading = false;
  String? _error;

  static const List<String> _groups = FacilityStock.allGroups;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bloodGroup == null || _area == null) {
      setState(() => _error = 'Please select your blood group and area.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700)); // mock IO
    final error = AuthService.instance.register(
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      bloodGroup: _bloodGroup!,
      area: _area!,
      password: _passwordCtrl.text,
      age: int.tryParse(_ageCtrl.text.trim()),
      role: _role,
      managedFacilityId: _role == UserRole.donor ? null : _facilityId,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameCtrl,
                  label: 'Full name',
                  hint: 'e.g. Ananya Sharma',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Enter your full name'
                      : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _phoneCtrl,
                  label: 'Phone number',
                  hint: '10-digit mobile number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone is required';
                    if (v.replaceAll(RegExp(r'\D'), '').length < 10) {
                      return 'Enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _ageCtrl,
                  label: 'Age',
                  hint: 'Donors must be 18–65 years',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final age = int.tryParse(v ?? '');
                    if (age == null) return 'Age is required';
                    if (age < 18 || age > 65) {
                      return 'Donors must be 18–65 years old';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Blood group',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _groups
                      .map(
                        (g) => ChoiceChip(
                          label: Text(g),
                          selected: _bloodGroup == g,
                          selectedColor: AppTheme.red,
                          labelStyle: TextStyle(
                            color: _bloodGroup == g
                                ? Colors.white
                                : AppTheme.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) =>
                              setState(() => _bloodGroup = g),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _area,
                  decoration: const InputDecoration(
                    labelText: 'Your area',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  ),
                  items: kAreas
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => setState(() => _area = v),
                  validator: (v) =>
                      v == null ? 'Please select your area' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  hint: 'Minimum 6 characters',
                  icon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                // ---- Account type (Phase 3) ----
                const Text(
                  'Account type',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.donor,
                      label: Text('Donor'),
                      icon: Icon(Icons.volunteer_activism, size: 18),
                    ),
                    ButtonSegment(
                      value: UserRole.hospitalAdmin,
                      label: Text('Hospital'),
                      icon: Icon(Icons.local_hospital, size: 18),
                    ),
                    ButtonSegment(
                      value: UserRole.bloodBankAdmin,
                      label: Text('Blood bank'),
                      icon: Icon(Icons.water_drop, size: 18),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) =>
                      setState(() => _role = s.first),
                ),
                if (_role != UserRole.donor) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _facilityId,
                    decoration: InputDecoration(
                      labelText: _role == UserRole.hospitalAdmin
                          ? 'Your hospital'
                          : 'Your blood bank',
                      prefixIcon: const Icon(Icons.business_outlined,
                          size: 20),
                    ),
                    items: (_role == UserRole.hospitalAdmin
                            ? kHospitals.map((h) => (
                                h.id,
                                '${h.name} (${h.area})'
                              ))
                            : kBloodBanks.map((b) => (
                                b.id,
                                '${b.name} (${b.area})'
                              )))
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.$1,
                            child: Text(r.$2, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _facilityId = v),
                    validator: (v) => v == null
                        ? 'Please pick the facility you manage'
                        : null,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppTheme.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Register',
                  icon: Icons.person_add_alt,
                  isLoading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
