 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaRedefinirSenha extends StatefulWidget {
  @override
  _TelaRedefinirSenhaState createState() => _TelaRedefinirSenhaState();
}

class _TelaRedefinirSenhaState extends State<TelaRedefinirSenha> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _redefinirSenha() async {
    if (_codeController.text.trim().isEmpty || _newPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, preencha todos os campos")),
      );
      return;
    }

    try {
      await _auth.confirmPasswordReset(
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Senha redefinida com sucesso!")),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // Voltar para a tela inicial
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao redefinir senha: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Redefinir senha"),
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
                    "Redefinir senha",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    "Digite o código do email e sua nova senha.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 24),

                  // CÓDIGO
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: "Código do email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 12),

                  // NOVA SENHA
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Nova senha",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 24),

                  // BOTÃO REDEFINIR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _redefinirSenha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        "Redefinir senha",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // VOLTAR
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Voltar",
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
