import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/models/product.dart';
import 'package:unilife/widgets/product_card.dart';

class StoreCarouselPage extends StatefulWidget {
  const StoreCarouselPage({Key? key}) : super(key: key);

  @override
  _StoreCarouselPageState createState() => _StoreCarouselPageState();
}

class _StoreCarouselPageState extends State<StoreCarouselPage> {
  List<Product> _products = [];
  List<Product> _cart = [];
  bool _isLoading = true;
  String? _errorMessage;

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

  void _addToCart(Product product) {
    setState(() {
      if (!_cart.contains(product)) {
        _cart.add(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.nombre} agregado al carrito'),
            backgroundColor: AppTheme.accentGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _showCartProducts() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El carrito está vacío'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _CartPage(cartProducts: _cart)),
    );
  }

  // Split products into two groups for the two carousels
  List<Product> get _firstHalfProducts {
    final half = (_products.length / 2).ceil();
    return _products.take(half).toList();
  }

  List<Product> get _secondHalfProducts {
    final half = (_products.length / 2).ceil();
    return _products.skip(half).toList();
  }

  void _showReservationModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Reserva Completada',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Tu reserva ha sido procesada exitosamente!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Productos reservados: ${_cart.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: Bs. ${_cart.fold<double>(0, (sum, item) => sum + item.precio).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _cart.clear();
                });
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('Tienda Online'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showCartProducts,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.accentOrange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
                      onPressed: _loadProducts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildCarousel('Bebidas', _firstHalfProducts),
                    const SizedBox(height: 30),
                    _buildCarousel('Snacks', _secondHalfProducts),
                    const SizedBox(height: 30),
                    // Action Buttons in same row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showCartProducts,
                              icon: const Icon(Icons.list, size: 18),
                              label: const Text(
                                'Ver Carrito',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_cart.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Agrega productos al carrito primero',
                                      ),
                                      backgroundColor: AppTheme.accentOrange,
                                    ),
                                  );
                                } else {
                                  _showReservationModal();
                                }
                              },
                              icon: const Icon(Icons.shopping_cart, size: 18),
                              label: const Text(
                                'Reservar',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCarousel(String title, List<Product> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'No hay productos disponibles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(title, style: Theme.of(context).textTheme.displayMedium),
        ),
        const SizedBox(height: 16),
        CarouselSlider.builder(
          itemCount: products.length,
          itemBuilder: (context, index, realIndex) {
            final product = products[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ProductCard(
                product: product,
                onTap: () => _addToCart(product),
              ),
            );
          },
          options: CarouselOptions(
            height: 240,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true,
            aspectRatio: 2.0,
            viewportFraction: 0.8,
          ),
        ),
      ],
    );
  }
}

// Cart Page to show selected products
class _CartPage extends StatelessWidget {
  final List<Product> cartProducts;

  const _CartPage({required this.cartProducts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('Carrito'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: cartProducts.length,
          itemBuilder: (context, index) {
            final product = cartProducts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: AppTheme.cardBackground,
              child: ListTile(
                title: Text(
                  product.nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Bs. ${product.precio.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color.fromARGB(255, 199, 199, 199),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                  onPressed: () {
                    cartProducts.removeAt(index);
                    Navigator.of(context).pop(); // Close the current page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _CartPage(cartProducts: cartProducts),
                      ),
                    ); // Reopen the cart page to refresh the list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product.nombre} eliminado del carrito',
                        ),
                        backgroundColor: AppTheme.accentRed,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
