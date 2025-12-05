import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Se você for salvar CPF/Telefone no Firestore, precisará desta importação:
// import 'package:cloud_firestore/cloud_firestore.dart'; 

import 'tela_login.dart';

class TelaRegistro extends StatefulWidget {
  @override
  _TelaRegistroState createState() => _TelaRegistroState();
}

class _TelaRegistroState extends State<TelaRegistro> {
  // Controladores de Texto (agora simples, sem máscara)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpfController = TextEditingController(); // Simples
  final _phoneController = TextEditingController(); // Simples

  bool _isBeneficiary = false; 

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    // Não é necessário remover máscara se não usarmos MaskedTextController
    final cpf = _cpfController.text.trim(); 
    final phone = _phoneController.text.trim(); 

    if (email.isEmpty || pass.isEmpty || cpf.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    try {
      // 1. Cria o usuário no Firebase Authentication
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // 2. Salva dados adicionais no Firestore (Exemplo Comentado)
      // (Você precisará de 'cloud_firestore' e descomentar a lógica)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      // Redireciona para a tela de login após o cadastro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TelaLogin()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// GRADIENTE
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8B0000),
              Color(0xFFFFF2F2),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// LOGO
                Column(
                  children: [
                    Image.asset(
                      "assets/logo.png",
                      width: 120,
                      height: 120,
                    ),
                    SizedBox(height: 20),
                  ],
                ),

                /// CARD BRANCO CENTRAL
                Container(
                  width: 340,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.black26,
                      )
                    ],
                  ),

                  child: Column(
                    children: [
                      /// CAMPOS CPF, TELEFONE, EMAIL E SENHA
                      TextField(
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "CPF",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Telefone",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Senha",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 16),

                      /// OPÇÃO DE BENEFICIÁRIO
                      Row(
                        children: [
                          Checkbox(
                            value: _isBeneficiary,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isBeneficiary = newValue ?? false;
                              });
                            },
                            activeColor: Color(0xFF8B0000), // Cor do tema
                          ),
                          Flexible(
                            child: Text(
                              "Sou beneficiário de algum programa social do governo (opcional)",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      /// BOTÃO REGISTRAR (VERMELHO)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B0000),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Criar conta",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      /// LINK LOGIN
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => TelaLogin()),
                          );
                        },
                        child: Text(
                          "Já tem uma conta? Faça login",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}