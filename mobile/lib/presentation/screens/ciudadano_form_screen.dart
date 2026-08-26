import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/ciudadano.dart';
import '../bloc/auth_provider.dart';
import '../bloc/ciudadanos_provider.dart';
import '../theme/sirc_theme.dart';
import '../widgets/web_app_shell.dart';

class CiudadanoFormScreen extends ConsumerStatefulWidget {
  final Ciudadano? ciudadano; // Si es null es registro nuevo, si no es edición

  const CiudadanoFormScreen({
    super.key,
    this.ciudadano,
  });

  @override
  ConsumerState<CiudadanoFormScreen> createState() =>
      _CiudadanoFormScreenState();
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

    _documentoController =
        TextEditingController(text: c?.documentoIdentidad ?? '');
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SircColors.blue,
              onPrimary: Colors.white,
              surface: SircColors.surface,
              onSurface: SircColors.ink,
            ),
          ),
          child: child!,
        );
      },
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
            backgroundColor: SircColors.error,
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
            telefono: _telefonoController.text.trim().isEmpty
                ? null
                : _telefonoController.text.trim(),
            correo: _correoController.text.trim().isEmpty
                ? null
                : _correoController.text.trim(),
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
        if (kIsWeb) {
          context.go('/ciudadanos');
        } else {
          context.pop();
        }
      }
    });

    if (kIsWeb) {
      return WebContentPage(
        title: esEdicion ? 'Editar ciudadano' : 'Registrar ciudadano',
        subtitle: 'Captura local con sincronizacion posterior',
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 760),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SircColors.border),
              boxShadow: [
                BoxShadow(
                  color: SircColors.blue.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _FormularioCiudadanoContent(
              formKey: _formKey,
              documentoController: _documentoController,
              nombresController: _nombresController,
              apellidosController: _apellidosController,
              telefonoController: _telefonoController,
              correoController: _correoController,
              formatoFecha: formatoFecha,
              esEdicion: esEdicion,
              onSeleccionarFecha: () => _seleccionarFecha(context),
              onGuardar: () => _guardarFormulario(
                authEstado.usuarioId,
                authEstado.dispositivoId,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SircColors.background,
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Ciudadano' : 'Registrar Ciudadano'),
        backgroundColor: SircColors.blue,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
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
                    decoration: const InputDecoration(
                      labelText: 'Documento de Identidad',
                      prefixIcon: Icon(Icons.badge_outlined),
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
                  const SizedBox(height: 24),

                  // Input Nombres
                  TextFormField(
                    controller: _nombresController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Nombres',
                      prefixIcon: Icon(Icons.person_outline),
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
                  const SizedBox(height: 24),

                  // Input Apellidos
                  TextFormField(
                    controller: _apellidosController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                      prefixIcon: Icon(Icons.person_outline),
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
                  const SizedBox(height: 24),

                  // Selector de Fecha de Nacimiento
                  Container(
                    decoration: BoxDecoration(
                      color: SircColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SircColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha de Nacimiento',
                                style: TextStyle(
                                    fontSize: 14, color: SircColors.muted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatoFecha,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: SircColors.ink),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: SircColors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.calendar_month_outlined,
                                  color: SircColors.blue),
                              onPressed: () => _seleccionarFecha(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Teléfono (Opcional)
                  TextFormField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[0-9+]+$'))
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Teléfono (Opcional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                      helperText:
                          'Solo números o prefijo + (8 a 15 caracteres)',
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
                  const SizedBox(height: 24),

                  // Input Correo (Opcional)
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico (Opcional)',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(val)) {
                          return 'Ingresa un correo electrónico válido';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Botón Guardar
                  ElevatedButton.icon(
                    onPressed: () => _guardarFormulario(
                      authEstado.usuarioId,
                      authEstado.dispositivoId,
                    ),
                    icon: Icon(esEdicion
                        ? Icons.save_rounded
                        : Icons.person_add_rounded),
                    label: Text(esEdicion
                        ? 'Actualizar Registro'
                        : 'Registrar Ciudadano'),
                  ),
                  const SizedBox(height: 24),

                  // Nota informativa
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 16, color: SircColors.muted),
                      SizedBox(width: 8),
                      Text(
                        'Los datos se cifran y guardan localmente.',
                        style: TextStyle(
                            color: SircColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
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

class _FormularioCiudadanoContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController documentoController;
  final TextEditingController nombresController;
  final TextEditingController apellidosController;
  final TextEditingController telefonoController;
  final TextEditingController correoController;
  final String formatoFecha;
  final bool esEdicion;
  final VoidCallback onSeleccionarFecha;
  final VoidCallback onGuardar;

  const _FormularioCiudadanoContent({
    required this.formKey,
    required this.documentoController,
    required this.nombresController,
    required this.apellidosController,
    required this.telefonoController,
    required this.correoController,
    required this.formatoFecha,
    required this.esEdicion,
    required this.onSeleccionarFecha,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: documentoController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Documento de Identidad',
              prefixIcon: Icon(Icons.badge_outlined),
              helperText: 'Solo numeros (6 a 12 digitos)',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Ingresa el numero de documento';
              }
              if (val.length < 6 || val.length > 12) {
                return 'El documento debe tener entre 6 y 12 digitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: nombresController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: 'Nombres',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Ingresa los nombres';
              }
              if (val.trim().length < 2) {
                return 'Nombres invalidos (minimo 2 letras)';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: apellidosController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: 'Apellidos',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Ingresa los apellidos';
              }
              if (val.trim().length < 2) {
                return 'Apellidos invalidos (minimo 2 letras)';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              color: SircColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SircColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined,
                    color: SircColors.muted),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha de Nacimiento',
                        style: TextStyle(
                          fontSize: 13,
                          color: SircColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatoFecha,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: SircColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_calendar_rounded,
                      color: SircColors.blue),
                  onPressed: onSeleccionarFecha,
                  tooltip: 'Seleccionar fecha',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: telefonoController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9+]+$'))
            ],
            decoration: const InputDecoration(
              labelText: 'Telefono (Opcional)',
              prefixIcon: Icon(Icons.phone_outlined),
              helperText: 'Solo numeros o prefijo + (8 a 15 caracteres)',
            ),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                if (val.length < 8 || val.length > 15) {
                  return 'Telefono invalido';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo Electronico (Opcional)',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(val)) {
                  return 'Ingresa un correo valido';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onGuardar,
            icon:
                Icon(esEdicion ? Icons.save_rounded : Icons.person_add_rounded),
            label:
                Text(esEdicion ? 'Actualizar registro' : 'Registrar ciudadano'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: SircColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 16, color: SircColors.muted),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Los datos se cifran y guardan localmente.',
                  style: TextStyle(
                    color: SircColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
