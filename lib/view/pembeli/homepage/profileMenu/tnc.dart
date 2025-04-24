import 'package:flutter/material.dart';

class termsAndConditions extends StatelessWidget {
  const termsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Syarat dan Ketentuan",
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
          child: Text("Syarat dan Ketentuan"),
        ),
      ),
    );
  }
}