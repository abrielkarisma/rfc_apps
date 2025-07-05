import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/pesanan.dart';
import 'package:rfc_apps/view/penjual/pesanan/detail_pesanan.dart';
import 'package:rfc_apps/widget/order_list_card.dart';
import 'package:rfc_apps/widget/tab_menu.dart';

class DaftarPesanan extends StatefulWidget {
  const DaftarPesanan({super.key, required this.tokoId});
  final String tokoId;
  @override
  State<DaftarPesanan> createState() => _DaftarPesananState();
}

class _DaftarPesananState extends State<DaftarPesanan> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _tabs = ['Pesanan Masuk', 'Menunggu Diambil', 'Selesai'];
  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _pesananMasuk = [];
  List<Map<String, dynamic>> _menungguDiambil = [];
  List<Map<String, dynamic>> _selesai = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    if (widget.tokoId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Toko ID tidak tersedia. Harap kembali ke halaman utama.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final PesananService pesananService = PesananService();
      final Map<String, dynamic> fullResponse =
          await pesananService.getPesananByTokoId(widget.tokoId);

      if (fullResponse['message'] ==
              "Berhasil mengambil daftar pesanan untuk toko" &&
          fullResponse['data'] != null) {
        List<dynamic> ordersRaw = fullResponse['data'];
        List<Map<String, dynamic>> fetchedOrders = [];

        for (var orderRaw in ordersRaw) {
          final Map<String, dynamic> order = orderRaw as Map<String, dynamic>;
          final Map<String, dynamic>? midtransOrder =
              order['MidtransOrder'] as Map<String, dynamic>?;
          final String? transactionStatus =
              midtransOrder?['transaction_status'] as String?;

          if (transactionStatus == "settlement") {
            fetchedOrders.add(order);
          }
        }

        _filterOrders(fetchedOrders);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              fullResponse['message'] ?? 'Gagal mengambil data pesanan.';
        });
      }
    } catch (e) {
      print('Error fetching orders in DaftarPesanan: $e');
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Terjadi kesalahan saat memuat pesanan. Silakan coba lagi.';
      });
    }
  }

  Future<void> _refreshOrders() async {
    await _fetchOrders();
  }

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _filterOrders(List<Map<String, dynamic>> allOrders) {
    List<Map<String, dynamic>> pesananMasukTemp = [];
    List<Map<String, dynamic>> menungguDiambilTemp = [];
    List<Map<String, dynamic>> selesaiTemp = [];

    for (var order in allOrders) {
      final String? orderStatus = order['status'] as String?;
      switch (orderStatus) {
        case "menunggu":
          pesananMasukTemp.add(order);
          break;
        case "diterima":
          menungguDiambilTemp.add(order);
          break;
        case "selesai":
          selesaiTemp.add(order);
          break;
        case "ditolak":
          selesaiTemp.add(order);
          break;
      }
    }

    setState(() {
      _allOrders = allOrders;
      _pesananMasuk = pesananMasukTemp;
      _menungguDiambil = menungguDiambilTemp;
      _selesai = selesaiTemp;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rooftop Farming Center.",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Monserrat_Alternates",
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
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
          Container(
              child: Container(
                  margin: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: context.getHeight(100),
                      bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Daftar Pesanan",
                          style: TextStyle(
                              fontFamily: "poppins",
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.start),
                      const SizedBox(height: 50),
                      TabMenu(
                        tabs: _tabs,
                        selectedIndex: _selectedIndex,
                        pageController: _pageController,
                        onTabChanged: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshOrders,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            children: [
                              _buildOrderList(_pesananMasuk),
                              _buildOrderList(_menungguDiambil),
                              _buildOrderList(_selesai),
                            ],
                          ),
                        ),
                      )
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          "Belum ada pesanan.",
          style: TextStyle(
            fontFamily: "poppins",
            fontSize: 14,
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderListCard(
          order: order,
          onTap: () {
            final result = Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPesanan(order: order),
              ),
            );
            if (result == 'refresh') {
              _fetchOrders();
            }
          },
        );
      },
    );
  }
}
