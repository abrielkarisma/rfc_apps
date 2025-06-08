import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/widget/toko_list.dart';

class TokoUmkm extends StatefulWidget {
  const TokoUmkm({super.key});

  @override
  State<TokoUmkm> createState() => _TokoUmkmState();
}

class _TokoUmkmState extends State<TokoUmkm> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: context.getHeight(50),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari Toko',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey, width: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        SizedBox(height: context.getHeight(16)),
        Expanded(
          child: TokoListWidget(searchQuery: _searchQuery),
        )
      ],
    );
  }
}
