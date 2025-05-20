import 'package:flutter/material.dart';
import 'package:rfc_apps/model/toko.dart';
import 'package:rfc_apps/service/toko.dart';
import 'package:rfc_apps/widget/toko_card.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer import

class TokoListWidget extends StatefulWidget {
  const TokoListWidget({Key? key}) : super(key: key);

  @override
  State<TokoListWidget> createState() => _TokoListWidgetState();
}

class _TokoListWidgetState extends State<TokoListWidget> {
  late Future<List<TokoData>> _tokoFuture;
  @override
  void initState() {
    super.initState();
    _tokoFuture = _fetchTokoData();
  }

  Future<List<TokoData>> _fetchTokoData() async {
    return await tokoService().getToko();
  }

  // Add shimmer loading widget for toko list
  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 5, // Show 5 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                // Circle for toko logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                // Toko name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 140,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 80,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TokoData>>(
      future: _tokoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading(); // Use shimmer loading instead of CircularProgressIndicator
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 69,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada toko yang tersedia'));
        } else {
          final tokoList = snapshot.data!;
          return Container(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: tokoList.length,
              itemBuilder: (context, index) {
                final toko = tokoList[index];
                return TokoItem(
                  nama: toko.nama,
                  logoToko: toko.logoToko,
                  idToko: toko.id,
                );
              },
            ),
          );
        }
      },
    );
  }
}
