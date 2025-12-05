import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_qr_code.dart'; // Importação da tela do QR Code

class TelaAcompanharPedido extends StatefulWidget {
  final String pedidoId;

  // ID de teste como fallback
  const TelaAcompanharPedido({super.key, this.pedidoId = 'ID_DE_TESTE_FIREBASE'}); 

  @override
  State<TelaAcompanharPedido> createState() => _TelaAcompanharPedidoState();
}

class _TelaAcompanharPedidoState extends State<TelaAcompanharPedido> {
  final TextEditingController _msgController = TextEditingController();

  String _metodoEntrega = "delivery";
  late String _currentPedidoId;

  static const Color _primaryColor = Color(0xFF8B0000); 
  static const Color _secondaryColor = Colors.green; 

  @override
  void initState() {
    super.initState();
    _currentPedidoId = widget.pedidoId.isNotEmpty ? widget.pedidoId : 'ID_DE_TESTE_FIREBASE';
    _carregarMetodoEntrega();
  }

  // 🔹 Carrega método de entrega (Mantido)
  Future<void> _carregarMetodoEntrega() async {
    final pedido = await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(_currentPedidoId) 
        .get();

    if (pedido.exists) {
      setState(() {
        _metodoEntrega = pedido.data()?['metodoEntrega'] ?? "delivery";
      });
    }
  }

  // 🔹 Atualiza método de entrega com NAVEGAÇÃO para o QR Code
  Future<void> _alterarMetodoEntrega(String metodo) async {
    // 1. Atualiza o Firestore
    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(_currentPedidoId) 
        .update({"metodoEntrega": metodo});

    // 2. Atualiza o estado local para que o chip fique selecionado/desselecionado
    setState(() {
      _metodoEntrega = metodo;
    });

    // 3. Se o método selecionado for 'retirada', NAVEGA para a tela do QR Code
    if (metodo == 'retirada') {
      Navigator.push(
        context,
        MaterialPageRoute(
          // Passa o ID do pedido
          builder: (_) => TelaQrCode(pedidoId: _currentPedidoId),
        ),
      );
    }
  }

  // 🔹 Envia mensagem (Mantido)
  Future<void> _enviarMensagem() async {
    final texto = _msgController.text.trim();
    if (texto.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(_currentPedidoId) 
        .collection("chat")
        .add({
      "texto": texto,
      "autor": "cliente",
      "timestamp": FieldValue.serverTimestamp(),
    });

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Acompanhar Pedido"),
        backgroundColor: _primaryColor, 
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // -------------------------------------------------------------------
          // CABEÇALHO
          // -------------------------------------------------------------------
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pedido #ID: ${_currentPedidoId}", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 12),

                Text(
                  "Método de Entrega:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),

                SizedBox(height: 8),

                Row(
                  children: [
                    ChoiceChip(
                      label: Text("Entrega"),
                      selected: _metodoEntrega == "delivery",
                      onSelected: (_) => _alterarMetodoEntrega("delivery"),
                      selectedColor: _primaryColor,
                      labelStyle: TextStyle(
                        color: _metodoEntrega == "delivery" ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 12),
                    // 👇 CHIP DE RETIRADA COM A LÓGICA DE SELEÇÃO E NAVEGAÇÃO
                    ChoiceChip(
                      label: Text("Retirada"),
                      selected: _metodoEntrega == "retirada", // <--- FICA SELECIONADO SE _metodoEntrega É 'retirada'
                      onSelected: (_) => _alterarMetodoEntrega("retirada"), // <--- CHAMA A NAVEGAÇÃO
                      selectedColor: _primaryColor,
                      labelStyle: TextStyle(
                        color: _metodoEntrega == "retirada" ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("pedidos")
                      .doc(_currentPedidoId) 
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Carregando status...");
                    }

                    String status = "Preparando";
                    if (snapshot.data?.exists == true) {
                      status = snapshot.data?.get("status") ?? "Preparando";
                    }
                    
                    Color statusIconColor = _secondaryColor; 

                    return Row(
                      children: [
                        Icon(Icons.local_shipping, color: statusIconColor),
                        SizedBox(width: 8),
                        Text(
                          "Status: $status",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // CHAT (Mantido)
          // -------------------------------------------------------------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pedidos")
                  .doc(_currentPedidoId) 
                  .collection("chat")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhuma mensagem ainda...",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final mensagens = snapshot.data!.docs;

                return ListView(
                  reverse: true,
                  padding: EdgeInsets.all(12),
                  children: mensagens.map((msg) {
                    bool souEu = msg["autor"] == "cliente";
                    return Align(
                      alignment: souEu
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: souEu
                              ? _primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg["texto"],
                          style: TextStyle(
                            fontSize: 15,
                            color: souEu ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // -------------------------------------------------------------------
          // CAMPO DE MENSAGEM (Mantido)
          // -------------------------------------------------------------------
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "Falar com o entregador...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _primaryColor,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _enviarMensagem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}