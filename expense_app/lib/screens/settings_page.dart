import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _profileController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _profileAnimation;

  bool _notificationsEnabled = true;
  final bool _biometricEnabled = true;
  bool _darkModeEnabled = true;
  final String _selectedCurrency = 'USD';

  final List<Map<String, dynamic>> _settingsSections = [
    {
      'title': 'Account',
      'items': [
        {
          'title': 'Profile Settings',
          'subtitle': 'Edit your personal information',
          'icon': Icons.person_rounded,
          'color': Color(0xFF6366F1),
          'action': 'profile',
        },
        {
          'title': 'Security',
          'subtitle': 'Password, biometric, 2FA',
          'icon': Icons.security_rounded,
          'color': Color(0xFF10B981),
          'action': 'security',
        },
        {
          'title': 'Currency',
          'subtitle': 'USD',
          'icon': Icons.monetization_on_rounded,
          'color': Color(0xFFF59E0B),
          'action': 'currency',
        },
      ],
    },
    {
      'title': 'Preferences',
      'items': [
        {
          'title': 'Notifications',
          'subtitle': 'Push notifications and alerts',
          'icon': Icons.notifications_rounded,
          'color': Color(0xFF8B5CF6),
          'action': 'notifications',
          'toggle': true,
        },
        {
          'title': 'Dark Mode',
          'subtitle': 'Toggle dark/light theme',
          'icon': Icons.dark_mode_rounded,
          'color': Color(0xFF3B82F6),
          'action': 'dark_mode',
          'toggle': true,
        },
        {
          'title': 'Language',
          'subtitle': 'English (US)',
          'icon': Icons.language_rounded,
          'color': Color(0xFF06B6D4),
          'action': 'language',
        },
      ],
    },
    {
      'title': 'Data & Privacy',
      'items': [
        {
          'title': 'Export Data',
          'subtitle': 'Download your expense data',
          'icon': Icons.download_rounded,
          'color': Color(0xFF10B981),
          'action': 'export',
        },
        {
          'title': 'Privacy Policy',
          'subtitle': 'Read our privacy policy',
          'icon': Icons.privacy_tip_rounded,
          'color': Color(0xFFEF4444),
          'action': 'privacy',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _profileController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _profileAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _profileController, curve: Curves.easeOutBack),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profileController.forward();
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildProfileCard(),
              const SizedBox(height: 30),
              Expanded(child: _buildSettingsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _fadeAnimation.value)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _buildGlassContainer(
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  width: 50,
                  height: 50,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return AnimatedBuilder(
      animation: _profileAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_profileAnimation.value * 0.2),
          child: Opacity(
            opacity: _profileAnimation.value.clamp(0.0, 1.0),
            child: _buildGlassContainer(
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pratyush Aron',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'PratyushAron@email.com',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Owner',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 16,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsList() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              itemCount: _settingsSections.length,
              itemBuilder: (context, sectionIndex) {
                final section = _settingsSections[sectionIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sectionIndex > 0) const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, bottom: 15),
                      child: Text(
                        section['title'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...section['items'].map<Widget>((item) {
                      final itemIndex = section['items'].indexOf(item);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildSettingsItem(
                          item,
                          delay: (sectionIndex * 0.1) + (itemIndex * 0.05),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem(Map<String, dynamic> item, {double delay = 0}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (600 + (delay * 1000)).round()),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: () => _handleSettingsTap(item['action']),
              child: _buildGlassContainer(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(item['icon'], color: item['color'], size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['subtitle'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item['toggle'] == true)
                      _buildAnimatedToggle(item['action'])
                    else
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: 16,
                      ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedToggle(String action) {
    bool isEnabled = action == 'notifications'
        ? _notificationsEnabled
        : _darkModeEnabled;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (action == 'notifications') {
            _notificationsEnabled = !_notificationsEnabled;
          } else {
            _darkModeEnabled = !_darkModeEnabled;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isEnabled
              ? const Color(0xFF10B981)
              : Colors.white.withOpacity(0.3),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    EdgeInsets? padding,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  void _handleSettingsTap(String action) {
    switch (action) {
      case 'profile':
        _showProfileModal();
        break;
      case 'security':
        _showSecurityModal();
        break;
      case 'currency':
        _showCurrencyModal();
        break;
      case 'language':
        _showLanguageModal();
        break;
      case 'export':
        _exportData();
        break;
      case 'privacy':
        _showPrivacyPolicy();
        break;
    }
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalContent(
        'Profile Settings',
        'Edit your personal information and preferences.',
        Icons.person_rounded,
      ),
    );
  }

  void _showSecurityModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalContent(
        'Security Settings',
        'Manage your password, biometric authentication, and two-factor authentication.',
        Icons.security_rounded,
      ),
    );
  }

  void _showCurrencyModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalContent(
        'Currency Settings',
        'Select your preferred currency for displaying amounts.',
        Icons.monetization_on_rounded,
      ),
    );
  }

  void _showLanguageModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalContent(
        'Language Settings',
        'Choose your preferred language for the application.',
        Icons.language_rounded,
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting data...'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalContent(
        'Privacy Policy',
        'Read our privacy policy to understand how we handle your data.',
        Icons.privacy_tip_rounded,
      ),
    );
  }

  Widget _buildModalContent(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: const Color(0xFF6366F1), size: 30),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
