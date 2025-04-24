import 'package:flutter/material.dart';

class accountSetting extends StatelessWidget {
  const accountSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        title: Text("Pengaturan Akun",
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
          child: Text("Pengaturan Akun"),
        ),
      ),
    );
  }
}