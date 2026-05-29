import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String _gender = 'fem';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _gender = user?.gender.isNotEmpty == true ? user!.gender : 'fem';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gender: _gender,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? context.read<SettingsProvider>().t('Profil berhasil disimpan', 'Profile saved')
              : auth.errorMessage ?? 'Gagal menyimpan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.t('Pengaturan Akun', 'Account Settings')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _infoTile(
                settings.t('Nama / Username', 'Name / Username'),
                user?.fullName ?? '-',
                Icons.badge_outlined,
              ),
              _infoTile('Email', user?.email ?? '-', Icons.email_outlined),
              _infoTile(
                settings.t('Peran', 'Role'),
                user?.roleDisplay ?? '-',
                Icons.school_outlined,
              ),
              if (user?.halaqoh != null)
                _infoTile('Halaqoh', user!.halaqoh!.name, Icons.groups_outlined),
              if (user?.halaqoh?.guruName != null)
                _infoTile(
                  settings.t('Guru', 'Teacher'),
                  user!.halaqoh!.guruName!,
                  Icons.person_outline,
                ),
              if (user?.halaqoh?.jadwal.isNotEmpty == true)
                _infoTile(
                  settings.t('Jadwal Halaqoh', 'Halaqoh Schedule'),
                  user!.halaqoh!.jadwal,
                  Icons.calendar_month,
                ),
              const Divider(height: 32),
              Text(
                settings.t('Edit Profil', 'Edit Profile'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: settings.t('Nama Lengkap', 'Full Name'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? settings.t('Wajib diisi', 'Required') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || !v.contains('@')
                    ? settings.t('Email tidak valid', 'Invalid email')
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: InputDecoration(
                  labelText: settings.t('Jenis Kelamin', 'Gender'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'fem',
                    child: Text(settings.t('Perempuan', 'Female')),
                  ),
                  DropdownMenuItem(
                    value: 'male',
                    child: Text(settings.t('Laki-laki', 'Male')),
                  ),
                ],
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(settings.t('SIMPAN PERUBAHAN', 'SAVE CHANGES')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.teal),
      title: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
    );
  }
}
