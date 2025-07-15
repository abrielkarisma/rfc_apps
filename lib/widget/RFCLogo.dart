import 'package:flutter/material.dart';
import 'dart:async';

class RFCLogo extends StatefulWidget {
  @override
  _RFCLogoState createState() => _RFCLogoState();
}

class _RFCLogoState extends State<RFCLogo> {
  bool _isHolding = false; 
  Timer? _holdTimer; 
  bool _showAdditionalButton = false; 

  @override
  void dispose() {
    _holdTimer?.cancel(); 
    super.dispose();
  }

  void _startHoldTimer() {
    _holdTimer = Timer(Duration(seconds: 2), () {
      setState(() {
        _showAdditionalButton =
            true; 
      });
    });
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel(); 
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
            _startHoldTimer(); 
          },
          onTapUp: (_) {
            _cancelHoldTimer(); 
          },
          onTapCancel: () {
            _cancelHoldTimer(); 
          },
          child: AnimatedOpacity(
            opacity: _isHolding ? 0.8 : 1.0, 
            duration: Duration(milliseconds: 200),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
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
