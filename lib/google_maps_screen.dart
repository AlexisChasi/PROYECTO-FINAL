import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtk_flutter/service/firebase_service.dart';
import 'package:gtk_flutter/utils/constans.dart';
import 'package:gtk_flutter/utils/utils.dart';
import 'package:intl/intl.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  Completer<GoogleMapController> googleMapController = Completer();
  List<LatLng> posiciones = [];
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  CameraPosition initialCameraPosition = const CameraPosition(
    zoom: 16,
    target: LatLng(-0.2107613, -78.4881543),
  );
  late BitmapDescriptor icon;
  bool showCalculateButton = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await setIcon();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(kMarker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  double calculatePolygonArea(List<LatLng> points) {
    double area = 0.0;
    int j = points.length - 1;

    for (int i = 0; i < points.length; i++) {
      area += (points[j].longitude + points[i].longitude) *
          (points[j].latitude - points[i].latitude);
      j = i;
    }

    return area.abs() / 2.0;
  }

  void setPolylines() {
    polylines.clear();

    if (posiciones.isNotEmpty) {
      // Crear una lista de puntos para el polígono
      List<LatLng> polygonPoints = [...posiciones];
      polygonPoints.add(posiciones
          .first); // Agregar el primer punto al final para cerrar el polígono

      polylines.add(
        Polyline(
          polylineId: const PolylineId('polygon'),
          points: polygonPoints,
          width: 4,
          color: Colors.purple,
        ),
      );

      // Agregar una línea entre el último y el primer marcador para formar el polígono
      polylines.add(
        Polyline(
          polylineId: const PolylineId('closingLine'),
          points: [posiciones.last, posiciones.first],
          width: 4,
          color: Colors.purple,
        ),
      );

      setState(() {
        showCalculateButton = true;
      });
    } else {
      setState(() {
        showCalculateButton = false;
      });
    }
  }

  void addMarker(LatLng nuevaPosicion) {
    markers.add(
      Marker(
        markerId: MarkerId(nuevaPosicion.toString()),
        position: nuevaPosicion,
        icon: icon,
        infoWindow: InfoWindow(
          title: DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
        ),
      ),
    );
    posiciones.add(nuevaPosicion);
    setPolylines();
  }

  Future<void> moverCamara(LatLng posicion) async {
    final controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(posicion));
  }

  void clearMarkers() {
    markers.clear();
    posiciones.clear();
    polylines.clear();
    setState(() {});
  }

  void calculateArea() {
    double area = calculatePolygonArea(posiciones);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Área del Polígono'),
          content: Text('El área del polígono es: $area'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: saveMeasuresCt,
              child: const Text("Guardar datos"),
            )
          ],
        );
      },
    );
  }

  void saveMeasuresCt() {
    double area = calculatePolygonArea(posiciones);
    String name =
        ''; // Variable para almacenar el nombre ingresado por el usuario

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Datos"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Datos: \nArea: $area\nPosciones: $posiciones'),
              TextField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onChanged: (value) {
                  // Actualizar el nombre cuando el usuario escribe en el campo de texto
                  name = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Verificar si se ingresó un nombre
                if (name.isNotEmpty) {
                  await saveMeasures(area, posiciones, name);
                  Navigator.of(context).pop();
                } else {
                  // Mostrar un mensaje de error si no se ingresó un nombre
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, ingresa un nombre.'),
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Google Maps'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              markers: markers,
              polylines: polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                googleMapController.complete(controller);
              },
              onTap: (LatLng posicion) {
                addMarker(posicion);
              },
            ),
            if (showCalculateButton)
              Positioned(
                top: 66,
                right: 16,
                child: ElevatedButton(
                  onPressed: calculateArea,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 135, 143, 218)),
                  ),
                  child: Text(
                    'Calcular Área',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            Positioned(
              top: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: clearMarkers,
                child: const Text('Limpiar Marcadores'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
