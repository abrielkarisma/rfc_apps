import 'package:flutter/material.dart';

class privacyP extends StatelessWidget {
  const privacyP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kebijakan Privasi",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Monserrat_Alternates",
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: Center(
          child: Text("Kebijakan Privasi"),
        ),
      ),
    );
  }
}