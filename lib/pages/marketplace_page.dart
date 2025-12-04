import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/models/marketplace_product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unilife/pages/my_products_page.dart';
import 'package:unilife/pages/my_purchases_page.dart';

class MarketplacePage extends StatefulWidget {
  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  List<MarketplaceProduct> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isGridView = false; // Toggle between grid and list view

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final products = await authService.apiService.getMarketplaceProducts();
      // Show only products with status 'publicado' (available)
      final available = products
          .where((p) => p.estado.toLowerCase() == 'publicado')
          .toList();
      setState(() {
        _products = available;
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
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: RefreshIndicator(
        onRefresh: _loadProducts,
        color: AppTheme.primaryPurple,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏪 Marketplace',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compra y vende entre estudiantes',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action buttons row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MyProductsPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.inventory_2, size: 18),
                            label: const Text(
                              'Mis Productos',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MyPurchasesPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_bag, size: 18),
                            label: const Text(
                              'Mis Compras',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // View toggle button
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                          icon: Icon(
                            _isGridView ? Icons.view_list : Icons.grid_view,
                            color: AppTheme.primaryPurple,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.cardBackground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Grid de productos
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
                        onPressed: _loadProducts,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.store_outlined,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos en el marketplace',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              )
            else
              _isGridView
                  ? SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = _products[index];
                          return _buildGridCard(product);
                        }, childCount: _products.length),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = _products[index];
                          return _buildProductCard(product);
                        }, childCount: _products.length),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(MarketplaceProduct product) {
    final isSold = product.cuComprador != null;

    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Card(
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
                            : AppTheme.accentOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'nuevo - casi nuevo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Button for reserved products to mark as delivered
                    if (product.estado.toLowerCase() == 'reservado')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await Provider.of<AuthService>(
                                context,
                                listen: false,
                              ).apiService.updateMarketplaceProductStatus(
                                productId: product.id,
                                status: 'vendido',
                              );
                              // Refresh after update
                              _loadProducts();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error al marcar entregado: $e',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Entregado'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGreen,
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
    );
  }

  Widget _buildGridCard(MarketplaceProduct product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 1,
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
                            Icons.shopping_bag,
                            size: 40,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.darkBackground,
                        child: const Icon(
                          Icons.shopping_bag,
                          size: 40,
                          color: AppTheme.textSecondary,
                        ),
                      ),
              ),
            ),
            // Información
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.titulo,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bs. ${product.precio.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.vendedorNombre ?? 'Vendedor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(MarketplaceProduct product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: AppTheme.darkBackground,
                    child: product.imagenUrl != null
                        ? Image.network(
                            product.imagenUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.shopping_bag,
                                  size: 80,
                                  color: AppTheme.textSecondary,
                                ),
                          )
                        : const Icon(
                            Icons.shopping_bag,
                            size: 80,
                            color: AppTheme.textSecondary,
                          ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(
                          product.titulo,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 16),

                        // Vendedor y estado
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 20,
                              color: AppTheme.primaryPurple,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.vendedorNombre ?? 'Vendedor',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: product.isNew
                                    ? AppTheme.accentGreen.withOpacity(0.2)
                                    : AppTheme.primaryBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                product.estado,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: product.isNew
                                          ? AppTheme.accentGreen
                                          : AppTheme.primaryBlue,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Descripción
                        Text(
                          product.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const Spacer(),

                        // Mostrar el precio arriba y las acciones en una fila separada
                        Text(
                          'Bs. ${product.precio.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(color: AppTheme.accentGreen),
                        ),
                        const SizedBox(height: 12),
                        if (product.estado.toLowerCase() == 'publicado')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(
                                    context,
                                  ); // Close the bottom sheet
                                  try {
                                    await Provider.of<AuthService>(
                                      context,
                                      listen: false,
                                    ).apiService.updateMarketplaceProductStatus(
                                      productId: product.id,
                                      status: 'reservado',
                                      cuComprador: Provider.of<AuthService>(
                                        context,
                                        listen: false,
                                      ).currentUser?.codigoEstudiante,
                                    );
                                    // Refresh list after status change
                                    _loadProducts();
                                    _showReservationModal();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al reservar: $e'),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.book_online),
                                label: const Text('Reservar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentOrange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(
                                    context,
                                  ); // Close the bottom sheet
                                  final whatsapp = product.vendedorWhatsapp;
                                  if (whatsapp == null ||
                                      whatsapp.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Número de WhatsApp no disponible.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // Normalize number: remove non-digit characters and leading +
                                  final digitsOnly = whatsapp.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    '',
                                  );
                                  final uri = Uri.parse(
                                    'https://wa.me/$digitsOnly',
                                  );
                                  try {
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No se pudo abrir WhatsApp.',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error al abrir WhatsApp: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text('Contactar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }

  void _showReservationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(24),
              // Let content size itself but cap height to avoid overflow
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_online,
                    size: 48,
                    color: AppTheme.accentGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Reservación exitosa',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu reserva se ha registrado. Revisa el estado de la entrega en Mis Compras.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
