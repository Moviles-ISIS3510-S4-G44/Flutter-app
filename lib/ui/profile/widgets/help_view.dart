import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  static const Color background = Color(0xFFEEF2F7);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const String _contactEmail = 'marketplace@uniandes.edu.co';

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: '¿Cómo publico un producto?',
      answer:
          'Toca el botón "Sell" en la barra inferior. Completa el título, descripción, precio, condición, fotos y ubicación, luego presiona "Publish listing".',
    ),
    _FaqItem(
      question: '¿Cómo contacto a un vendedor?',
      answer:
          'Abre el detalle del listing y toca "Contactar". Esta función estará disponible próximamente.',
    ),
    _FaqItem(
      question: '¿Qué formatos de imagen se aceptan?',
      answer:
          'Se aceptan imágenes en formato JPG, JPEG, PNG y WEBP. El tamaño máximo por imagen es de 5 MB.',
    ),
    _FaqItem(
      question: '¿Puedo guardar productos favoritos?',
      answer:
          'Sí. Toca la estrella (★) en cualquier listing para agregarlo a tus favoritos. Puedes verlos desde tu perfil en "Favorite listings".',
    ),
    _FaqItem(
      question: '¿Mis datos están seguros?',
      answer:
          'Sí. El token de sesión se guarda de forma cifrada en el dispositivo y nunca se comparte con terceros.',
    ),
    _FaqItem(
      question: '¿Cómo elimino una publicación?',
      answer:
          'Por ahora, eliminar publicaciones se gestiona desde el administrador del marketplace. Escríbenos al correo de soporte si necesitas remover un listing.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Ayuda y soporte',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4BF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFE680)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline_rounded,
                        size: 36, color: textPrimary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Preguntas Frecuentes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Encuentra respuestas rápidas a preguntas comunes.',
                            style: TextStyle(
                                fontSize: 13, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // FAQs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _faqs.length; i++) ...[
                      _FaqTile(item: _faqs[i]),
                      if (i < _faqs.length - 1)
                        const Divider(
                            height: 1, thickness: 1, color: borderColor),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contacto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¿Aún necesitas ayuda?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Escribe a soporte y te responderemos lo antes posible.',
                      style:
                          TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: _contactEmail),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.email_outlined,
                                size: 20, color: textPrimary),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _contactEmail,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            Icon(Icons.copy_outlined,
                                size: 18, color: textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

//  Data 

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

//  FAQ tile con expansión 

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4BF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Q',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF6E6E6E),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  widget.item.answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E6E6E),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}