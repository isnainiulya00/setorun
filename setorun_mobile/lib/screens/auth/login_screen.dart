import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/halaqoh_model.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLogin = true;
  bool _isSubmitting = false;
  List<HalaqohModel> _halaqohList = [];
  int? _selectedHalaqohId;
  String _selectedGender = 'fem';
  bool _loadingHalaqoh = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  List<HalaqohModel> get _filteredHalaqohList =>
      _halaqohList.where((h) => h.gender == _selectedGender).toList();

  void _syncHalaqohSelection() {
    final filtered = _filteredHalaqohList;
    if (filtered.isEmpty) {
      _selectedHalaqohId = null;
    } else if (!filtered.any((h) => h.id == _selectedHalaqohId)) {
      _selectedHalaqohId = filtered.first.id;
    }
  }

  Future<void> _loadHalaqohIfNeeded() async {
    if (_halaqohList.isNotEmpty || _loadingHalaqoh) return;
    setState(() => _loadingHalaqoh = true);
    try {
      final list = await context.read<AuthProvider>().loadHalaqohList();
      if (!mounted) return;
      setState(() {
        _halaqohList = list;
        _syncHalaqohSelection();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat daftar halaqoh. Periksa koneksi server.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingHalaqoh = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    bool success;

    if (_isLogin) {
      success = await auth.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      if (_selectedHalaqohId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih halaqoh terlebih dahulu.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }
      success = await auth.registerStudent(
        email: _emailController.text,
        fullName: _fullNameController.text,
        gender: _selectedGender,
        password: _passwordController.text,
        passwordConfirm: _passwordConfirmController.text,
        halaqohId: _selectedHalaqohId!,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isBusy = _isSubmitting || auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? 'SETORUN' : 'DAFTAR AKUN',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    _isLogin
                        ? 'Hafalan dari mana saja'
                        : 'Daftar sebagai murid',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.wc_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'fem', child: Text('Perempuan')),
                        DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                      ],
                      onChanged: (v) => setState(() {
                        _selectedGender = v!;
                        _syncHalaqohSelection();
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.text, // Keyboard jadi text biasa
                    decoration: InputDecoration(
                      labelText: 'Email atau Username', // Ganti label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline), // Ganti icon orang
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email atau Username wajib diisi';
                      // Validasi .contains('@') dihapus agar username bisa lolos!
                      return null; 
                    },
                  ),
                  // ------------------------------
                  
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
                  ),
                  const SizedBox(height: 16),

                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _passwordConfirmController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Kata Sandi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return 'Kata sandi tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_loadingHalaqoh)
                      const Center(child: CircularProgressIndicator())
                    else if (_filteredHalaqohList.isEmpty)
                      const Text(
                        'Belum ada halaqoh untuk jenis kelamin ini.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: _selectedHalaqohId,
                        decoration: InputDecoration(
                          labelText: 'Pilih Halaqoh',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.groups_outlined),
                        ),
                        items: _filteredHalaqohList
                            .map(
                              (h) => DropdownMenuItem(
                                value: h.id,
                                child: Text(
                                  '${h.name} (${h.gender == 'male' ? 'Putra' : 'Putri'})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedHalaqohId = v),
                        validator: (v) =>
                            v == null ? 'Pilih halaqoh Anda' : null,
                      ),
                    const SizedBox(height: 8),
                  ] else
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Lupa Kata Sandi?'),
                      ),
                    ),

                  ElevatedButton(
                    onPressed: isBusy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isBusy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isLogin ? 'MASUK' : 'DAFTAR SEKARANG',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? 'Belum punya akun?' : 'Sudah punya akun?',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: isBusy
                            ? null
                            : () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                                if (!_isLogin) _loadHalaqohIfNeeded();
                              },
                        child: Text(
                          _isLogin ? 'Daftar di sini' : 'Masuk di sini',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}