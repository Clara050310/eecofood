import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

import 'dart:convert';
import 'dart:typed_data';

class TelaPagamento extends StatefulWidget {
  final double total;

  const TelaPagamento({Key? key, required this.total}) : super(key: key);

  @override
  _TelaPagamentoState createState() => _TelaPagamentoState();
}

class _TelaPagamentoState extends State<TelaPagamento> {
  String? qrCodeCopiaCola;
  Uint8List? qrCodeImage;
  String status = 'aguardando';
  String? pagamentoId;
  
  get http => null;

  Future<void> gerarPix() async {
    setState(() {
      status = 'gerando';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/criar-pix'), // use seu IP local se for celular físico
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'valor': 29.90,
          'descricao': 'Cesta Eco Food',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        pagamentoId = data['id'];
        qrCodeCopiaCola = data['qrCodeCopiaCola'];
        qrCodeImage = base64Decode(data['qrCodeBase64']);
        status = 'gerado';
        _verificarStatus();
      } else {
        status = 'erro';
      }
      setState(() {});
    } catch (e) {
      print('Erro: $e');
      setState(() => status = 'erro');
    }
  }

  // 🔁 Verifica a cada 5 segundos se o pagamento foi aprovado
  Future<void> _verificarStatus() async {
    Future.delayed(Duration(seconds: 5), () async {
      if (pagamentoId == null) return;

      final response = await http.get(
        Uri.parse('https://api.mercadopago.com/v1/payments/$pagamentoId'),
        headers: {
          'Authorization':
              'Bearer APP_USR-xxxxxxxxxxxx' // ⚠️ coloque seu access_token aqui temporariamente (ou crie endpoint seguro no backend)
        },
      );

      final data = json.decode(response.body);
      if (data['status'] == 'approved') {
        setState(() => status = 'pago');
      } else if (status != 'pago') {
        _verificarStatus(); // tenta novamente até o pagamento ser aprovado
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Pagamento via Pix'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Builder(
            builder: (context) {
              if (status == 'aguardando') {
                return ElevatedButton(
                  onPressed: gerarPix,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Gerar Pix'),
                );
              } else if (status == 'gerando') {
                return CircularProgressIndicator();
              } else if (status == 'gerado') {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Escaneie o QR Code abaixo para pagar:'),
                    SizedBox(height: 20),
                    Image.memory(qrCodeImage!, width: 250),
                    SizedBox(height: 20),
                    SelectableText(qrCodeCopiaCola ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    SizedBox(height: 20),
                    Text('Aguardando pagamento...'),
                  ],
                );
              } else if (status == 'pago') {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 100),
                    SizedBox(height: 20),
                    Text('Pagamento aprovado!'),
                  ],
                );
              } else {
                return Text('Erro ao gerar Pix');
              }
            },
          ),
        ),
      ),
    );
  }
}
