import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../bloc/auth_provider.dart';

class RegistrarRegistradorScreen extends ConsumerStatefulWidget {
  const RegistrarRegistradorScreen({super.key});

  @override
  ConsumerState<RegistrarRegistradorScreen> createState() => _RegistrarRegistradorScreenState();
}

class _RegistrarRegistradorScreenState extends ConsumerState<RegistrarRegistradorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  
  bool _cargando = false;
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final authEstado = ref.read(authProvider);
    if (authEstado is! AuthAuthenticated) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No has iniciado sesión o tu sesión expiró.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final registrarUseCase = ref.read(registrarUsuarioUseCaseProvider);
      
      await registrarUseCase.ejecutar(
        correo: _correoController.text.trim(),
        contrasena: _contrasenaController.text,
        nombre: _nombreController.text.trim(),
        token: authEstado.token,
      );

      if (mounted) {
        setState(() => _cargando = false);
        
        // Mostrar Dialog de Éxito
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Registro Exitoso'),
                ],
              ),
              content: Text(
                'El registrador ${_nombreController.text} ha sido creado correctamente en el servidor central.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar dialog
                    Navigator.of(context).pop(); // Volver a la pantalla anterior
                  },
                  child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Agente'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono y Texto de Encabezado
              Center(
                child: Column(
                  children: [
                    Icon(Icons.admin_panel_settings, size: 72, color: Colors.blue.shade800),
                    const SizedBox(height: 12),
                    Text(
                      'Nuevo Registrador de Campo',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.blue.shade900
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Crea una nueva cuenta para que un agente pueda recolectar datos en campo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Campo Nombre Completo
              TextFormField(
                controller: _nombreController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre completo.';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Correo
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el correo electrónico.';
                  }
                  // Validación simple de regex
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Ingresa un formato de correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Contraseña
              TextFormField(
                controller: _contrasenaController,
                obscureText: !_mostrarContrasena,
                decoration: InputDecoration(
                  labelText: 'Contraseña Temporal',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_mostrarContrasena ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña.';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 36),

              // Botón Guardar / Loader
              ElevatedButton(
                onPressed: _cargando ? null : _enviarFormulario,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _cargando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3, 
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Registrar Agente',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
