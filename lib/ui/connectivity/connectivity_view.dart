import 'package:flutter/material.dart';

class ConnectivityView extends StatefulWidget {
  const ConnectivityView({super.key});

  @override
  State<ConnectivityView> createState() => _ConnectivityViewState();
}

class _ConnectivityViewState extends State<ConnectivityView> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Color(0xFFFFD700),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              'You are offline. This app requires an internet connection for this feature.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),

          // Botón X
          GestureDetector(
            onTap: () {
              setState(() {
                _isVisible = false;
              });
            },
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}