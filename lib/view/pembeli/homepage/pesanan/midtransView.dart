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
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains("transaction_status=settlement")) {
              _handleTransactionInfo();
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },           
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: WebViewWidget(controller: _controller),
    );
  }

  Future<void> _handleTransactionInfo() async {
    final response =
        await MidtransService().getTransactionStatus(widget.orderId);
    if (response["message"] == "Status transaksi berhasil diambil") {
      print(response);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mendapatkan status transaksi')),
      );
    }
  }
}
