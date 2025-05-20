import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class TokoItem extends StatefulWidget {
  final String nama;
  final String logoToko;
  final String idToko;

  const TokoItem(
      {Key? key,
      required this.nama,
      required this.logoToko,
      required this.idToko})
      : super(key: key);

  @override
  State<TokoItem> createState() => _TokoItemState();
}

class _TokoItemState extends State<TokoItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Container(
        color: Colors.white,
        width: context.getWidth(400),
        height: context.getHeight(80),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: context.getHeight(80),
                height: context.getHeight(80),
                child: Image.network(
                  widget.logoToko,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.store, size: 30),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.nama,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Color(0XFF4CAD73)),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/toko_detail',
                  arguments: widget.idToko,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
