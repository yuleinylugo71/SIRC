import 'package:uuid/uuid.dart';
import '../entities/ciudadano.dart';
import '../repositories/ciudadano_repository.dart';

class GuardarCiudadanoUseCase {
  final CiudadanoRepository _repository;
  final _uuid = const Uuid();

  GuardarCiudadanoUseCase(this._repository);

  Future<void> ejecutar({
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
    final esEdicion = id != null && id.isNotEmpty;

    if (esEdicion) {
      final ciudadanoExistente = await _repository.obtenerCiudadanoPorId(id);
      final versionActual = ciudadanoExistente?.version ?? 1;

      final ciudadanoEditado = Ciudadano(
        id: id,
        documentoIdentidad: documentoIdentidad,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: fechaNacimiento,
        telefono: telefono,
        correo: correo,
        estadoSincronizacion: 'PENDIENTE',
        registradoPorUsuarioId: registradoPorUsuarioId,
        registradoEnDispositivoId: registradoEnDispositivoId,
        version: versionActual + 1,
        createdAt: ciudadanoExistente?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.actualizarCiudadano(ciudadanoEditado);
    } else {
      final nuevoCiudadano = Ciudadano(
        id: _uuid.v4(),
        documentoIdentidad: documentoIdentidad,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: fechaNacimiento,
        telefono: telefono,
        correo: correo,
        estadoSincronizacion: 'PENDIENTE',
        registradoPorUsuarioId: registradoPorUsuarioId,
        registradoEnDispositivoId: registradoEnDispositivoId,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.registrarCiudadano(nuevoCiudadano);
    }
  }
}
