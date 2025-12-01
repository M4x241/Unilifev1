import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/pages/store_page.dart';
import 'package:unilife/pages/home_page.dart';
import 'package:unilife/pages/marketplace_page.dart';
import 'package:unilife/pages/chat_uni_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [HomePage(), MarketplacePage(), ChatUniPage()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('UniLife'),
          ],
        ),
        actions: [
          // Perfil de usuario
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  authService.currentUser?.nombre
                          .substring(0, 1)
                          .toUpperCase() ??
                      'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authService.currentUser?.fullName ?? 'Usuario',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        authService.currentUser?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                PopupMenuItem(
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: AppTheme.accentOrange),
                      SizedBox(width: 8),
                      Text('Cerrar Sesión'),
                    ],
                  ),
                  onTap: () async {
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded),
              label: 'Marketplace',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded),
              label: 'ChatUni',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
