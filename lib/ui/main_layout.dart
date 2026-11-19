import 'package:flutter/material.dart';

import 'screen/block_sel_screen.dart';
import 'screen/dashboard_screen.dart';
import 'screen/kunjungan_screen.dart';
import 'screen/laporan_screen.dart';
import 'screen/narapidana_screen.dart';
import 'screen/operasional_sipir_screen.dart';
import 'screen/persetujuan_screen.dart';
import 'screen/petugas_screen.dart';
import 'screen/login_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    this.namaUser = 'Maya Pramesti',
    this.jabatanUser = 'Kepala Lapas',
    this.loggedInUser = const {
      'nama': 'Maya Pramesti',
      'nip': '-',
      'blok': 'Blok A',
    },
  });

  final String namaUser;
  final String jabatanUser;
  final Map<String, Object?> loggedInUser;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  static const _menuItems = [
    (title: 'Ringkasan', icon: Icons.dashboard),
    (title: 'Data Narapidana', icon: Icons.people),
    (title: 'Blok & Sel', icon: Icons.grid_view),
    (title: 'Petugas', icon: Icons.badge),
    (title: 'Operasional Sipir', icon: Icons.assignment_ind),
    (title: 'Kunjungan', icon: Icons.calendar_today),
    (title: 'Persetujuan', icon: Icons.check_circle_outline),
    (title: 'Laporan Lapas', icon: Icons.description),
  ];

  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    DashboardScreen(onNavigate: _navigateTo),
    NarapidanaScreen(),
    BlokSelScreen(),
    PetugasScreen(),
    OperasionalSipirScreen(loggedInUser: widget.loggedInUser),
    KunjunganScreen(),
    PersetujuanScreen(),
    LaporanScreen(),
  ];

  void _navigateTo(int index) {
    if (index < 0 || index >= _menuItems.length) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return initials.isEmpty ? 'U' : initials;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_menuItems[_selectedIndex].title),
              backgroundColor: const Color(0xFF101828),
              foregroundColor: Colors.white,
            ),
            drawer: Drawer(
              backgroundColor: const Color(0xFF101828),
              child: _buildSidebar(),
            ),
            body: _buildPage(),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF101828),
          body: Row(
            children: [
              SizedBox(width: 260, child: _buildSidebar()),
              Expanded(child: _buildPage()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    return ColoredBox(
      color: const Color(0xFF101828),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.tealAccent),
                  SizedBox(width: 10),
                  Text(
                    'SIMLAPAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) => _buildSidebarItem(index),
              ),
            ),
            _buildProfileMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final item = _menuItems[index];
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? Colors.tealAccent : Colors.grey[400],
          size: 20,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
            fontSize: 14,
          ),
        ),
        trailing: index == 6 ? const _MenuBadge(label: '5') : null,
        selected: isSelected,
        onTap: () {
          _navigateTo(index);
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, -100),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'pengaturan') {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Pengaturan Akun'),
              content: Text(
                'Kelola preferensi akun untuk ${widget.namaUser} '
                '(${widget.jabatanUser}) di sini.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          );
        } else if (value == 'logout') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'pengaturan',
          child: Row(
            children: [
              Icon(Icons.settings, color: Color(0xFF0F766E), size: 20),
              SizedBox(width: 12),
              Text('Pengaturan Akun'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Logout (Keluar)', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Material(
        color: Colors.black26,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    _initials(widget.namaUser),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.namaUser,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        widget.jabatanUser,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.unfold_more, color: Colors.grey[400], size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    return ColoredBox(
      color: const Color(0xFFF8F9FA),
      child: _pages[_selectedIndex],
    );
  }
}

class _MenuBadge extends StatelessWidget {
  const _MenuBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
