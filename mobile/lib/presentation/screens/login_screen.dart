import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_provider.dart';
import '../theme/sirc_theme.dart';
import '../widgets/sirc_background.dart';
import '../widgets/sirc_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController(text: 'admin@sirc.gov');
  final _contrasenaController = TextEditingController(text: 'admin12345');
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _intentarLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).login(
            _correoController.text.trim(),
            _contrasenaController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authEstado = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next is AuthAuthenticated) {
        context.go('/dashboard');
      } else if (next is AuthError) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('No se pudo ingresar'),
            content: Text(next.mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    });

    final cargando = authEstado is AuthLoading;

    return Scaffold(
      body: SircBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.76),
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: SircColors.blue.withOpacity(0.10),
                                blurRadius: 30,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: const SircLogo(size: 118, showText: false),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.86),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: SircColors.blue.withOpacity(0.10),
                              blurRadius: 35,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Acceso operativo',
                              style: TextStyle(
                                color: SircColors.ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ingresa para registrar, consultar y sincronizar datos.',
                              style: TextStyle(
                                color: SircColors.muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _correoController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Ingresa tu correo';
                                }
                                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(val)) {
                                  return 'Ingresa un correo valido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contrasenaController,
                              obscureText: _ocultarContrasena,
                              decoration: InputDecoration(
                                labelText: 'Contrasena',
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _ocultarContrasena
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() => _ocultarContrasena =
                                        !_ocultarContrasena);
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty)
                                  return 'Ingresa tu contrasena';
                                if (val.length < 6)
                                  return 'Minimo 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            PressableCard(
                              borderRadius: BorderRadius.circular(18),
                              onTap: cargando ? null : _intentarLogin,
                              child: Container(
                                height: 58,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      SircColors.blue,
                                      SircColors.blueLight
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: SircColors.blue.withOpacity(0.28),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: cargando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Entrar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Disponible para trabajo local y sincronizacion posterior.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: SircColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
