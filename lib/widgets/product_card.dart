import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: product.imagenUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imagenUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.darkBackground,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.darkBackground,
                          child: const Icon(
                            Icons.fastfood,
                            size: 40,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.darkBackground,
                        child: const Icon(
                          Icons.fastfood,
                          size: 40,
                          color: AppTheme.textSecondary,
                        ),
                      ),
              ),
            ),
            
            // Información del producto
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.nombre,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.categoria != null && product.categoria.isNotEmpty)
                    Text(
                      product.categoria,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryPurple,
                            fontSize: 10,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Bs. ${product.precio.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (!product.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Agotado',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.accentOrange,
                                  fontSize: 9,
                                ),
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
