import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/token.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/service/user.dart';
import 'package:rfc_apps/utils/ShimmerImage.dart';
import 'package:rfc_apps/view/penjual/sellerStoreReg.dart';
import 'package:rfc_apps/widget/badge_status.dart';
import 'package:shimmer/shimmer.dart';

class homeSeller extends StatefulWidget {
  const homeSeller({super.key});

  @override
  State<homeSeller> createState() => _homeSellerState();
}

String $name = "";
String $avatarUrl = "";
String $tokoStatus = "";
bool $unlockFeature = false;
int $typeUnlock = 2;
bool $isAccepted = true;
bool $tokoRegistered = false;
late Timer _timer;

class _homeSellerState extends State<homeSeller> {
  @override
  void initState() {
    super.initState();
    _getTokoDatabyId();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _getTokoDatabyId();
    });
  }

  void _getTokoDatabyId() async {
    try {
      final toko = await tokoService().getTokoByUserId();
      print(toko.message);
      if (toko.message == "Toko not found for this user") {
        setState(() {
          $tokoRegistered = false;
        });
      }
      if (toko.message == "Successfully retrieved toko data for user") {
        setState(() {
          $tokoRegistered = true;
        });
      }
      final String name = toko.data!.nama ?? "";
      final String tokoAvatar = toko.data!.logoToko ?? "";
      final String tokoStatus = toko.data!.tokoStatus ?? "";
      if (toko.data!.tokoStatus == "active") {
        setState(() {
          $typeUnlock = 1;
          $isAccepted = true;
        });
      } else if (toko.data!.tokoStatus == "request") {
        setState(() {
          $isAccepted = false;
          $typeUnlock = 2;
        });
      } else if (toko.data!.tokoStatus == "reject") {
        setState(() {
          $isAccepted = false;
          $typeUnlock = 3;
        });
      } else if (toko.data!.tokoStatus == "delete") {
        setState(() {
          $isAccepted = false;
          $typeUnlock = 4;
        });
      } else {
        setState(() {
          $isAccepted = false;
          $unlockFeature = false;
        });
      }
      setState(() {
        $name = name;
        $avatarUrl = tokoAvatar;
        $tokoStatus = tokoStatus;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer.cancel();
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
            margin: EdgeInsets.only(
                left: 20, right: 20, top: context.getHeight(100), bottom: 20),
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
                                  margin:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  width: context.getWidth(50),
                                  height: context.getHeight(50),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
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
                                  margin: const EdgeInsets.only(left: 8),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    $name.length > 15
                                        ? '${$name.substring(0, 15)}...'
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
                                    final result = await Navigator.pushNamed(
                                      context,
                                      "/profil_seller",
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
                SizedBox(height: context.getHeight(33)),
                $isAccepted == true
                    ? Container(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Status Pesanan",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, "/daftar_pesanan");
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              "Daftar Pesanan",
                                              style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 12,
                                                color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildOrderStatusBox(
                                          "2", "Pesanan Masuk"),
                                      _buildOrderStatusBox(
                                          "1", "Menunggu Diambil"),
                                      _buildOrderStatusBox("3", "Selesai"),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: context.getHeight(33)),
                            _buildSimpleCard(
                              title: "Kelola Produk Anda",
                              onTap: () {
                                Navigator.pushNamed(context, "/kelola_produk");
                              },
                            ),
                            SizedBox(height: context.getHeight(33)),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "Total Saldo",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, "/detail_produk");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                        ),
                                        child: const Text(
                                          "Tarik Dana",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Rp. 100,000",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.history,
                                        color: Colors.green),
                                    title: const Text(
                                      "Riwayat Penjualan",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    onTap: () {
                                      print("Riwayat Penjualan clicked");
                                    },
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    minLeadingWidth: 0,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : $isAccepted == false
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Review Icon
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: $typeUnlock == 2
                                        ? Colors.orange.withOpacity(0.2)
                                        : $typeUnlock == 3
                                            ? Colors.red.withOpacity(0.2)
                                            : $typeUnlock == 4
                                                ? Colors.black.withOpacity(0.2)
                                                : Colors.transparent,
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
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        $typeUnlock == 2
                                            ? Icons.hourglass_top
                                            : $typeUnlock == 3
                                                ? Icons.cancel
                                                : Icons.block,
                                        size: 60,
                                        color: $typeUnlock == 2
                                            ? Colors.orange
                                            : $typeUnlock == 3
                                                ? Colors.red
                                                : $typeUnlock == 4
                                                    ? Colors.black
                                                    : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Title
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
                                // Message
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
                                // Progress Indicator
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
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
      {required String title, required VoidCallback onTap}) {
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
            Text(
              title,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
