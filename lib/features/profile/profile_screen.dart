import 'package:flutter/material.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/user_profile.dart';
import 'package:hote_v2/features/onboarding/onboarding_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _panelColor = Color(0xFFF7F5F4);
  static const Color _dangerColor = Color(0xFFE53935);

  UserProfile _profile = const UserProfile(
    firstName: 'Seong-hyeon',
    lastName: 'Eom',
    dateOfBirth: 'January 13, 2009',
    email: 'eom.seonghyeon4@gmail.com',
    country: 'Cambodia',
    phoneNumber: '081991186',
    gender: 'Male',
    language: 'English',
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final UserProfile profile = await AppServices.profile.fetchProfile();
    if (!mounted) {
      return;
    }

    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _openEditProfile() async {
    final UserProfile? updatedProfile =
        await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute<UserProfile>(
        builder: (_) => _EditProfileScreen(profile: _profile),
      ),
    );

    if (!mounted || updatedProfile == null) {
      return;
    }

    setState(() => _profile = updatedProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label settings are not ready yet')),
    );
  }

  Future<void> _logout() async {
    await AppServices.auth.signOut();
    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SizedBox(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ProfileHeader(
                              profile: _profile,
                              onEditTap: _openEditProfile,
                            ),
                            const SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: _panelColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  _ProfileMenuTile(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Edit Profile',
                                    onTap: _openEditProfile,
                                  ),
                                  const Divider(height: 1),
                                  _ProfileMenuTile(
                                    icon: Icons.language_rounded,
                                    title: 'Language',
                                    trailingText: _profile.language,
                                    onTap: () => _showComingSoon('Language'),
                                  ),
                                  const Divider(height: 1),
                                  _ProfileMenuTile(
                                    icon: Icons.notifications_none_rounded,
                                    title: 'Notifications',
                                    onTap: () =>
                                        _showComingSoon('Notification'),
                                  ),
                                  const Divider(height: 1),
                                  _ProfileMenuTile(
                                    icon: Icons.verified_user_outlined,
                                    title: 'Security',
                                    onTap: () => _showComingSoon('Security'),
                                  ),
                                  const Divider(height: 1),
                                  _ProfileMenuTile(
                                    icon: Icons.help_outline_rounded,
                                    title: 'Help',
                                    onTap: () => _showComingSoon('Help'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              decoration: BoxDecoration(
                                color: _panelColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: _ProfileMenuTile(
                                icon: Icons.logout_rounded,
                                iconColor: _dangerColor,
                                title: 'Logout',
                                titleColor: _dangerColor,
                                onTap: _logout,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.onEditTap,
  });

  final UserProfile profile;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onEditTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFEFE2), Color(0xFFFFD7B5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  profile.initials,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.iconColor = AppTheme.textPrimary,
    this.titleColor = AppTheme.textPrimary,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final Color iconColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Row(
            children: [
              Icon(icon, size: 30, color: iconColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileScreen extends StatefulWidget {
  const _EditProfileScreen({required this.profile});

  final UserProfile profile;

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();

  static const _countries = <String>[
    'Cambodia',
    'Thailand',
    'Vietnam',
    'Singapore',
    'Malaysia',
  ];

  static const _genders = <String>[
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.profile.firstName;
    _lastNameController.text = widget.profile.lastName;
    _dateOfBirthController.text = widget.profile.dateOfBirth;
    _emailController.text = widget.profile.email;
    _countryController.text = widget.profile.country;
    _phoneController.text = widget.profile.phoneNumber;
    _genderController.text = widget.profile.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate =
        _parseDate(_dateOfBirthController.text) ?? DateTime(2009, 1, 13);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    _dateOfBirthController.text = _formatDate(selectedDate);
  }

  Future<void> _pickOption(
    String title,
    List<String> options,
    TextEditingController controller,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                    trailing: option == controller.text
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppTheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      controller.text = selected;
    }
  }

  Future<void> _saveProfile() async {
    final UserProfile updatedProfile = widget.profile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      email: _emailController.text.trim(),
      country: _countryController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gender: _genderController.text.trim(),
    );

    if (updatedProfile.hasEmptyRequiredField) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all profile fields')),
      );
      return;
    }

    try {
      final UserProfile savedProfile =
          await AppServices.profile.updateProfile(updatedProfile);
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(savedProfile);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 460 ? 420.0 : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: maxWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon:
                                  const Icon(Icons.arrow_back_ios_new_rounded),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 24),
                        _EditField(
                          label: 'First name',
                          controller: _firstNameController,
                        ),
                        const SizedBox(height: 16),
                        _EditField(
                          label: 'Last name',
                          controller: _lastNameController,
                        ),
                        const SizedBox(height: 16),
                        _EditField(
                          label: 'Date of birth',
                          controller: _dateOfBirthController,
                          readOnly: true,
                          suffixIcon: Icons.calendar_month_outlined,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 16),
                        _EditField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _EditField(
                          label: 'Country',
                          controller: _countryController,
                          readOnly: true,
                          suffixIcon: Icons.chevron_right_rounded,
                          onTap: () => _pickOption(
                            'Select country',
                            _countries,
                            _countryController,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _EditField(
                          label: 'Phone number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _EditField(
                          label: 'Gender',
                          controller: _genderController,
                          readOnly: true,
                          suffixIcon: Icons.chevron_right_rounded,
                          onTap: () => _pickOption(
                            'Select gender',
                            _genders,
                            _genderController,
                          ),
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          label: 'Update',
                          height: 60,
                          radius: 30,
                          onPressed: _saveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DateTime? _parseDate(String value) {
    final parts = value.split(' ');
    if (parts.length != 3) {
      return null;
    }

    final month = _monthIndex(parts[0]);
    final day = int.tryParse(parts[1].replaceAll(',', ''));
    final year = int.tryParse(parts[2]);

    if (month == null || day == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  int? _monthIndex(String monthName) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final index = months.indexOf(monthName);
    return index == -1 ? null : index + 1;
  }

  String _formatDate(DateTime date) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            fillColor: const Color(0xFFF5F3F2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppTheme.primary,
                width: 1.2,
              ),
            ),
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}
