import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/session_manager.dart';
import 'login_page.dart';

class SettingsPage2 extends StatefulWidget {
  const SettingsPage2({super.key});

  @override
  State<SettingsPage2> createState() => _SettingsPage2State();
}

class _SettingsPage2State extends State<SettingsPage2> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0066FF),
          title: const Text("Paramètres", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                _SingleSection(
                  title: "Général",
                  children: [
                    _CustomListTile(
                      title: "Mode sombre",
                      icon: Icons.dark_mode_outlined,
                      trailing: Switch(
                        value: _isDark,
                        onChanged: (value) {
                          setState(() => _isDark = value);
                        },
                      ),
                    ),
                    const _CustomListTile(
                      title: "Notifications",
                      icon: Icons.notifications_none_rounded,
                    ),
                    const _CustomListTile(
                      title: "Sécurité",
                      icon: CupertinoIcons.lock_shield,
                    ),
                  ],
                ),
                const Divider(),
                const _SingleSection(
                  title: "Profil",
                  children: [
                    _CustomListTile(
                      title: "Compte",
                      icon: Icons.person_outline_rounded,
                    ),
                    _CustomListTile(
                      title: "Messagerie",
                      icon: Icons.message_outlined,
                    ),
                    _CustomListTile(
                      title: "Appels",
                      icon: Icons.phone_outlined,
                    ),
                    _CustomListTile(
                      title: "Contacts",
                      icon: Icons.contacts_outlined,
                    ),
                    _CustomListTile(
                      title: "Calendrier",
                      icon: Icons.calendar_today_rounded,
                    ),
                  ],
                ),
                const Divider(),
                _SingleSection(
                  children: [
                    const _CustomListTile(
                      title: "Aide & commentaires",
                      icon: Icons.help_outline_rounded,
                    ),
                    const _CustomListTile(
                      title: "À propos",
                      icon: Icons.info_outline_rounded,
                    ),
                    _CustomListTile(
                      title: "Se déconnecter",
                      icon: Icons.exit_to_app_rounded,
                      onTap: () async {
                        await SessionManager.clearSession();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                        );
                      },
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

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _CustomListTile({
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon, color: const Color(0xFF0066FF)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _SingleSection({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(children: children),
      ],
    );
  }
}
