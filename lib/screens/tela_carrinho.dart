import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/local_storage_service.dart';
import 'tela_pagamento.dart';

// 🎨 CORES DO PROTÓTIPO
const Color _primaryColor = Color(0xFFC0392B); // Vermelho Escuro (Botões, AppBar)
const Color _backgroundColor = Color(0xFFF5F5F5); // Fundo Cinza Claro

class TelaCarrinho extends StatefulWidget {
  @override
  _TelaCarrinhoState createState() => _TelaCarrinhoState();
}

class _TelaCarrinhoState extends State<TelaCarrinho> {
  final LocalStorageService _localStorage = LocalStorageService();
  List<CartItem> cart = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() async {
    cart = await _localStorage.getCart();
    setState(() {});
  }

  void _removeItem(int index) async {
    cart.removeAt(index);
    await _localStorage.saveCart(cart);
    setState(() {});
  }

  void _increaseQty(int index) async {
    cart[index].quantity++;
    await _localStorage.saveCart(cart);
    setState(() {});
  }

  void _decreaseQty(int index) async {
    if (cart[index].quantity > 1) {
      cart[index].quantity--;
    } else {
      cart.removeAt(index);
    }
    await _localStorage.saveCart(cart);
    setState(() {});
  }

  void _clearCart() async {
    cart.clear();
    await _localStorage.saveCart(cart);
    setState(() {});
  }

  double get totalPrice => cart.fold(0, (sum, item) => sum + item.totalPrice);

  double get finalTotal => totalPrice + (totalPrice > 50 ? 0 : 5);

  String formatDate(String date) {
    final d = DateTime.parse(date);
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      //  appBar Fiel ao Protótipo (Cor e Título Centralizado)
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text("Eco Food", style: TextStyle(fontSize: 16, color: Colors.white)),
            const Text("Carrinho", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              onPressed: () => _clearCart(),
            ),
        ],
      ),

      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seu carrinho está vazio',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Lista de Itens do Carrinho
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];

                      // 📦 Card de Item de Produto (Fiel ao Protótipo)
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1, // Baixa elevação como no protótipo
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // Cantos pouco arredondados
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // IMAGEM
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // DADOS DO PRODUTO (Nome, Validade, Valor, Quantidade)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Produto (Nome)
                                    Text(
                                      item.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 4),
                                    
                                    // Validade
                                    Text(
                                      "Validade: ${formatDate(item.product.validity)}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 4),

                                    // Valor
                                    Text(
                                      "Valor: R\$ ${item.product.price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Botões de Quantidade e Exclusão (Simulando o 'X' do protótipo)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Botão de Excluir (Simulando o 'X')
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close, // Usa um ícone 'X' para ser fiel ao protótipo
                                      color: _primaryColor, 
                                      size: 24,
                                    ),
                                    onPressed: () => _removeItem(index),
                                    tooltip: 'Remover item',
                                  ),
                                  
                                  // Contador de Quantidade
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Botão Subtrair
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.remove, size: 16, color: item.quantity > 1 ? _primaryColor : Colors.grey),
                                          onPressed: () => _decreaseQty(index),
                                        ),
                                      ),
                                      
                                      // Quantidade
                                      Container(
                                        width: 25,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${item.quantity}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      
                                      // Botão Adicionar
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.add, size: 16, color: _primaryColor),
                                          onPressed: () => _increaseQty(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 8),

                                  // Subtotal
                                  Text(
                                    "R\$ ${item.totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 💰 Rodapé: Total + Botão Finalizar
                _buildTotalFooter(context),
              ],
            ),
    );
  }

  // Widget Separado para o Rodapé do Carrinho
  Widget _buildTotalFooter(BuildContext context) {
    // Definindo as regras de frete
    final double shippingCost = totalPrice > 50 ? 0.00 : 5.00;
    final String shippingText = totalPrice > 50 ? 'Grátis' : 'R\$ 2,00';
    final Color shippingColor = totalPrice > 50 ? Colors.green : Colors.black87;
    final double finalTotal = totalPrice + shippingCost;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text('R\$ ${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),

          // Frete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Frete:', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                shippingText,
                style: TextStyle(
                  fontSize: 16,
                  color: shippingColor,
                  fontWeight: totalPrice > 50 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // Total Final
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Final:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(
                'R\$ ${finalTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Botão Finalizar (Fiel ao Protótipo)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaPagamento(total: finalTotal)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Pouco arredondado
                ),
                elevation: 0,
              ),
              child: const Text(
                'Finalizar',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}