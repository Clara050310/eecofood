import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'tela_acompanhar_pedido.dart';

// Cor principal do projeto
const Color _primaryColor = Color(0xFF8B0000);

// -----------------------------------------------------------
// GERAR PAYLOAD PIX (simplificado)
// -----------------------------------------------------------
String gerarPix({
  required String chave,
  required String recebedor,
  required String cidade,
  required double valor,
}) {
  final valorFormatado = valor.toStringAsFixed(2);

  final recebedorLimpo =
      recebedor.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\s]'), '');
  final cidadeLimpa =
      cidade.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\s]'), '');

  final mi_pix =
      "0014BR.GOV.BCB.PIX01${chave.length.toString().padLeft(2, '0')}$chave";
  final mi = "26${mi_pix.length.toString().padLeft(2, '0')}$mi_pix";
  final amount =
      "54${valorFormatado.length.toString().padLeft(2, '0')}$valorFormatado";
  final name =
      "59${recebedorLimpo.length.toString().padLeft(2, '0')}$recebedorLimpo";
  final city =
      "60${cidadeLimpa.length.toString().padLeft(2, '0')}$cidadeLimpa";

  return "000201"
      "010212"
      "$mi"
      "52040000"
      "5303986"
      "$amount"
      "5802BR"
      "$name"
      "$city"
      "62070503***"
      "6304";
}

// -----------------------------------------------------------
// TELA DE PAGAMENTO
// -----------------------------------------------------------
class TelaPagamento extends StatefulWidget {
  final double total;

  const TelaPagamento({super.key, required this.total});

  @override
  State<TelaPagamento> createState() => _TelaPagamentoState();
}

class _TelaPagamentoState extends State<TelaPagamento> {
  String _metodoSelecionado = 'pix';

  // -----------------------------------------------------------
  // POPUP PIX
  // -----------------------------------------------------------
  void _abrirQrPix() {
    const chavePix = "39965795860";
    const recebedor = "EcoFood";
    const cidade = "LIMEIRA";

    final payload = gerarPix(
      chave: chavePix,
      recebedor: recebedor,
      cidade: cidade,
      valor: widget.total,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          "Pagamento via PIX",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/pixqr.png",
              width: 220,
              height: 220,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              "Valor: R\$ ${widget.total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Fechar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o dialog
                  final pedidoId = DateTime.now().millisecondsSinceEpoch.toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaAcompanharPedido(pedidoId: pedidoId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Já realizei o pagamento"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // BOTÕES DE PAGAMENTO
  // -----------------------------------------------------------
  Widget _buildPaymentOption(String label, String value) {
    bool isSelected = _metodoSelecionado == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _metodoSelecionado = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? _primaryColor : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // LAYOUT
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text("Pagamento"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                offset: Offset(0, 4),
                color: Colors.black26,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Text(
                      "Eco Food",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Escolha a forma de pagamento",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // OPÇÕES
              _buildPaymentOption("Cartão de Crédito", "credito"),
              _buildPaymentOption("Cartão de Débito", "debito"),
              _buildPaymentOption("PIX", "pix"),

              const SizedBox(height: 25),

              // BOTÃO FINALIZAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _metodoSelecionado == 'pix'
                      ? _abrirQrPix
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Método ${_metodoSelecionado.toUpperCase()} selecionado (adicione a lógica).',
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Finalizar",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
