import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/artikel.dart';
import 'package:intl/intl.dart';

class ListArtikel extends StatefulWidget {
  final List<Artikel> aritikels;

  ListArtikel({required this.aritikels});

  @override
  State<ListArtikel> createState() => _ListArtikelState();
}

class _ListArtikelState extends State<ListArtikel> {
  @override
  Widget build(BuildContext context) {
    widget.aritikels.sort((a, b) =>
        DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.aritikels.length,
      itemBuilder: (context, index) {
        Artikel item = widget.aritikels[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: context.getWidth(118),
                  height: context.getHeight(118),
                  child: Image.network(
                    item.images,
                    width: context.getWidth(118),
                    height: context.getHeight(118),
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: context.getWidth(10))),
                Container(
                  width: context.getWidth(246),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Text(
                          DateFormat('dd MMMM yyyy')
                              .format(DateTime.parse(item.createdAt)),
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 8,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: context.getHeight(34),
                        child: Text(
                          item.title,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        height: context.getHeight(43),
                        width: double.infinity,
                        child: Text(
                          item.description,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                      Container(
                        height: context.getHeight(24),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(),
                            GestureDetector(
                              onTap: () {
                                print(item.id);
                              },
                              child: Icon(
                                LineIcons.arrowRight,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
