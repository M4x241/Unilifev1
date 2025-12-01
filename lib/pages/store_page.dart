import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/models/product.dart';
import 'package:unilife/widgets/product_card.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Todos';

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
      final products = await authService.apiService.getStoreProducts();
      
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

  List<String> get _categories {
    final categories = _products.map((p) => p.categoria).toSet().toList();
    return ['Todos', ...categories];
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Todos') {
      return _products;
    }
    return _products.where((p) => p.categoria == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
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
                      '🛍️ Tienda',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Productos disponibles en el campus',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Filtros de categoría
            if (!_isLoading && _products.isNotEmpty)
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
                            gradient: isSelected ? AppTheme.primaryGradient : null,
                            color: isSelected ? null : AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: isSelected ? AppTheme.cardShadow : null,
                          ),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

            // Grid de productos
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
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
            else if (_filteredProducts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos disponibles',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          _showProductDetails(product);
                        },
                      );
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Container(
                height: 250,
                width: double.infinity,
                color: AppTheme.darkBackground,
                child: product.imagenUrl != null
                    ? Image.network(
                        product.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.fastfood,
                          size: 80,
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood,
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
                    // Nombre y categoría
                    Text(
                      product.nombre,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.categoria,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryPurple,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    Text(
                      product.descripcion,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Stock
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 20,
                          color: product.isAvailable
                              ? AppTheme.accentGreen
                              : AppTheme.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.isAvailable
                              ? 'Stock: ${product.stock} unidades'
                              : 'Agotado',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: product.isAvailable
                                    ? AppTheme.accentGreen
                                    : AppTheme.accentOrange,
                              ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Precio y botón
                    Row(
                      children: [
                        Text(
                          'Bs. ${product.precio.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppTheme.accentGreen,
                              ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: product.isAvailable
                              ? () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.nombre} agregado al carrito'),
                                      backgroundColor: AppTheme.accentGreen,
                                    ),
                                  );
                                }
                              : null,
                          child: const Text('Agregar al carrito'),
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
    );
  }
}
