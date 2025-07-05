import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/komoditas.dart';
import 'package:rfc_apps/service/komoditas.dart';
import 'package:rfc_apps/widget/komoditas_card.dart';

class Komoditas extends StatefulWidget {
  const Komoditas({super.key});

  @override
  State<Komoditas> createState() => _KomoditasState();
}

class _KomoditasState extends State<Komoditas> {
  late Future<List<KomoditasData>> _komoditasFuture;

  @override
  void initState() {
    super.initState();
    _komoditasFuture = _fetchKomoditas();
  }

  Future<void> _refreshKomoditas() async {
    setState(() {
      _komoditasFuture = _fetchKomoditas();
    });
  }

  Future<List<KomoditasData>> _fetchKomoditas() async {
    final response = await KomoditasService().getUnproductKomoditas();
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Komoditas',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Monserrat_Alternates',
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
            child: RefreshIndicator(
              onRefresh: _refreshKomoditas,
              child: FutureBuilder<List<KomoditasData>>(
                future: _komoditasFuture,
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat komoditas'));
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('Tidak ada komoditas'));
                }
                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 143 / 160,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return KomoditasCard(komoditas: list[index]);
                  },
                );
              },
            ),
          ),
       ) ],
      ),
    );
  }
}
