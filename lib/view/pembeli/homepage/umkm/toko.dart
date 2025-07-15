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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari toko yang kamu inginkan...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontFamily: "Inter",
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
