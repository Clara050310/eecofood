import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaAcompanharPedido extends StatefulWidget {
  final String pedidoId;

  const TelaAcompanharPedido({super.key, required this.pedidoId});

  @override
  State<TelaAcompanharPedido> createState() => _TelaAcompanharPedidoState();
}

class _TelaAcompanharPedidoState extends State<TelaAcompanharPedido> {
  final TextEditingController _msgController = TextEditingController();

  String _metodoEntrega = "delivery";

  @override
  void initState() {
    super.initState();

    // 🚨 Proteção contra pedidoId vazio
    if (widget.pedidoId.isEmpty) {
      print("ERRO: pedidoId está vazio!");
      return;
    }

    _carregarMetodoEntrega();
  }

  // 🔹 Carrega método de entrega com verificação
  Future<void> _carregarMetodoEntrega() async {
    if (widget.pedidoId.isEmpty) return;

    final pedido = await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(widget.pedidoId)
        .get();

    if (pedido.exists) {
      setState(() {
        _metodoEntrega = pedido.data()?['metodoEntrega'] ?? "delivery";
      });
    }
  }

  // 🔹 Atualiza método de entrega com segurança
  Future<void> _alterarMetodoEntrega(String metodo) async {
    if (widget.pedidoId.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(widget.pedidoId)
        .update({"metodoEntrega": metodo});

    setState(() {
      _metodoEntrega = metodo;
    });
  }

  // 🔹 Envia mensagem com proteção
  Future<void> _enviarMensagem() async {
    if (widget.pedidoId.isEmpty) return;

    final texto = _msgController.text.trim();
    if (texto.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("pedidos")
        .doc(widget.pedidoId)
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
    // 🚨 Falha crítica → impede crash
    if (widget.pedidoId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Acompanhar Pedido")),
        body: Center(
          child: Text(
            "Erro: pedidoId não foi fornecido.",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Acompanhar Pedido"),
        backgroundColor: Colors.green,
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
                  "Pedido #${widget.pedidoId}",
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
                      selectedColor: Colors.green,
                    ),
                    SizedBox(width: 12),
                    ChoiceChip(
                      label: Text("Retirada"),
                      selected: _metodoEntrega == "retirada",
                      onSelected: (_) => _alterarMetodoEntrega("retirada"),
                      selectedColor: Colors.green,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("pedidos")
                      .doc(widget.pedidoId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Carregando status...");
                    }

                    String status =
                        snapshot.data?.get("status") ?? "Preparando";

                    return Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.green),
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
          // CHAT
          // -------------------------------------------------------------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pedidos")
                  .doc(widget.pedidoId)
                  .collection("chat")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final mensagens = snapshot.data!.docs;

                if (mensagens.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhuma mensagem ainda...",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

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
                              ? Colors.green
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
          // CAMPO DE MENSAGEM
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
                  backgroundColor: Colors.green,
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
