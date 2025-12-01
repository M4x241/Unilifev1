import 'package:flutter/material.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/models/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  Color _getCategoryColor() {
    switch (announcement.categoria.toLowerCase()) {
      case 'academico':
        return AppTheme.primaryBlue;
      case 'evento':
        return AppTheme.accentOrange;
      case 'importante':
        return AppTheme.accentOrange;
      case 'deportes':
        return AppTheme.accentGreen;
      default:
        return AppTheme.primaryPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con categoría y fecha
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor().withOpacity(0.3),
                    _getCategoryColor().withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      announcement.categoria.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    announcement.formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.titulo,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.contenido,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 16,
                        color: AppTheme.primaryPurple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.carrera,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryPurple,
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
      ),
    );
  }
}
