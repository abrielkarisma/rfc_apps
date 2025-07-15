import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/utils/toastHelper.dart';

class QuantityCounter extends StatefulWidget {
  final String satuan;
  final String stok;
  final ValueChanged<int>? onQuantityChanged;
  const QuantityCounter({
    Key? key,
    required this.satuan,
    required this.stok,
    this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<QuantityCounter> {
  late int jumlahProduk;

  @override
  void initState() {
    super.initState();
    jumlahProduk = widget.satuan == "gr" ? 100 : 1;
    
    if (widget.onQuantityChanged != null) {
      widget.onQuantityChanged!(jumlahProduk);
    }
  }

  void increment() {
    int stockInt = int.tryParse(widget.stok) ?? 0;
    int oldValue = jumlahProduk;

    setState(() {
      if (widget.satuan == "gr") {
        if (jumlahProduk + 100 <= stockInt) {
          jumlahProduk += 100;
        } else {
          jumlahProduk = stockInt;
          ToastHelper.showInfoToast(context, 'Stok tidak mencukupi');
        }
      } else if (widget.satuan == "kg") {
        if (jumlahProduk + 1 <= stockInt) {
          jumlahProduk += 1;
        } else {
          jumlahProduk = stockInt;
          ToastHelper.showInfoToast(context, 'Stok tidak mencukupi');
        }
      } else {
        if (jumlahProduk + 1 <= stockInt) {
          jumlahProduk++;
        } else {
          ToastHelper.showInfoToast(context, 'Stok tidak mencukupi');
        }
      }
    });

    if (oldValue != jumlahProduk && widget.onQuantityChanged != null) {
      widget.onQuantityChanged!(jumlahProduk);
    }
  }

  void decrement() {
    int oldValue = jumlahProduk;

    setState(() {
      if (widget.satuan == "gr") {
        if (jumlahProduk > 100) jumlahProduk -= 100;
      } else if (widget.satuan == "kg") {
        if (jumlahProduk > 1) jumlahProduk -= 1;
      } else {
        if (jumlahProduk > 1) jumlahProduk--;
      }
    });

    
    if (oldValue != jumlahProduk && widget.onQuantityChanged != null) {
      widget.onQuantityChanged!(jumlahProduk);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.getWidth(200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: context.getWidth(40),
            height: context.getHeight(40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.remove, color: Colors.black),
                onPressed: decrement,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                '$jumlahProduk',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              Text(
                '${widget.satuan}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            width: context.getWidth(40),
            height: context.getHeight(40),
            decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).primaryColor, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                onPressed: increment,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
