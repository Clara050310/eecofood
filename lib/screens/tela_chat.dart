import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TelaChat extends StatefulWidget {
  final String pedidoId;

  TelaChat({required this.pedidoId});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final TextEditingController _msgController = TextEditingController();

  void _enviarMensagem() {
    final texto = _msgController.text.trim();
    if (texto.isEmpty) return;

    FirebaseFirestore.instance
        .collection("pedidos")
        .doc(widget.pedidoId)
        .collection("chat")
        .add({
      "texto": texto,
      "enviadoPor": "cliente",
      "timestamp": DateTime.now(),
    });

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat com o entregador")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("pedidos")
                  .doc(widget.pedidoId)
                  .collection("chat")
                  .orderBy("timestamp")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();

                final msgs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index];
                    final enviadoCliente = msg["enviadoPor"] == "cliente";

                    return Align(
                      alignment: enviadoCliente
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: enviadoCliente
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg["texto"]),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // CAMPO DE ENVIO
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "Digite uma mensagem...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: _enviarMensagem,
                  icon: Icon(Icons.send),
                  color: Colors.green,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
