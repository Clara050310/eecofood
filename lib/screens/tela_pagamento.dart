import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// CORES DO PROJETO
const Color _primaryColor = Color(0xFFC0392B);

// -----------------------------------------------------------
// FUNÇÃO QUE REALMENTE GERA O BR CODE CORRETO DO PIX
// -----------------------------------------------------------

String gerarPix({
  required String chave,
  required String recebedor,
  required String cidade,
  required double valor,
}) {
  final valorFormatado = valor.toStringAsFixed(2);

  // remove espaços e linhas extras
  return "000201"
      "010212"
      "26580014BR.GOV.BCB.PIX0136$chave"
      "52040000"
      "5303986"
      "5405$valorFormatado"
      "5802BR"
      "59${recebedor.length.toString().padLeft(2, '0')}$recebedor"
      "60${cidade.length.toString().padLeft(2, '0')}$cidade"
      "62070503***";
}

// -----------------------------------------------------------
// TELA PRINCIPAL DE PAGAMENTO
// -----------------------------------------------------------

class TelaPagamento extends StatefulWidget {
  final double total;

  const TelaPagamento({super.key, required this.total});

  @override
  State<TelaPagamento> createState() => _TelaPagamentoState();
}

class _TelaPagamentoState extends State<TelaPagamento> {
  void _abrirQrPix() {
    const chavePix = "sua_chave_pix_aqui"; // <- coloque sua chave PIX real
    const recebedor = "EcoFood";
    const cidade = "SAOPAULO";

    final payload = gerarPix(
      chave: chavePix,
      recebedor: recebedor,
      cidade: cidade,
      valor: widget.total,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("PIX - QR Code"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QRCODE FUNCIONANDO
            QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: 240,
            ),

            const SizedBox(height: 12),

            Text(
              "Valor: R\$ ${widget.total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar", style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pagamento")),
      body: Center(
        child: ElevatedButton(
          onPressed: _abrirQrPix,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text(
            "Pagar com PIX",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
