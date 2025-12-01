import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/services/api_service.dart';
import 'package:unilife/models/whatsapp_group.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatUniPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (_) => ApiService(),
      child: _ChatUniPageContent(),
    );
  }
}

class _ChatUniPageContent extends StatefulWidget {
  @override
  _ChatUniPageContentState createState() => _ChatUniPageContentState();
}

class _ChatUniPageContentState extends State<_ChatUniPageContent> {
  List<WhatsAppGroup> _whatsappGroups =
      []; // Updated to use WhatsAppGroup model
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWhatsAppGroups();
  }

  Future<void> _loadWhatsAppGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final groups = await apiService.getWhatsAppGroups();
      setState(() {
        _whatsappGroups = groups; // Updated to use WhatsAppGroup model
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El enlace proporcionado no es válido.'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Invalid URL: $url');
      return;
    }

    try {
      debugPrint('Attempting to launch URL: $url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('Successfully launched URL: $url');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo abrir el enlace en el navegador predeterminado.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('Failed to launch URL: $url');
      }
    } catch (e) {
      debugPrint('Error al intentar abrir el enlace: $url');
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el enlace: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('ChatUni - Grupos de WhatsApp'),
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
                      onPressed: _loadWhatsAppGroups,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _whatsappGroups.length,
                itemBuilder: (context, index) {
                  final group = _whatsappGroups[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: AppTheme.cardBackground,
                    child: ListTile(
                      title: Text(
                        group.groupName, // Updated to use WhatsAppGroup model
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _launchURL(group.link),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                        ),
                        child: const Text('Unirse'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
