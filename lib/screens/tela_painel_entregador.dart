import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaPainelEntregador extends StatefulWidget {
  @override
  State<TelaPainelEntregador> createState() => _TelaPainelEntregadorState();
}

class _TelaPainelEntregadorState extends State<TelaPainelEntregador> {
  final TextEditingController _pedidoIdController = TextEditingController();
  String _statusAtual = 'preparando';

  Future<void> _atualizarStatus() async {
    final String id = _pedidoIdController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o ID do pedido.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("pedidos").doc(id).update({
        "status": _statusAtual,
        "ultimaAtualizacao": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status atualizado com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar status.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel do Entregador"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID do Pedido", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            TextField(
              controller: _pedidoIdController,
              decoration: InputDecoration(
                labelText: "Ex: PED12345",
              ),
            ),
            SizedBox(height: 20),

            Text("Status do Pedido", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),

            DropdownButton<String>(
              value: _statusAtual,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                    value: "preparando",
                    child: Text("Preparando Pedido")),
                DropdownMenuItem(
                    value: "caminho", child: Text("Pedido a Caminho")),
                DropdownMenuItem(
                    value: "entregue", child: Text("Pedido Entregue")),
              ],
              onChanged: (value) {
                setState(() {
                  _statusAtual = value!;
                });
              },
            ),

            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _atualizarStatus,
                child: const Text("Atualizar Status"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
