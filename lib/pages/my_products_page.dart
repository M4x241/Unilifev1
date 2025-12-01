import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/models/marketplace_product.dart';
import 'package:unilife/pages/add_product_page.dart';

class MyProductsPage extends StatefulWidget {
  @override
  _MyProductsPageState createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  List<MarketplaceProduct> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyProducts();
  }

  Future<void> _loadMyProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final cu = authService.currentUser?.codigoEstudiante ?? '';
      final products = await authService.apiService.getMyProducts(cu);

      setState(() {
        _products = products;
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
        title: const Text('Mis Productos'),
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
                      onPressed: _loadMyProducts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : _products.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: AppTheme.primaryPurple.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes productos\nen el marketplace',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Agrega tu primer producto\ncon el botón +',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadMyProducts,
                color: AppTheme.primaryPurple,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = _products[index];
                          return _buildProductCard(product);
                        }, childCount: _products.length),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    // End-of-list message
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Text(
                          'Se debe entregar el producto al Centro de Estudiantes de las TICs, antes de marcar como vendido',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductPage()),
          );
          if (result == true) {
            _loadMyProducts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }

  Widget _buildProductCard(MarketplaceProduct product) {
    final isSold = product.cuComprador != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                      color: isSold
                          ? AppTheme.accentGreen.withOpacity(0.2)
                          : AppTheme.accentOrange.withOpacity(0.0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.estado.toLowerCase() == 'publicado')
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await Provider.of<AuthService>(
                                    context,
                                    listen: false,
                                  ).apiService.deleteMarketplaceProduct(
                                    product.id,
                                  );
                                  _loadMyProducts();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al borrar producto: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentRed,
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ),
                        if (product.estado.toLowerCase() == 'reservado')
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await Provider.of<AuthService>(
                                    context,
                                    listen: false,
                                  ).apiService.updateMarketplaceProductStatus(
                                    productId: product.id,
                                    status: 'vendido',
                                  );
                                  _loadMyProducts();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al actualizar producto: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentGreen,
                              ),
                              child: const Text('Entregado al C.E.'),
                            ),
                          ),
                        if (isSold && product.compradorNombre != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Comprador: ${product.compradorNombre}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ),
                      ],
                    ),
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
