import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/pesanan.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';
import 'package:rfc_apps/widget/badge_status.dart';

class homeSeller extends StatefulWidget {
  const homeSeller({super.key});

  @override
  State<homeSeller> createState() => _homeSellerState();
}

class _homeSellerState extends State<homeSeller> {
  String $name = "";
  String $avatarUrl = "";
  String $tokoStatus = "";
  bool $unlockFeature = false;
  int $typeUnlock = 2;
  bool $isAccepted = true;
  bool $tokoRegistered = false;
  Timer? _tokoDataTimer;
  Timer? _pesananTimer;
  Timer? _saldoTimer;
  String $tokoId = "";
  int _pesananMasukCount = 0;
  int _menungguDiambilCount = 0;
  int _selesaiCount = 0;
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> filteredData = [];
  int totalPendapatan = 0;
  final SaldoService _saldoService = SaldoService();
  late Future<Map<String, dynamic>> _saldoFuture;
  String $idUser = "";
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();

    _saldoFuture = _saldoService.getMySaldoByIdUser($idUser);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _getIdUser();

      if ($idUser.isNotEmpty) {
        await _getTokoDatabyId();

        if ($tokoId.isNotEmpty) {
          await getPesananToko();
        }
      }

      _fetchSaldo();

      _startTimers();
    } catch (e) {
      print("Error initializing data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startTimers() {
    _tokoDataTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getTokoDatabyId();
    });

    _pesananTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getPesananToko();
    });

    _saldoTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchSaldo();
    });
  }

  Future<void> _getIdUser() async {
    final idUser = FlutterSecureStorage();
    final id = await idUser.read(key: "id");
    if (mounted) {
      setState(() {
        $idUser = id ?? "";
      });
    }
  }

  void _fetchSaldo() {
    if (mounted) {
      setState(() {
        _saldoFuture = _saldoService.getMySaldoByIdUser($idUser);
      });
    }
  }

  Future<void> _refreshSellerHome() async {
    try {
      await _getIdUser();
      if ($idUser.isNotEmpty) {
        await _getTokoDatabyId();
        if ($tokoId.isNotEmpty) {
          await getPesananToko();
        }
      }
      _fetchSaldo();
      print("User ID: ${$idUser}");
    } catch (e) {
      print("Error refreshing data: $e");
    }
  }

  Future<void> _getTokoDatabyId() async {
    if ($idUser.isEmpty) return;

    try {
      final toko = await tokoService().getTokoByIdUser($idUser);

      if (!mounted) return;

      if (toko.message == "Toko not found for this user") {
        setState(() {
          $tokoRegistered = false;
        });
        return;
      }

      if (toko.message == "Successfully retrieved toko data for user" &&
          toko.data.isNotEmpty) {
        final tokoData = toko.data[0];
        final String name = tokoData.nama;
        final String tokoAvatar = tokoData.logoToko;
        final String tokoStatus = tokoData.tokoStatus;
        final String tokoId = tokoData.id;

        setState(() {
          $tokoRegistered = true;
          $name = name;
          $avatarUrl = tokoAvatar;
          $tokoStatus = tokoStatus;
          $tokoId = tokoId;

          switch (tokoStatus) {
            case "active":
              $typeUnlock = 1;
              $isAccepted = true;
              break;
            case "request":
              $isAccepted = false;
              $typeUnlock = 2;
              break;
            case "reject":
              $isAccepted = false;
              $typeUnlock = 3;
              break;
            case "delete":
              $isAccepted = false;
              $typeUnlock = 4;
              break;
            default:
              $isAccepted = false;
              $unlockFeature = false;
          }
        });
      }
    } catch (e) {
      print("Error getting toko data: $e");
      if (mounted) {
        setState(() {
          $tokoRegistered = false;
        });
      }
    }
  }

  Future<void> getPesananToko() async {
    if ($tokoId.isEmpty) return;

    try {
      final Map<String, dynamic> pesananResponse =
          await PesananService().getPesananByTokoId($tokoId);

      if (!mounted) return;

      if (pesananResponse['message'] ==
              "Berhasil mengambil daftar pesanan untuk toko" &&
          pesananResponse['data'] is List) {
        int pending = 0;
        int accepted = 0;
        int completed = 0;

        for (var order in pesananResponse['data']) {
          if (order is Map<String, dynamic> &&
              order['MidtransOrder'] is Map<String, dynamic> &&
              order['MidtransOrder']['transaction_status'] == "settlement") {
            final orderStatus = order['status'];
            if (orderStatus == "menunggu") {
              pending++;
            } else if (orderStatus == "diterima") {
              accepted++;
            } else if (orderStatus == "selesai") {
              completed++;
            } else if (orderStatus == "ditolak") {
              completed++;
            }
          }
        }

        setState(() {
          _pesananMasukCount = pending;
          _menungguDiambilCount = accepted;
          _selesaiCount = completed;
        });
      } else {
        setState(() {
          _pesananMasukCount = 0;
          _menungguDiambilCount = 0;
          _selesaiCount = 0;
        });
      }
    } catch (e) {
      print("Error getting pesanan data: $e");
      if (mounted) {
        setState(() {
          _pesananMasukCount = 0;
          _menungguDiambilCount = 0;
          _selesaiCount = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _tokoDataTimer?.cancel();
    _pesananTimer?.cancel();
    _saldoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Rooftop Farming Center.",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: "Monserrat_Alternates",
                  fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: RefreshIndicator(
          onRefresh: _refreshSellerHome,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/homebackground.png',
                  fit: BoxFit.fill,
                ),
              ),
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  margin: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: context.getHeight(100),
                      bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dashboard Penjual",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: context.getHeight(47)),
                      if (_isLoading)
                        Container(
                          height: context.getHeight(60),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                width: context.getWidth(50),
                                height: context.getHeight(50),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 16,
                                        width: context.getWidth(120),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 12,
                                        width: context.getWidth(80),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          height: context.getHeight(60),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: $tokoRegistered
                              ? Container(
                                  child: Row(
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          width: context.getWidth(50),
                                          height: context.getHeight(50),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: ShimmerImage(
                                              imageUrl: $avatarUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                      Container(
                                          width: context.getWidth(140),
                                          height: double.infinity,
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            $name.length > 15
                                                ? '${$name.substring(0, 12)}...'
                                                : $name,
                                            style: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                      Container(
                                        width: context.getWidth(100),
                                        child: StatusBadge(status: $tokoStatus),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        child: GestureDetector(
                                          child: Image.asset(
                                              "assets/images/menuIcon/gear.png",
                                              width: 32,
                                              height: 32),
                                          onTap: () async {
                                            final result =
                                                await Navigator.pushNamed(
                                              context,
                                              "/profil_seller",
                                              arguments:
                                                  $idUser, // Kirim ID user sebagai arguments
                                            );
                                            if (result == 'refresh') {
                                              _getTokoDatabyId();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  child: Center(
                                      child: TextButton(
                                    onPressed: () async {
                                      final result = await Navigator.pushNamed(
                                          context, "/toko_register");
                                      if (result == 'refresh') {
                                        _getTokoDatabyId();
                                      }
                                    },
                                    child: Text(
                                      "Isi data tokomu disini",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )),
                                ),
                        ),
                      $tokoRegistered == false
                          ? const SizedBox(height: 20)
                          : SizedBox(height: context.getHeight(33)),
                      if (!_isLoading)
                        $tokoRegistered == true
                            ? Container(
                                child: $isAccepted == true
                                    ? Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: Colors.grey[200]!),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12
                                                        .withOpacity(0.05),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Status Pesanan",
                                                        style: TextStyle(
                                                          fontFamily: "Poppins",
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              "/daftar_pesanan",
                                                              arguments:
                                                                  $tokoId);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Daftar Pesanan",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            Icon(
                                                                Icons
                                                                    .arrow_forward_ios_rounded,
                                                                size: 12,
                                                                color: Colors
                                                                    .grey),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      _buildOrderStatusBox(
                                                          _pesananMasukCount
                                                              .toString(),
                                                          "Pesanan Masuk"),
                                                      _buildOrderStatusBox(
                                                          _menungguDiambilCount
                                                              .toString(),
                                                          "Menunggu Diambil"),
                                                      _buildOrderStatusBox(
                                                          _selesaiCount
                                                              .toString(),
                                                          "Selesai"),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: context.getHeight(33)),
                                            _buildSimpleCard(
                                              title: "Kelola Produk Anda",
                                              icon: Icons.inventory_2,
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, "/kelola_produk",
                                                    arguments:
                                                        $idUser); // Kirim ID user sebagai arguments
                                              },
                                            ),
                                            SizedBox(
                                                height: context.getHeight(33)),
                                            _buildSimpleCard(
                                              title: "Laporan Penjualan",
                                              icon: Icons.bar_chart,
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  "/penjualan",
                                                  arguments: $tokoId,
                                                );
                                              },
                                            ),
                                            SizedBox(
                                                height: context.getHeight(33)),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, "/saldo");
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                      color: Colors.grey[200]!),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12
                                                          .withOpacity(0.05),
                                                      blurRadius: 5,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          "Saldo Toko",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Poppins",
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: FutureBuilder<
                                                          Map<String, dynamic>>(
                                                        future: _saldoFuture,
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Text(
                                                              "Memuat saldo...",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            );
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return Text(
                                                              "Gagal memuat saldo",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .red[400],
                                                              ),
                                                            );
                                                          } else if (snapshot
                                                                  .hasData &&
                                                              snapshot.data !=
                                                                  null) {
                                                            final saldoDataMap =
                                                                snapshot.data!;
                                                            final dynamic
                                                                saldoValue =
                                                                saldoDataMap[
                                                                    'saldoTersedia'];
                                                            double
                                                                saldoNumerik =
                                                                0.0;

                                                            if (saldoValue
                                                                is String) {
                                                              saldoNumerik =
                                                                  double.tryParse(
                                                                          saldoValue) ??
                                                                      0.0;
                                                            } else if (saldoValue
                                                                is num) {
                                                              saldoNumerik =
                                                                  saldoValue
                                                                      .toDouble();
                                                            }
                                                            return Text(
                                                              Formatter()
                                                                  .formatRupiah(
                                                                      saldoNumerik),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            );
                                                          } else {
                                                            return Text(
                                                              "Saldo tidak tersedia",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .grey[500],
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    const Divider(),
                                                    ListTile(
                                                      leading: Icon(
                                                          Icons
                                                              .account_balance_wallet,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                      title: const Text(
                                                        "Kelola Saldo Toko",
                                                        style: TextStyle(
                                                          fontFamily: "Poppins",
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      trailing: const Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        size: 16,
                                                        color: Colors.grey,
                                                      ),
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context, "/saldo");
                                                      },
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      dense: true,
                                                      minLeadingWidth: 0,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : $isAccepted == false
                                        ? Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: $typeUnlock == 2
                                                        ? Colors.orange
                                                            .withOpacity(0.2)
                                                        : $typeUnlock == 3
                                                            ? Colors.red
                                                                .withOpacity(
                                                                    0.2)
                                                            : $typeUnlock == 4
                                                                ? Colors.black
                                                                    .withOpacity(
                                                                        0.2)
                                                                : Colors
                                                                    .transparent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Image.asset(
                                                      $typeUnlock == 2
                                                          ? 'assets/images/menuIcon/review.png'
                                                          : $typeUnlock == 3
                                                              ? 'assets/images/menuIcon/rejected.png'
                                                              : $typeUnlock == 4
                                                                  ? 'assets/images/menuIcon/banned.png'
                                                                  : "",
                                                      width: 60,
                                                      height: 60,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Icon(
                                                        $typeUnlock == 2
                                                            ? Icons
                                                                .hourglass_top
                                                            : $typeUnlock == 3
                                                                ? Icons.cancel
                                                                : Icons.block,
                                                        size: 60,
                                                        color: $typeUnlock == 2
                                                            ? Colors.orange
                                                            : $typeUnlock == 3
                                                                ? Colors.red
                                                                : $typeUnlock ==
                                                                        4
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Text(
                                                  $typeUnlock == 2
                                                      ? "Dalam Proses Review"
                                                      : $typeUnlock == 3
                                                          ? "Pendaftaran Ditolak"
                                                          : $typeUnlock == 4
                                                              ? "Akun Diblokir"
                                                              : "",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  $typeUnlock == 2
                                                      ? "Akun anda masih dalam proses review, Lengkapi informasi toko anda dan tunggu beberapa saat agar bisa digunakan."
                                                      : $typeUnlock == 3
                                                          ? "Pendaftaran toko anda ditolak. Silahkan periksa kembali data toko anda dan daftar menggunakan akun lain"
                                                          : $typeUnlock == 4
                                                              ? "Akun anda telah diblokir. Silahkan hubungi admin untuk informasi lebih lanjut."
                                                              : "",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    height: 1.5,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 24),
                                                Container(
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                  ),
                                                  child:
                                                      LinearProgressIndicator(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                              ],
                                            ),
                                          )
                                        : Container(),
                              )
                            : Container(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildOrderStatusBox(String number, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }

  Widget _buildSimpleCard(
      {required String title, required VoidCallback onTap, IconData? icon}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
