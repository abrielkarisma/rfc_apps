class Store {
  final String id;
  final String nama;
  final String logoToko;
  final String alamat;

  Store(
      {required this.id,
      required this.nama,
      required this.logoToko,
      required this.alamat});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      nama: json['nama'],
      logoToko: json['logoToko'],
      alamat: json['alamat'],
    );
  }
}

class Product {
  final String id;
  final String nama;
  final String satuan;
  final int harga;
  final String gambar;
  final Store toko;

  Product({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.gambar,
    required this.toko,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nama: json['nama'],
      satuan: json['satuan'],
      harga: json['harga'],
      gambar: json['gambar'],
      toko: Store.fromJson(json['Toko']),
    );
  }
}

class CartItem {
  final String id;
  int jumlah;
  final Product produk;

  CartItem({required this.id, required this.jumlah, required this.produk});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      jumlah: json['jumlah'],
      produk: Product.fromJson(json['Produk']),
    );
  }
}
