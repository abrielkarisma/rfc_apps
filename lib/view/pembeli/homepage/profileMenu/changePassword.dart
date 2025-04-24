import 'package:flutter/material.dart';

class changePassword extends StatelessWidget {
  const changePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Ubah Kata Sandi",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Monserrat_Alternates",
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text("Ubah Kata Sandi"),
      ),
    );
  }
}