import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/models/announcement.dart';
import 'package:unilife/widgets/announcement_card.dart';
import 'package:unilife/pages/store_carousel_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'Academico',
    'Evento',
    'Importante',
    'Deportes',
  ];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final announcements = await authService.apiService.getAnnouncements();

      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Announcement> get _filteredAnnouncements {
    if (_selectedCategory == 'Todos') {
      return _announcements;
    }
    return _announcements
        .where(
          (a) => a.categoria.toLowerCase() == _selectedCategory.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: RefreshIndicator(
        onRefresh: _loadAnnouncements,
        color: AppTheme.primaryPurple,
        child: CustomScrollView(
          slivers: [
            // Market image button at top
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoreCarouselPage(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    80,
                    20,
                    20,
                  ), // Increased top padding to 60
                  child: Image.asset(
                    'assets/images/market_image.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Header for announcements (moved down)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📢 Anuncios',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mantente al día con las novedades',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Placeholder ChatUni section
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.all(20),
            //     child: Container(
            //       width: double.infinity,
            //       padding: const EdgeInsets.all(16),
            //       decoration: BoxDecoration(
            //         color: AppTheme.cardBackground,
            //         borderRadius: BorderRadius.circular(16),
            //         boxShadow: AppTheme.cardShadow,
            //       ),
            //       child: Text(
            //         'ChatUni (próximamente)',
            //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //           color: AppTheme.textSecondary,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //     ),
            //   ),
            // ),

            // Filtros de categoría
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppTheme.primaryGradient
                              : null,
                          color: isSelected ? null : AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: isSelected ? AppTheme.cardShadow : null,
                        ),
                        child: Text(
                          category,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Lista de anuncios
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryPurple,
                    ),
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.accentOrange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAnnouncements,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredAnnouncements.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay anuncios disponibles',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final announcement = _filteredAnnouncements[index];
                    return AnnouncementCard(
                      announcement: announcement,
                      onTap: () {
                        _showAnnouncementDetails(announcement);
                      },
                    );
                  }, childCount: _filteredAnnouncements.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetails(Announcement announcement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              announcement.titulo,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),

            // Metadata
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    announcement.categoria,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.school, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  announcement.carrera,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  announcement.formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contenido
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  announcement.contenido,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
