import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class profileSeller extends StatelessWidget {
  const profileSeller({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
              child:Container(
         margin: EdgeInsets.only(
          left: 20, right: 20, top: context.getHeight(100), bottom: 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.green),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Profil Toko",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Poppins",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
               SizedBox(height: context.getHeight(1)),
              Column(
                children: [
                  Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                              BoxShadow(
                              color: Colors.grey[200]!,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.pinkAccent,
                          child: Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: context.getHeight(11)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:  Text(
                      "Ubah Foto",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                Container(
                  height: context.getHeight(575),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
_buildInfoCard(
                title: "Informasi Toko",
                icon: Icons.edit,
                onEditTap: () {
                  print("Edit Toko Pressed");
                },
                content: const [
                  _InfoRow(label: "Nama", divider: ": ", value: "Rooftop Farming Center"),
                  _InfoRow(label: "No Handphone", divider: ": " , value: "0822660957432"),
                  _InfoRow(
                    label: "Alamat Toko",
                    divider: ": ",
                    value:
                        "Jl. Ketintang No.156, Gayungan, Surabaya, Jawa Timur 60231",
                  ),
                  _InfoRow(
                    label: "Deskripsi Toko",
                    divider: ": ",
                    value:
                        "Menjual berbagai macam sayur, buah, dan hasil ternak di Rooftop Farming Center",
                  ),
                ],
              ),
              _buildInfoCard(
                title: "Informasi Rekening",
                icon: Icons.edit,
                onEditTap: () {
                  print("Edit Rekening Pressed");
                },
                content: const [
                  _InfoRow(label: "Nama Rekening", divider: ": ", value: "Abriel Karisma"),
                  _InfoRow(label: "Jenis Rekening", divider: ": ", value: "Mandiri"),
                  _InfoRow(label: "Nomor Rekening", divider: ": ", value: "653620003"),
                ],
              ),
                Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _modalLogout(context);
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                    alignment: Alignment.center,
                    child: Text(
                      "LOGOUT",
                      style: TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                    Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(Icons.logout, color: Colors.red),
                    ),
                    ),
                  ],
                  ),
                ),
                ),
                    ],
                  ),
                ),
              ],
            )
          ]),
        ),
            ),      
            ],          
            ));
  }
   Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required VoidCallback onEditTap,
    required List<Widget> content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEditTap,
                child: Icon(icon, size: 18, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...content,
        ],
      ),
    );
  }
}

void _modalLogout(BuildContext context) {
  showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          backgroundColor: Colors.white,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Apakah kamu yakin akan keluar dari akun?',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 26,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEAEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/auth',
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text(
                        'Ya, Logout',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Color(0xFF979797),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
}


class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String divider;

  const _InfoRow({required this.label, required this.value, required this.divider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            child: Text(
              "$label",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
           Text(
              "$divider",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}