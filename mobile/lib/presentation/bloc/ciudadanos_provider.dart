import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/ciudadano.dart';
import '../../domain/usecases/eliminar_ciudadano_usecase.dart';
import '../../domain/usecases/guardar_ciudadano_usecase.dart';
import '../../domain/usecases/obtener_ciudadanos_usecase.dart';

abstract class CiudadanosEstado {}

class CiudadanosInicial extends CiudadanosEstado {}

class CiudadanosCargando extends CiudadanosEstado {}

class CiudadanosCargados extends CiudadanosEstado {
  final List<Ciudadano> ciudadanos;
  final List<Ciudadano> ciudadanosFiltrados;
  final String queryBusqueda;

  CiudadanosCargados({
    required this.ciudadanos,
    this.ciudadanosFiltrados = const [],
    this.queryBusqueda = '',
  });

  CiudadanosCargados copiaCon({
    List<Ciudadano>? ciudadanos,
    List<Ciudadano>? ciudadanosFiltrados,
    String? queryBusqueda,
  }) {
    return CiudadanosCargados(
      ciudadanos: ciudadanos ?? this.ciudadanos,
      ciudadanosFiltrados: ciudadanosFiltrados ?? this.ciudadanosFiltrados,
      queryBusqueda: queryBusqueda ?? this.queryBusqueda,
    );
  }
}

class CiudadanoOperacionExito extends CiudadanosEstado {
  final String mensaje;
  CiudadanoOperacionExito(this.mensaje);
}

class CiudadanosError extends CiudadanosEstado {
  final String mensaje;
  CiudadanosError(this.mensaje);
}

class CiudadanosNotifier extends StateNotifier<CiudadanosEstado> {
  final ObtenerCiudadanosUseCase _obtenerCiudadanosUseCase;
  final GuardarCiudadanoUseCase _guardarCiudadanoUseCase;
  final EliminarCiudadanoUseCase _eliminarCiudadanoUseCase;
  
  StreamSubscription<List<Ciudadano>>? _streamSubscription;

  CiudadanosNotifier(
    this._obtenerCiudadanosUseCase,
    this._guardarCiudadanoUseCase,
    this._eliminarCiudadanoUseCase,
  ) : super(CiudadanosInicial());

  void cargarCiudadanos({String? usuarioId, String? rol}) {
    state = CiudadanosCargando();
    _streamSubscription?.cancel();
    
    _streamSubscription = _obtenerCiudadanosUseCase.ejecutarReactivo(usuarioId: usuarioId, rol: rol).listen(
      (lista) {
        final estadoActual = state;
        String query = '';
        
        if (estadoActual is CiudadanosCargados) {
          query = estadoActual.queryBusqueda;
        }

        final filtrados = _filtrarLista(lista, query);

        state = CiudadanosCargados(
          ciudadanos: lista,
          ciudadanosFiltrados: filtrados,
          queryBusqueda: query,
        );
      },
      onError: (error) {
        state = CiudadanosError('Error al recuperar ciudadanos de SQLite: ${error.toString()}');
      },
    );
  }

  void filtrarCiudadanos(String query) {
    final estadoActual = state;
    if (estadoActual is CiudadanosCargados) {
      final filtrados = _filtrarLista(estadoActual.ciudadanos, query);
      state = estadoActual.copiaCon(
        ciudadanosFiltrados: filtrados,
        queryBusqueda: query,
      );
    }
  }

  Future<void> guardarCiudadano({
    String? id,
    required String documentoIdentidad,
    required String nombres,
    required String apellidos,
    required DateTime fechaNacimiento,
    String? telefono,
    String? correo,
    required String registradoPorUsuarioId,
    required String registradoEnDispositivoId,
  }) async {
    try {
      await _guardarCiudadanoUseCase.ejecutar(
        id: id,
        documentoIdentidad: documentoIdentidad,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: fechaNacimiento,
        telefono: telefono,
        correo: correo,
        registradoPorUsuarioId: registradoPorUsuarioId,
        registradoEnDispositivoId: registradoEnDispositivoId,
      );
      state = CiudadanoOperacionExito(
        id == null ? 'Ciudadano registrado localmente con éxito.' : 'Registro actualizado localmente con éxito.'
      );
      cargarCiudadanos();
    } catch (e) {
      state = CiudadanosError('Error al escribir localmente: ${e.toString()}');
    }
  }

  Future<void> eliminarCiudadano(String id) async {
    try {
      await _eliminarCiudadanoUseCase.ejecutar(id);
      state = CiudadanoOperacionExito('Ciudadano marcado para eliminación física offline.');
      cargarCiudadanos();
    } catch (e) {
      state = CiudadanosError('Error al borrar localmente: ${e.toString()}');
    }
  }

  List<Ciudadano> _filtrarLista(List<Ciudadano> lista, String query) {
    if (query.isEmpty) return lista;
    final q = query.toLowerCase();
    return lista.where((c) {
      return c.documentoIdentidad.contains(q) ||
          c.nombres.toLowerCase().contains(q) ||
          c.apellidos.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

final ciudadanosProvider = StateNotifierProvider<CiudadanosNotifier, CiudadanosEstado>((ref) {
  return CiudadanosNotifier(
    ref.watch(obtenerCiudadanosUseCaseProvider),
    ref.watch(guardarCiudadanoUseCaseProvider),
    ref.watch(eliminarCiudadanoUseCaseProvider),
  );
});
