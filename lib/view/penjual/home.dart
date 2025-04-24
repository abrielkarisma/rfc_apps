import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class homeSeller extends StatelessWidget {
  const homeSeller({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    const Text(
                      "RFC.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: "Poppins",
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Rooftop Farming Center",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      child: Image.asset("assets/images/menuIcon/gear.png",
                          width: 32, height: 32),
                      onTap: () {
                        Navigator.pushNamed(context, "/profil_seller");
                      },
                    ),
                  ],
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children:  [
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
                            Navigator.pushNamed(context, "/daftar_pesanan");
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
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 12, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOrderStatusBox("2", "Pesanan Masuk"),
                        _buildOrderStatusBox("1", "Menunggu Diambil"),
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
                  print("Kelola Produk Anda clicked");
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
                            print("Tarik Dana clicked");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                      leading: const Icon(Icons.history, color: Colors.green),
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

  Widget _buildSimpleCard({required String title, required VoidCallback onTap}) {
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