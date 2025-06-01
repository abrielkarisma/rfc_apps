import 'package:flutter/material.dart';
import 'package:rfc_apps/service/midtrans.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String orderId;

  const PaymentWebViewPage(
      {super.key, required this.paymentUrl, required this.orderId});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    print(widget.orderId);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onNavigationRequest: (request) {
          if (request.url.contains("transaction_status=settlement")) {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);

            return NavigationDecision.prevent;
          } else if (request.url
              .contains("transaction_status=pending&action=back")) {
            Navigator.pop(context);
          }
          return NavigationDecision.navigate;
        }),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran",
            style: TextStyle(
                fontFamily: "poppins",
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
