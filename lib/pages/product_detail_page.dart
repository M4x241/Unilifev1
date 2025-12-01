import 'package:flutter/material.dart';
import 'package:unilife/models/marketplace_product.dart';
import 'package:unilife/theme/app_theme.dart';

class ProductDetailPage extends StatelessWidget {
  final MarketplaceProduct product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.titulo),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imagenUrl ?? 'https://via.placeholder.com/150',
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppTheme.darkBackground,
                      child: const Icon(
                        Icons.image,
                        color: AppTheme.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Product Title
            Text(
              product.titulo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            // Product Price
            Text(
              'Precio: Bs. ${product.precio.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Product Description
            Text('Descripción', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              product.descripcion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Seller Information
            if (product.vendedorNombre != null) ...[
              Text('Vendedor', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                product.vendedorNombre!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
