import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/widget/produk_list.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Home extends StatefulWidget {
  final VoidCallback onSeeMoreArticles;
  final VoidCallback onSeeMoreProducts;

  const Home(
      {super.key,
      required this.onSeeMoreArticles,
      required this.onSeeMoreProducts});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Key _produkListKey = UniqueKey();
  final SaldoService _saldoService = SaldoService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<Map<String, dynamic>>? _saldoFuture;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _produkListKey = UniqueKey();
    _initializeSaldo();
  }

  // Method baru untuk inisialisasi saldo yang lebih aman
  Future<void> _initializeSaldo() async {
    try {
      await _getUserId();
      if (_userId.isNotEmpty) {
        setState(() {
          _saldoFuture = _saldoService.getMySaldoByIdUser(_userId);
        });
      } else {
        setState(() {
          _saldoFuture = Future.value({'saldoTersedia': '0'});
        });
      }
    } catch (e) {
      print("Error initializing saldo: $e");
      setState(() {
        _saldoFuture = Future.value({'saldoTersedia': '0'});
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data ketika aplikasi kembali aktif
      _refreshHome();
    }
  }

  Future<void> _getUserId() async {
    try {
      final id = await _storage.read(key: "id");
      setState(() {
        _userId = id ?? "";
      });
    } catch (e) {
      print("Error getting user ID: $e");
    }
  }

  Future<void> _loadSaldo() async {
    await _initializeSaldo();
  }

  Future<void> _refreshHome() async {
    await _initializeSaldo();
    setState(() {
      _produkListKey = UniqueKey();
    });
  }

  String formatRupiah(dynamic amount) {
    double numericAmount = 0.0;
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(numericAmount);
  }

  Widget _buildSaldoCard(String saldo) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/saldo'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, const Color(0xFF93E2B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Tersedia:',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatRupiah(saldo),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: context.getHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: context.getWidth(10)),
                    Text(
                      'Lihat Riwayat',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: context.getWidth(10)),
                    Text(
                      'Rekening Saya',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: 20, right: 20, top: context.getHeight(100), bottom: 20),
      width: double.infinity,
      height: double.infinity,
      child: Column(children: [
        Container(
          width: double.infinity,
          child: Text("Home",
              style: TextStyle(
                  fontFamily: "poppins",
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.start),
        ),
        Padding(padding: EdgeInsets.only(top: context.getHeight(20))),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshHome,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _saldoFuture == null
                      ? Container(
                          width: double.infinity,
                          height: context.getHeight(120),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                        )
                      : FutureBuilder<Map<String, dynamic>>(
                          future: _saldoFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: double.infinity,
                                height: context.getHeight(120),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return GestureDetector(
                                onTap: _loadSaldo,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Gagal memuat saldo',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontFamily: 'poppins'),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              final saldoTersedia =
                                  snapshot.data!['saldoTersedia']?.toString() ??
                                      '0';

                              return _buildSaldoCard(saldoTersedia);
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                  SizedBox(height: context.getHeight(20)),
                  Padding(padding: EdgeInsets.only(top: context.getHeight(26))),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Baru Saja Ditambahkan",
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.start),
                            GestureDetector(
                              onTap: () {
                                widget.onSeeMoreProducts();
                              },
                              child: Row(
                                children: [
                                  Text("Lihat lebih",
                                      style: TextStyle(
                                          fontFamily: "poppins",
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.start),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 12,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: context.getHeight(6),
                        ),
                        Container(
                            child: ProdukCarousel(
                          key: _produkListKey,
                          cardType: "rfc",
                          id: "",
                          showDeletedProducts:
                              false, // Hanya tampilkan produk yang tidak dihapus
                        )),
                        SizedBox(
                          height: context.getHeight(8),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Lihat Produk UMKM",
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.start),
                            GestureDetector(
                              onTap: () {
                                widget.onSeeMoreProducts();
                              },
                              child: Row(
                                children: [
                                  Text("Lihat lebih",
                                      style: TextStyle(
                                          fontFamily: "poppins",
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.start),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 12,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: context.getHeight(8),
                        ),
                        Container(
                            child: ProdukCarousel(
                          key: _produkListKey,
                          cardType: "umkm",
                          id: "",
                          showDeletedProducts:
                              false, // Hanya tampilkan produk yang tidak dihapus
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}
