import 'package:flutter/material.dart';
import 'dart:async';

class RFCLogo extends StatefulWidget {
  @override
  _RFCLogoState createState() => _RFCLogoState();
}

class _RFCLogoState extends State<RFCLogo> {
  bool _isHolding = false; // Untuk mengecek apakah widget sedang di-hold
  Timer? _holdTimer; // Timer untuk menghitung durasi hold
  bool _showAdditionalButton = false; // Untuk menampilkan tombol tambahan

  @override
  void dispose() {
    _holdTimer?.cancel(); // Batalkan timer saat widget di-dispose
    super.dispose();
  }

  void _startHoldTimer() {
    _holdTimer = Timer(Duration(seconds: 2), () {
      setState(() {
        _showAdditionalButton =
            true; // Tampilkan tombol tambahan setelah 2 detik
      });
    });
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel(); // Batalkan timer jika hold dihentikan
    setState(() {
      _isHolding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown: (_) {
            setState(() {
              _isHolding = true;
            });
            _startHoldTimer(); // Mulai timer saat widget di-hold
          },
          onTapUp: (_) {
            _cancelHoldTimer(); // Batalkan timer saat hold dihentikan
          },
          onTapCancel: () {
            _cancelHoldTimer(); // Batalkan timer jika hold dibatalkan
          },
          child: AnimatedOpacity(
            opacity: _isHolding ? 0.8 : 1.0, // Efek opacity saat di-hold
            duration: Duration(milliseconds: 200),
            child: Container(
              height: 100,
              decoration: BoxDecoration(// Sesuaikan dengan kebutuhan
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rooftop",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: "Monserrat_Alternates",
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    "Farming",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: "Monserrat_Alternates",
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    "Center.",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: "Monserrat_Alternates",
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showAdditionalButton)
          Container(
            height: 100,
            color: Colors.white,
            child: Column(
              children: [
                TextButton(onPressed: () {}, child: Text("Admin")),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAdditionalButton = false;
                    });
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
