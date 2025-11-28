import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaEsqueciSenha extends StatefulWidget {
  @override
  _TelaEsqueciSenhaState createState() => _TelaEsqueciSenhaState();
}

class _TelaEsqueciSenhaState extends State<TelaEsqueciSenha> {
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _enviarEmailRedefinicao() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, insira um email válido")),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email de redefinição enviado! Verifique sua caixa de entrada.")),
      );
      Navigator.pop(context); // Voltar para tela de login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar email: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Esqueci minha senha"),
        backgroundColor: Color(0xFF8B0000),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B0000), Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 340,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // LOGO
                  Image.asset(
                    'assets/logo_ecofood.png',
                    height: 100,
                    errorBuilder: (ctx, error, stack) {
                      return Column(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 40),
                          Text(
                            "Erro ao carregar a logo",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  Text(
                    "Esqueci minha senha",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    "Digite seu email para receber um link de redefinição de senha. Verifique sua caixa de entrada e spam.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 24),

                  // EMAIL
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 24),

                  // BOTÃO ENVIAR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _enviarEmailRedefinicao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        "Enviar link de redefinição",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // VOLTAR PARA LOGIN
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Voltar ao login",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
