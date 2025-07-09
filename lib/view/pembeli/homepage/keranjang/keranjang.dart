import 'package:flutter/material.dart';
import 'package:rfc_apps/model/keranjang.dart';
import 'package:rfc_apps/service/keranjang.dart';
import 'package:rfc_apps/service/produk.dart';
import 'package:rfc_apps/utils/rupiahFormatter.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:rfc_apps/view/pembeli/homepage/pesanan/prosesPesanan.dart';

class Keranjang extends StatefulWidget {
  const Keranjang({super.key});

  @override
  State<Keranjang> createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  late Future<List<CartItem>> futureKeranjang;
  Map<String, bool> selectedToko = {};
  Map<CartItem, bool> selectedItems = {};
  Map<String, List<CartItem>> grouped = {};

  @override
  void initState() {
    super.initState();
    futureKeranjang = KeranjangService().getAllKeranjang();
  }

  Future<void> _refreshKeranjang() async {
    setState(() {
      futureKeranjang = KeranjangService().getAllKeranjang();
    });
  }

  Map<String, List<CartItem>> groupByToko(List<CartItem> items) {
    Map<String, List<CartItem>> result = {};
    for (var item in items) {
      final tokoId = item.produk.toko.nama;
      result.putIfAbsent(tokoId, () => []);
      result[tokoId]!.add(item);
    }
    return result;
  }

  void handleTokoCheck(String tokoNama, List<CartItem> items, bool? checked) {
    setState(() {
      selectedToko.updateAll((key, value) => false);
      selectedItems.updateAll((key, value) => false);

      if (checked ?? false) {
        selectedToko[tokoNama] = true;
        for (var item in items) {
          selectedItems[item] = true;
        }
      } else {
        selectedToko[tokoNama] = false;
        for (var item in items) {
          selectedItems[item] = false;
        }
      }
    });
  }

  void handleItemCheck(String tokoNama, CartItem item, bool? checked) {
    setState(() {
      if (checked == true) {
        for (var otherToko in selectedToko.keys) {
          if (otherToko != tokoNama) {
            selectedToko[otherToko] = false;
            selectedItems.keys
                .where((e) => e.produk.toko.nama == otherToko)
                .forEach((i) => selectedItems[i] = false);
          }
        }
      }

      selectedItems[item] = checked ?? false;

      final itemsInToko = selectedItems.keys
          .where((e) => e.produk.toko.nama == tokoNama)
          .toList();

      bool allChecked = itemsInToko.every((i) => selectedItems[i] == true);
      selectedToko[tokoNama] = allChecked;
    });
  }

  void _handleCheckout(BuildContext context) async {
    final selected = selectedItems.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    if (selected.isEmpty) {
      ToastHelper.showErrorToast(context, "Pilih produk terlebih dahulu.");
      return;
    }

    for (var item in selected) {
      try {
        final stockResponse =
            await ProdukService().getProdukStok(item.produk.id);
        final int stok = stockResponse['data']['stok'];
        if (item.jumlah > stok) {
          ToastHelper.showErrorToast(context,
              "${item.produk.nama} melebihi stok yang tersedia: $stok");
          return;
        }
      } catch (e) {
        ToastHelper.showErrorToast(context, "Gagal cek stok: $e");
        return;
      }
    }

    final callback = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProsesPesananPage(items: selected),
      ),
    );
    if (callback == "refresh") {
      setState(() {
        futureKeranjang = KeranjangService().getAllKeranjang();
      });
    }
  }

  void _showEditJumlahDialog(CartItem item) {
    final controller = TextEditingController(text: item.jumlah.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ubah Jumlah",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'poppins',
              color: Theme.of(context).primaryColor,
              fontSize: 18,
            )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: const TextStyle(fontFamily: 'poppins', fontSize: 14),
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: ProdukService().getProdukStok(item.produk.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Memuat stok...");
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!['data'] == null) {
                  return const Text("Gagal memuat stok");
                }
                final stok = snapshot.data!['data']['stok'];
                return Text(
                  "Stok: $stok",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontFamily: 'poppins',
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal",
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                )),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final newJumlah = int.tryParse(controller.text);
              if (newJumlah == null || newJumlah < 1) return;

              try {
                final stockResponse =
                    await ProdukService().getProdukStok(item.produk.id);
                final int stock = stockResponse['data']['stok'];
                if (newJumlah > stock) {
                  ToastHelper.showErrorToast(
                      context, "Jumlah melebihi stok yang tersedia.");
                  return;
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal mendapatkan stok: $e")),
                );
                return;
              }

              Navigator.pop(context);

              try {
                await KeranjangService().updateKeranjang(item.id, newJumlah);
                setState(() {
                  futureKeranjang = KeranjangService().getAllKeranjang();
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal update jumlah: $e")),
                );
              }
            },
            child: Text("Simpan",
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: Colors.white,
                  fontSize: 12,
                )),
          ),
        ],
      ),
    );
  }

  void _handleDelete(CartItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Item"),
        content: const Text("Yakin ingin menghapus item ini dari keranjang?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await KeranjangService().deleteKeranjang(item.id);
        setState(() {
          futureKeranjang = KeranjangService().getAllKeranjang();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item berhasil dihapus")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal hapus item: $e")),
        );
      }
    }
  }

  int _getTotalHarga() {
    int total = 0;
    selectedItems.forEach((item, isSelected) {
      if (isSelected) {
        total += item.jumlah * item.produk.harga;
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Keranjang",
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: "poppins",
                fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshKeranjang,
        child: FutureBuilder<List<CartItem>>(
          future: futureKeranjang,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final items = snapshot.data!;
            grouped = groupByToko(items);

            for (var toko in grouped.keys) {
              selectedToko.putIfAbsent(toko, () => false);
              for (var item in grouped[toko]!) {
                selectedItems.putIfAbsent(item, () => false);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final tokoName = grouped.keys.elementAt(index);
                  final tokoItems = grouped[tokoName]!;
                  final toko = tokoItems.first.produk.toko;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: selectedToko[tokoName],
                            onChanged: (val) =>
                                handleTokoCheck(tokoName, tokoItems, val),
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    toko.logoToko,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    toko.nama,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          ...tokoItems.map((item) => CheckboxListTile(
                                value: selectedItems[item],
                                onChanged: (val) =>
                                    handleItemCheck(tokoName, item, val),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Row(
                                  children: [
                                    Image.network(item.produk.gambar,
                                        width: 40, height: 40),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.produk.nama,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500)),
                                          Text(
                                              "${item.jumlah} ${item.produk.satuan}",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Rp. ${Formatter.rupiah(item.produk.harga)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  size: 18),
                                              onPressed: () =>
                                                  _showEditJumlahDialog(item),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  size: 18, color: Colors.red),
                                              onPressed: () =>
                                                  _handleDelete(item),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleCheckout(context),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pesan Sekarang",
                      style: TextStyle(
                          fontFamily: 'poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text("Rp. ${Formatter.rupiah(_getTotalHarga())}",
                      style: const TextStyle(
                          fontFamily: 'poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
