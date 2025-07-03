import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/komoditas.dart';
import 'package:rfc_apps/service/komoditas.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';

class DetailKomoditasPage extends StatefulWidget {
  final String id;
  const DetailKomoditasPage({super.key, required this.id});

  @override
  State<DetailKomoditasPage> createState() => _DetailKomoditasPageState();
}

class _DetailKomoditasPageState extends State<DetailKomoditasPage> {
  KomoditasData? data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {

      final komoditas = await KomoditasService().getKomoditasById(widget.id);
      setState(() {
        data = komoditas;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(' : ',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Detail Komoditas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Monserrat_Alternates',
              fontWeight: FontWeight.w600,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/homebackground.png',
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 20, right: 20, top: context.getHeight(100), bottom: 20),
            child: data == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: context.getWidth(300),
                          height: context.getHeight(300),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ShimmerImage(
                              imageUrl: data!.gambar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: context.getHeight(20)),
                        _buildRow('Nama Komoditas', data!.nama),
                        _buildRow('Jumlah', data!.jumlah.toString()),
                        _buildRow('Tipe', data!.tipeKomoditas),
                        _buildRow('Satuan', data!.satuan.nama),
                        _buildRow('Jenis Budidaya', data!.jenisBudidaya.nama),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
