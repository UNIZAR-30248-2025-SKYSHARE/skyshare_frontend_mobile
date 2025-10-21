class Spot {
  final int id;
  final int ubicacionId;
  final String? creadorId;
  final String nombre;
  final String? descripcion;
  final double lat;
  final double lng;
  final String ciudad;
  final String pais;
  final double? valoracionMedia;
  final int totalValoraciones;
  final String? urlImagen; 

  Spot({
    required this.id,
    required this.ubicacionId,
    required this.creadorId,
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.ciudad,
    required this.pais,
    this.descripcion,
    this.valoracionMedia,
    this.totalValoraciones = 0,
    this.urlImagen,
  });

  factory Spot.fromMap(Map<String, dynamic> map) {
    final ubicacion = map['ubicacion'] as Map<String, dynamic>? ?? {};
    
    double? valoracionMedia;
    int totalValoraciones = 0;
    
    if (map['valoracion'] != null) {
      final valoraciones = map['valoracion'] as List;
      if (valoraciones.isNotEmpty) {
        totalValoraciones = valoraciones.length;
        double suma = 0.0;
        for (var val in valoraciones) {
          final puntuacion = val['puntuacion'];
          if (puntuacion is int) {
            suma += puntuacion.toDouble();
          } else if (puntuacion is double) {
            suma += puntuacion;
          } else {
            suma += double.tryParse(puntuacion.toString()) ?? 0.0;
          }
        }
        valoracionMedia = totalValoraciones > 0 ? suma / totalValoraciones : null;
      }
    }
    
    return Spot(
      id: (map['id_spot'] is int) 
        ? map['id_spot'] as int 
        : int.parse(map['id_spot'].toString()),
      ubicacionId: (map['id_ubicacion'] is int) 
        ? map['id_ubicacion'] as int 
        : int.parse(map['id_ubicacion'].toString()),
      creadorId: map['id_usuario_creador']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
      lat: (ubicacion['latitud'] is double) 
        ? ubicacion['latitud'] as double 
        : (ubicacion['latitud'] is int 
          ? (ubicacion['latitud'] as int).toDouble() 
          : double.parse((ubicacion['latitud'] ?? '0').toString())),
      lng: (ubicacion['longitud'] is double) 
        ? ubicacion['longitud'] as double 
        : (ubicacion['longitud'] is int 
          ? (ubicacion['longitud'] as int).toDouble() 
          : double.parse((ubicacion['longitud'] ?? '0').toString())),
      ciudad: ubicacion['nombre']?.toString() ?? 'Desconocida',
      pais: ubicacion['pais']?.toString() ?? 'Desconocido',
      valoracionMedia: valoracionMedia,
      totalValoraciones: totalValoraciones,
      urlImagen: map['url_imagen']?.toString(), 
    );
  }

  String get valoracionTexto {
    if (valoracionMedia == null) return 'Sin valorar';
    return '${valoracionMedia!.toStringAsFixed(1)} ⭐';
  }
}
