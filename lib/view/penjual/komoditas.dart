import 'package:flutter/material.dart';

class Komoditas extends StatefulWidget {
  const Komoditas({super.key});

  @override
  State<Komoditas> createState() => _KomoditasState();
}

class _KomoditasState extends State<Komoditas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Komoditas",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Monserrat_Alternates",
                fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text("Daftar Komoditas"),
      ),
    );
  }
}