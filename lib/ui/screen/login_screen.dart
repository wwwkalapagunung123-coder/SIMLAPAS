import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../main_layout.dart';
import '../../helpers/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static String? _rememberedUsername;

  bool _obscurePassword = true;
  bool _rememberUsername = _rememberedUsername != null;
  final TextEditingController _userController = TextEditingController(
    text: _rememberedUsername ?? '',
  );
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Fungsi Proses Login dengan SQLite
  Future<void> _handleLogin() async {
    final username = _userController.text.trim();
    final password = _passController.text;

    if (username.isEmpty || password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIP/nama pengguna dan kata sandi wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, Object?>? user;
    try {
      user = await DatabaseHelper.instance.loginUser(username, password);
    } catch (error, stackTrace) {
      debugPrint('Login gagal mengakses database: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terjadi kesalahan saat mengakses database. Coba lagi.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    if (user != null) {
      final namaUser = user['nama'] as String;
      final role = user['role'] as String;
      final blok = user['blok'] as String? ?? '-';
      final jabatanInfo = role == 'Sipir'
          ? 'Sipir Jaga · $blok'
          : 'Kepala Lapas';

      if (_rememberUsername) {
        _rememberedUsername = username;
      } else {
        _rememberedUsername = null;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainLayout(
            namaUser: namaUser,
            jabatanUser: jabatanInfo,
            loggedInUser: user!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal Masuk: NIP atau Kata Sandi salah!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi Dialog Pendaftaran Akun Baru (Register) ke SQLite
  void _showRegisterDialog() {
    final TextEditingController regNama = TextEditingController();
    final TextEditingController regNip = TextEditingController();
    final TextEditingController regPass = TextEditingController();
    String regRole = 'Kepala Lapas';
    String regBlok = 'Blok A';
    var isRegistering = false;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text(
            'Buat Akun Baru SIMLAPAS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: regNama,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regNip,
                    decoration: const InputDecoration(
                      labelText: 'NIP / ID Pengguna',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regPass,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Kata Sandi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pilih Peran:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: regRole,
                    items: ['Kepala Lapas', 'Sipir']
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setStateDialog(() => regRole = value);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (regRole == 'Sipir') ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Pilih Blok Jaga:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: regBlok,
                      items: ['Blok A', 'Blok B', 'Blok C', 'Blok Isolasi']
                          .map(
                            (blok) => DropdownMenuItem(
                              value: blok,
                              child: Text(blok),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setStateDialog(() => regBlok = value);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isRegistering ? null : () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (isRegistering) return;
                if (regNama.text.trim().isEmpty ||
                    regNip.text.trim().isEmpty ||
                    regPass.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua kolom harus diisi!')),
                  );
                  return;
                }

                setStateDialog(() => isRegistering = true);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await DatabaseHelper.instance.registerUser(
                    nama: regNama.text.trim(),
                    nip: regNip.text.trim(),
                    password: regPass.text,
                    role: regRole,
                    blok: regRole == 'Sipir' ? regBlok : null,
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('✅ Akun berhasil dibuat! Silakan login.'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                } catch (error, stackTrace) {
                  debugPrint('Pendaftaran gagal: $error\n$stackTrace');
                  if (!context.mounted) return;
                  setStateDialog(() => isRegistering = false);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        error is StateError &&
                                error.message == 'NIP sudah terdaftar.'
                            ? 'NIP sudah terdaftar.'
                            : error is DatabaseException &&
                                  error.isUniqueConstraintError()
                            ? 'NIP sudah terdaftar.'
                            : 'Gagal menyimpan akun: $error',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: isRegistering
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Daftar Akun'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // ==========================================
          // PANEL KIRI (Background Gelap khas SIMLAPAS)
          // ==========================================
          if (isWide)
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFF101828),
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0F766E,
                            ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF0F766E)),
                          ),
                          child: const Icon(
                            Icons.security,
                            color: Colors.tealAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SIMLAPAS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'SISTEM MANAJEMEN LAPAS',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 2,
                          color: Colors.tealAccent,
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                        const Text(
                          'Pengelolaan lapas\nyang terintegrasi\ndan terlindungi.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Akses data penghuni, operasional petugas, dan persetujuan\ndalam satu sistem sesuai kewenangan Anda.',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.apartment,
                                color: Colors.tealAccent,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UNIT KERJA',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Lapas Kelas IIA Suryatama',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Jawa Tengah · LP-ST01',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Akses berbasis peran\nInformasi sensitif dilindungi dan akses dicatat. Hanya untuk pengguna yang berwenang.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ==========================================
          // PANEL KANAN (Form Login Putih Bersih)
          // ==========================================
          Expanded(
            flex: isWide ? 6 : 1,
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned(
                    top: 24,
                    right: 48,
                    child: isWide
                        ? TextButton.icon(
                            onPressed: () => _showHelp(context),
                            icon: Icon(
                              Icons.help_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            label: Text(
                              'Butuh bantuan? Hubungi administrator',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () => _showHelp(context),
                            tooltip: 'Bantuan',
                            icon: Icon(
                              Icons.help_outline,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        80,
                        24,
                        isWide ? 120 : 32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0F766E,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 14,
                                      color: Color(0xFF0F766E),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'PORTAL INTERNAL',
                                      style: TextStyle(
                                        color: Color(0xFF0F766E),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Selamat datang kembali',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Masuk dengan akun petugas atau kepala lapas untuk\nmelanjutkan ke ruang kerja Anda.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Input NIP / Nama Pengguna
                              const Text(
                                'NIP / Nama pengguna',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF344054),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _userController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan NIP atau Nama Pengguna',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Input Kata Sandi
                              const Text(
                                'Kata sandi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF344054),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _passController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan kata sandi',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey[500],
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Opsi Ingat Saya & Lupa Kata Sandi
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Checkbox(
                                          value: _rememberUsername,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberUsername =
                                                  value ?? false;
                                              _rememberedUsername =
                                                  _rememberUsername
                                                  ? _userController.text.trim()
                                                  : null;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ingat nama pengguna',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () => _showHelp(context),
                                    child: const Text(
                                      'Lupa kata sandi?',
                                      style: TextStyle(
                                        color: Color(0xFF0F766E),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Tombol Masuk (Terhubung SQLite)
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F766E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed:
                                      _handleLogin, // Memanggil validasi SQLite
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Masuk',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  'Hak akses disesuaikan secara otomatis dengan peran akun Anda.',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Tombol Buat Akun (Hubungkan ke Dialog Register)
                              Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Belum memiliki akun? ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _showRegisterDialog,
                                      child: const Text(
                                        'Buat akun baru',
                                        style: TextStyle(
                                          color: Color(0xFF0F766E),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Footer Kanan Bawah (Disclaimer)
                  if (isWide)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 13,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Jaga kerahasiaan akun Anda. Jangan bagikan kata sandi dan selalu keluar setelah menggunakan perangkat bersama.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '© 2026 SIMLAPAS · Sistem Manajemen Lapas',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            'Data fiktif untuk rancangan · Gunakan informasi sesuai kewenangan.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bantuan Administrator'),
        content: const Text(
          'Silakan daftarkan akun melalui tombol "Buat akun baru" di halaman login atau hubungi administrator.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
