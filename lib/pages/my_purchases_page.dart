import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/models/marketplace_product.dart';

class MyPurchasesPage extends StatefulWidget {
  @override
  _MyPurchasesPageState createState() => _MyPurchasesPageState();
}

class _MyPurchasesPageState extends State<MyPurchasesPage> {
  List<MarketplaceProduct> _purchases = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyPurchases();
  }

  Future<void> _loadMyPurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final cu = authService.currentUser?.codigoEstudiante ?? '';
      final purchases = await authService.apiService.getMyPurchases(cu);
      // Show only reserved or sold items
      final filtered = purchases
          .where(
            (p) =>
                p.estado.toLowerCase() == 'reservado' ||
                p.estado.toLowerCase() == 'vendido',
          )
          .toList();

      setState(() {
        _purchases = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('Mis Compras'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryPurple,
                  ),
                ),
              )
            : _errorMessage != null
            ? Center(
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
                      onPressed: _loadMyPurchases,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : _purchases.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: AppTheme.primaryPurple.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No has comprado productos\naún',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explora el marketplace para\nencontrar productos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadMyPurchases,
                color: AppTheme.primaryPurple,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20), // Apply padding here
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = _purchases[index];
                          return _buildPurchaseCard(product);
                        }, childCount: _purchases.length),
                      ),
                    ),
                    // End-of-list message for purchases
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Text(
                          'Los productos comerciados en esta plataforma, deben recogerse del Centro de Estudiantes de las TICs',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPurchaseCard(MarketplaceProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imagenUrl ?? 'https://via.placeholder.com/80',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppTheme.darkBackground,
                        child: const Icon(
                          Icons.image,
                          color: AppTheme.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.titulo,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bs. ${product.precio.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.estado.toLowerCase() == 'vendido'
                              ? AppTheme.accentGreen.withOpacity(0.2)
                              : AppTheme.accentOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.estado.toLowerCase() == 'vendido'
                              ? 'Listo para recoger'
                              : 'Esperando Entrega',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: product.estado.toLowerCase() == 'vendido'
                                    ? AppTheme.accentGreen
                                    : AppTheme.accentOrange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product.vendedorNombre != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Información del vendedor',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    product.vendedorNombre!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (product.cuOwner != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.badge,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CU: ${product.cuOwner}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
