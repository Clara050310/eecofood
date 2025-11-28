import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:ecofood/screens/tela_produtos_cliente.dart';
import 'package:ecofood/screens/tela_registro.dart';
import 'package:ecofood/screens/tela_esqueci_senha.dart';

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ["email"]); // ← IMPORTANTE

  // LOGIN EMAIL/SENHA
  Future<void> _loginEmailSenha() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TelaProdutosCliente()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email ou senha incorretos")),
      );
    }
  }

  // LOGIN GOOGLE
  Future<void> _loginGoogle() async {
    try {
      // 1 - abrir pop-up de login
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      // 2 - pegar tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3 - converter credenciais para o Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4 - logar no Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 5 - ir para a tela principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TelaProdutosCliente()),
      );
    } catch (e) {
      print("ERRO LOGIN GOOGLE: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao entrar com o Google, verifique o Firebase."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                  // BOTÃO GOOGLE FUNCIONAL
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _loginGoogle,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.g_mobiledata,
                              color: Colors.blue, size: 30),
                          SizedBox(width: 10),
                          Text(
                            "Continuar com o Google",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Ou"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  SizedBox(height: 18),

                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),

                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TelaEsqueciSenha()),
                        );
                      },
                      child: Text(
                        "Esqueci minha senha",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loginEmailSenha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        "Entrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TelaRegistro()),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Não tem uma conta? ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Registre-se",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
