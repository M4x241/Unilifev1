import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final cuOwner = authService.currentUser?.codigoEstudiante ?? '';
      
      if (cuOwner.isEmpty) {
        throw Exception('No se pudo identificar al usuario');
      }

      await authService.apiService.createMarketplaceProduct(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        precio: double.parse(_precioController.text),
        cuOwner: cuOwner,
        imagenUrl: _imagenUrlController.text.isEmpty ? null : _imagenUrlController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto creado exitosamente'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        title: const Text('Nuevo Producto'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título de sección
                Text(
                  'Información del Producto',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del producto',
                    hintText: 'Ej: Calculadora Científica',
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe el producto...',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Precio
                TextFormField(
                  controller: _precioController,
                  decoration: InputDecoration(
                    labelText: 'Precio (Bs.)',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el precio';
                    }
                    final precio = double.tryParse(value);
                    if (precio == null || precio <= 0) {
                      return 'Ingresa un precio válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // URL de imagen (opcional)
                TextFormField(
                  controller: _imagenUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL de imagen (opcional)',
                    hintText: 'https://...',
                    prefixIcon: const Icon(Icons.image),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 32),

                // Botón de submit
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitProduct,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Publicar Producto',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
