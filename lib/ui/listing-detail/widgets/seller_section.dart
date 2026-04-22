import 'package:flutter/material.dart';

class SellerSection extends StatelessWidget {
  final String? sellerName;
  final String? sellerEmail;
  final bool isLoading;

  const SellerSection({
    super.key,
    this.sellerName,
    this.sellerEmail,
    this.isLoading = false,
  });

  /// Genera las iniciales a partir del nombre (ej. "Juan Pérez" → "JP")
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(
          isLoading: isLoading,
          initials: (sellerName != null && sellerName!.isNotEmpty)
              ? _initials(sellerName!)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: isLoading ? _SkeletonInfo() : _SellerInfo(
            name: sellerName,
            email: sellerEmail,
          ),
        ),
      ],
    );
  }
}

// Avatar 

class _Avatar extends StatelessWidget {
  final bool isLoading;
  final String? initials;

  const _Avatar({required this.isLoading, this.initials});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _shimmerBox(
        child: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade300,
        ),
      );
    }

    if (initials != null) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFFF3E39A),
        child: Text(
          initials!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5A4700),
          ),
        ),
      );
    }

    // Fallback: ícono genérico
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade300,
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}

// Seller info 

class _SellerInfo extends StatelessWidget {
  final String? name;
  final String? email;

  const _SellerInfo({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    final displayName = (name != null && name!.isNotEmpty)
        ? name!
        : 'Unknown Seller';
    final displayEmail = (email != null && email!.isNotEmpty)
        ? email!
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vendedor',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E6E6E),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (displayEmail != null) ...[
          const SizedBox(height: 3),
          Text(
            displayEmail,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        const SizedBox(height: 3),
        Text(
          'Estudiante universitario',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

// Skeleton loader 

class _SkeletonInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerBox(
          child: Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _shimmerBox(
          child: Container(
            height: 16,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _shimmerBox(
          child: Container(
            height: 12,
            width: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}

// Shimmer helper

Widget _shimmerBox({required Widget child}) {
  return _ShimmerWidget(child: child);
}

class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  const _ShimmerWidget({required this.child});

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}