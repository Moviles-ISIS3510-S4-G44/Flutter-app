import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';

class CreateListingView extends StatefulWidget {
  const CreateListingView({super.key});

  @override
  State<CreateListingView> createState() => _CreateListingViewState();
}

class _CreateListingViewState extends State<CreateListingView> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = '';
  String _condition = 'New';

  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color bgColor = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color borderColor = Color(0xFFE0E0E0);

  final List<String> _categories = ['Books', 'Electronics', 'Furniture', 'Clothing', 'Other'];
  final List<String> _conditions = ['New', 'Like New', 'Used'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateListingViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Create New Listing',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/drafts'),
            child: const Text(
              'Drafts',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Photos',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                Text(
                  '${vm.selectedImage != null ? 1 : 0} / 5 photos',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // photo row with add button + preview
            SizedBox(
              height: 140,
              child: Row(
                children: [
                  // add photo button
                  GestureDetector(
                    onTap: () => _showImageOptions(context, vm),
                    child: Container(
                      width: 130,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: textSecondary,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _DashedBorderPainter(),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 32, color: textSecondary),
                            SizedBox(height: 8),
                            Text(
                              'ADD PHOTO',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // photo preview if selected
                  if (vm.selectedImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            vm.selectedImage!,
                            width: 130,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => vm.reset(),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: Bright, clear photos help items sell faster.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Title field
            _buildField(
              controller: _titleCtrl,
              hint: 'Title (e.g., Organic Chemistry Textbook)',
            ),
            const SizedBox(height: 16),
            // Price field
            _buildField(
              controller: _priceCtrl,
              hint: '\$ Price',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Category dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  hint: const Text(
                    'Select Category',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Condition selector
            const Text(
              'Condition',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _conditions.map((c) {
                final isSelected = _condition == c;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _condition = c),
                    child: Container(
                      margin: EdgeInsets.only(right: c != _conditions.last ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? primaryYellow : borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          c,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? textPrimary : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Description field
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              maxLength: 500,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Item Description',
                hintStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  color: textSecondary,
                ),
                filled: true,
                fillColor: bgColor,
                counterText: '',
                contentPadding: const EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: textPrimary),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_descCtrl.text.length} / 500 CHARACTERS',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: textSecondary,
                  ),
                ),
              ),
            ),
            if (vm.error != null) ...[
              const SizedBox(height: 8),
              Text(vm.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            // Post button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final ok = await vm.createListing(
                          title: _titleCtrl.text.trim(),
                          description: _descCtrl.text.trim(),
                          price: _priceCtrl.text.trim(),
                          category: _selectedCategory.isEmpty ? 'Other' : _selectedCategory,
                        );
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Listing created!')),
                          );
                          context.go('/');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primaryYellow,
                  foregroundColor: textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: vm.isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Post Listing',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          color: textSecondary,
        ),
        filled: true,
        fillColor: bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textPrimary),
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context, CreateListingViewModel vm) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                vm.takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                vm.pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// dashed border painter for the add photo box
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // intentionally empty - the container border handles it
    // just a placeholder for the dashed look
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
