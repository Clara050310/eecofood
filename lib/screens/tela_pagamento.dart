import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// 🎨 CORES DO PROTÓTIPO
const Color _primaryColor = Color(0xFFC0392B);
const Color _backgroundColor = Color(0xFFF5F5F5);
const Color _cardColor = Color(0xFFFEF9F8);

class TelaPagamento extends StatefulWidget {
  final double total;

  const TelaPagamento({required this.total, super.key});

  @override
  _TelaPagamentoState createState() => _TelaPagamentoState();
}

class _TelaPagamentoState extends State<TelaPagamento> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text("Eco Food", style: TextStyle(fontSize: 16, color: Colors.white)),
            Text("Forma de Pagamento", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: _cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a Pagar:', style: TextStyle(fontSize: 18)),
                    Text(
                      'R\$ ${widget.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Selecione a forma de pagamento:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 12),

            _buildPaymentOption(
              context,
              'Cartão de Crédito',
              Icons.credit_card,
            ),

            _buildPaymentOption(
              context,
              'Cartão de Débito',
              Icons.credit_card_off,
            ),

            _buildPaymentOption(
              context,
              'PIX',
              Icons.qr_code_2,
              onTap: () => _showPixQrCode(context),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showOrderConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              elevation: 0,
            ),
            child: const Text(
              'Finalizar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String title, IconData icon,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: _cardColor,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: InkWell(
          onTap: onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Forma de Pagamento selecionada: $title'),
                    backgroundColor: _primaryColor,
                  ),
                );
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: _primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pedido Finalizado!'),
        content:
            Text('Seu pedido no valor de R\$ ${widget.total.toStringAsFixed(2)} foi enviado com sucesso.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('OK', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  // 🚀 QR CODE FIXO DO PIX
  void _showPixQrCode(BuildContext context) {
    final valor = widget.total.toStringAsFixed(2);

    // Cole sua chave PIX aqui:
    const chavePix = "seu_email_ou_cpf_ou_chave_aleatoria";

    // Código BR Code PIX fixo
    final String qrCodePix =
        "00020126580014BR.GOV.BCB.PIX0136$chavePix5204000053039865406$valor5802BR5910EcoFood6009SAO PAULO62070503***6304ABCD";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("PIX - QR Code"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrCodePix,
              version: QrVersions.auto,
              size: 220,
            ),
            const SizedBox(height: 10),
            Text("Valor: R\$ $valor"),
            const Text("Escaneie o QR Code para pagar."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar", style: TextStyle(color: _primaryColor)),
          )
        ],
      ),
    );
  }
}
