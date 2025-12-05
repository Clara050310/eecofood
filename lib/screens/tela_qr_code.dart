import 'package:flutter/material.dart';
import 'tela_acompanhar_pedido.dart'; // Importação necessária para a próxima tela

// Você precisará desta importação se estiver usando a biblioteca qr_flutter
// import 'package:qr_flutter/qr_flutter.dart'; 

class TelaQrCode extends StatelessWidget {
 final String pedidoId;

 // Você pode adicionar a lista de produtos aqui:
// final List<Map<String, dynamic>> itensDoPedido; 

 const TelaQrCode({super.key, required this.pedidoId}); 

 static const Color _primaryColor = Color(0xFF8B0000); // Tom de vermelho do seu layout

 @override
 Widget build(BuildContext context) {
 // A string de dados do QR Code. 
 final String qrCodeData = 'PedidoID:$pedidoId';

 return Scaffold(
 appBar: AppBar(
 title: const Text("Retirada - QR Code"),
 backgroundColor: _primaryColor,
 foregroundColor: Colors.white,
 ),
 body: Center(
 child: Padding(
 padding: const EdgeInsets.all(24.0),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Text(
 "Apresente este código para retirar seu pedido (Pagamento na Retirada).",
 textAlign: TextAlign.center,
 style: TextStyle(fontSize: 18),
 ),
 const SizedBox(height: 30),
 
 // -----------------------------------------------------------
 // ✅ EXIBIÇÃO DA IMAGEM ESTÁTICA DO QR CODE
 // -----------------------------------------------------------
 Container(
 decoration: BoxDecoration(
 border: Border.all(color: Colors.grey.shade300, width: 2),
 borderRadius: BorderRadius.circular(8)
),
 padding: const EdgeInsets.all(16),
 // Usa o asset 'pixqr.png' que você forneceu
 child: Image.asset(
 'pixqr.png', 
 width: 250,
 height: 250,
 fit: BoxFit.contain,
 ),
),

 const SizedBox(height: 30),
 Text(
 "Pedido ID: $pedidoId",
 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
 ),

 const SizedBox(height: 40),

 // Botão para a próxima tela na jornada do usuário
 ElevatedButton.icon(
 onPressed: () {
 // Substitui a tela atual pela tela de acompanhamento 
 Navigator.pushReplacement(
 context,
 MaterialPageRoute(
 builder: (_) => TelaAcompanharPedido(pedidoId: pedidoId),
 ),
 );
},
 icon: const Icon(Icons.track_changes_outlined),
 label: const Text("Acompanhar Pedido"),
 style: ElevatedButton.styleFrom(
 backgroundColor: _primaryColor,
 foregroundColor: Colors.white,
 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
 ),
 ),
 ],
 ),
 ),
 ),
 );
}
}