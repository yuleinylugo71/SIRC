import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/ciudadano.dart';
import '../bloc/auth_provider.dart';
import '../bloc/ciudadanos_provider.dart';

class CiudadanoFormScreen extends ConsumerStatefulWidget {
  final Ciudadano? ciudadano; // Si es null es registro nuevo, si no es edición

  const CiudadanoFormScreen({
    super.key,
    this.ciudadano,
  });

  @override
  ConsumerState<CiudadanoFormScreen> createState() => _CiudadanoFormScreenState();
}

class _CiudadanoFormScreenState extends ConsumerState<CiudadanoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _documentoController;
  late final TextEditingController _nombresController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _correoController;
  
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    final c = widget.ciudadano;
    
    _documentoController = TextEditingController(text: c?.documentoIdentidad ?? '');
    _nombresController = TextEditingController(text: c?.nombres ?? '');
    _apellidosController = TextEditingController(text: c?.apellidos ?? '');
    _telefonoController = TextEditingController(text: c?.telefono ?? '');
    _correoController = TextEditingController(text: c?.correo ?? '');
    _fechaNacimiento = c?.fechaNacimiento;
  }

  @override
  void dispose() {
    _documentoController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final ahora = DateTime.now();
    final primeraFecha = DateTime(ahora.year - 120);
    final ultimaFecha = ahora;

    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? ahora,
      firstDate: primeraFecha,
      lastDate: ultimaFecha,
      helpText: 'Selecciona la fecha de nacimiento',
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaNacimiento = fechaSeleccionada;
      });
    }
  }

  void _guardarFormulario(String usuarioId, String dispositivoId) {
    if (_formKey.currentState?.validate() ?? false) {
      if (_fechaNacimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona la fecha de nacimiento.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ref.read(ciudadanosProvider.notifier).guardarCiudadano(
            id: widget.ciudadano?.id,
            documentoIdentidad: _documentoController.text.trim(),
            nombres: _nombresController.text.trim(),
            apellidos: _apellidosController.text.trim(),
            fechaNacimiento: _fechaNacimiento!,
            telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
            correo: _correoController.text.trim().isEmpty ? null : _correoController.text.trim(),
            registradoPorUsuarioId: usuarioId,
            registradoEnDispositivoId: dispositivoId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authEstado = ref.watch(authProvider);

    if (authEstado is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sesión no disponible.')),
      );
    }

    final esEdicion = widget.ciudadano != null;
    final formatoFecha = _fechaNacimiento == null 
        ? 'No seleccionada' 
        : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}';

    // Escuchar el guardado exitoso para cerrar la pantalla
    ref.listen<CiudadanosEstado>(ciudadanosProvider, (prev, next) {
      if (next is CiudadanoOperacionExito) {
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Ciudadano' : 'Registrar Ciudadano'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Documento Identidad
              TextFormField(
                controller: _documentoController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Documento de Identidad',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  helperText: 'Solo números (6 a 12 dígitos)',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa el número de documento';
                  }
                  if (val.length < 6 || val.length > 12) {
                    return 'El documento debe tener entre 6 y 12 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Nombres
              TextFormField(
                controller: _nombresController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa los nombres';
                  }
                  if (val.trim().length < 2) {
                    return 'Nombres inválidos (mínimo 2 letras)';
                  }
                  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(val)) {
                    return 'Los nombres solo deben contener letras';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Apellidos
              TextFormField(
                controller: _apellidosController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa los apellidos';
                  }
                  if (val.trim().length < 2) {
                    return 'Apellidos inválidos (mínimo 2 letras)';
                  }
                  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(val)) {
                    return 'Los apellidos solo deben contener letras';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Selector de Fecha de Nacimiento
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de Nacimiento',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatoFecha,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month_outlined, color: Colors.blue),
                        onPressed: () => _seleccionarFecha(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Teléfono (Opcional)
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9+]+$'))],
                decoration: InputDecoration(
                  labelText: 'Teléfono (Opcional)',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  helperText: 'Solo números o prefijo + (8 a 15 caracteres)',
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    if (val.length < 8 || val.length > 15) {
                      return 'Teléfono inválido (debe tener entre 8 y 15 caracteres)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Correo (Opcional)
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico (Opcional)',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                      return 'Ingresa un correo electrónico válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              ElevatedButton(
                onPressed: () => _guardarFormulario(
                  authEstado.usuarioId,
                  authEstado.dispositivoId,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  esEdicion ? 'Actualizar Registro' : 'Registrar Ciudadano',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              
              // Nota informativa
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Los datos se cifran y guardan localmente.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
