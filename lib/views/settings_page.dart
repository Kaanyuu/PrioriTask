// lib/views/settings_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Toggle states
  bool _darkMode = false;
  bool _notifications = true;
  bool _sounds = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: Color(0xFFE8E9EC)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ── Banner ───────────────────────────────────────────
          _bannerCard(),

          // ── Preferences ──────────────────────────────────────
          _sectionLabel('PREFERENCES'),
          _settingsCard(
            children: [
              _toggleRow(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF5B5FEE),
                iconBg: const Color(0xFFEEF0FF),
                label: 'Dark Mode',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _divider(),
              _toggleRow(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFFFF8C00),
                iconBg: const Color(0xFFFFF3E0),
                label: 'Notifications',
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              _divider(),
              _toggleRow(
                icon: Icons.volume_up_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
                label: 'Sounds & Haptics',
                value: _sounds,
                onChanged: (v) => setState(() => _sounds = v),
              ),
            ],
          ),

          // ── App ───────────────────────────────────────────────
          _sectionLabel('APP'),
          _settingsCard(
            children: [
              _chevronRow(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF1565C0),
                iconBg: const Color(0xFFE3F2FD),
                label: 'Language',
                value: 'English',
                onTap: () => _showSnack('Language picker coming soon'),
              ),
              _divider(),
              _chevronRow(
                icon: Icons.palette_rounded,
                iconColor: const Color(0xFF7B1FA2),
                iconBg: const Color(0xFFF3E5F5),
                label: 'App Theme',
                value: 'System',
                onTap: () => _showSnack('Theme picker coming soon'),
              ),
              _divider(),
              _chevronRow(
                icon: Icons.storage_rounded,
                iconColor: const Color(0xFFF57F17),
                iconBg: const Color(0xFFFFF8E1),
                label: 'Clear Cache',
                value: '24 MB',
                onTap: () => _showSnack('Cache cleared'),
              ),
            ],
          ),

          // ── About ─────────────────────────────────────────────
          _sectionLabel('ABOUT'),
          _settingsCard(
            children: [
              _chevronRow(
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
                label: 'Privacy Policy',
                onTap: () => _showSnack('Opening Privacy Policy…'),
              ),
              _divider(),
              _chevronRow(
                icon: Icons.info_rounded,
                iconColor: const Color(0xFF5B5FEE),
                iconBg: const Color(0xFFEEF0FF),
                label: 'Version',
                value: '1.0.0',
                onTap: () => _showSnack("You're on the latest version!"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Reusable widgets ────────────────────────────────────────────────────

  Widget _bannerCard() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
    child: Center(
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: Text(
          'PrioriTask',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white, // must be white for ShaderMask to work
            letterSpacing: -1,
          ),
        ),
      ),
    ),
  );

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
    child: Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9096A2),
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _settingsCard({required List<Widget> children}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFECEEF2), width: 0.5),
    ),
    child: Column(children: children),
  );

  Widget _toggleRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _iconPill(icon, iconColor, iconBg),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF5B5FEE),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE0E2E8),
          ),
        ],
      ),
    ),
  );

  Widget _chevronRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _iconPill(icon, iconColor, iconBg),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: const Color(0xFF9096A2),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFC5C8D0),
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _iconPill(IconData icon, Color iconColor, Color iconBg) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: iconBg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: iconColor, size: 18),
  );

  Widget _divider() => const Divider(
    height: 0.5,
    thickness: 0.5,
    color: Color(0xFFF0F1F3),
    indent: 16,
    endIndent: 0,
  );

  // ─── Helpers ────────────────────────────────────────────────────────────

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}
