import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cria pedido básico (retorna id)
  Future<String> createPedido({
    required String userId,
    required Map<String, dynamic> orderData,
  }) async {
    final docRef = await _db.collection('pedidos').add({
      'userId': userId,
      'status': 0,
      'previsao': orderData['previsao'] ?? '20–35 min',
      'entregador': orderData['entregador'] ?? {
        'name': 'Carlos Silva',
        'phone': '5511999999999',
        'vehicle': 'Moto - ABC-1234'
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      ...orderData,
    });
    return docRef.id;
  }

  // Observar documento do pedido em tempo real
  Stream<DocumentSnapshot<Map<String, dynamic>>> pedidoStream(String pedidoId) {
    return _db.collection('pedidos').doc(pedidoId).snapshots();
  }

  // Atualizar status do pedido
  Future<void> updateStatus(String pedidoId, int status) async {
    await _db.collection('pedidos').doc(pedidoId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Enviar mensagem no chat
  Future<void> sendMessage(String pedidoId, String from, String text) async {
    final collection = _db.collection('pedidos').doc(pedidoId).collection('messages');
    await collection.add({
      'from': from,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream das mensagens (ordenadas por createdAt)
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String pedidoId) {
    return _db
        .collection('pedidos')
        .doc(pedidoId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
