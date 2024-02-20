import 'dart:ffi';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// ----- Admin -------

Future<void> newUserTopo(String email, String password, String name) async {
  UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Agregar información adicional del usuario a Firestore
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userCredential.user!.uid)
      .set({
    'nombre': name,
    'email': email,
    'role': 'Topografo', // Definir el rol predeterminado del nuevo usuario
    'estado': true
    // Puedes agregar más campos según sea necesario
  });
}

Future<void> deleteUserTopo(String userID) async {
  await db.collection('users').doc(userID).delete();
}

Future<void> statusUser(bool status, String userID) async {
  await db.collection('users').doc(userID).update({
    "estado": status
  });
}

// ----- Cartografos ------
Future<void> saveMeasures(double area, List<LatLng> points, String name) async {
  // Obtener el usuario actualmente autenticado
  User? user = FirebaseAuth.instance.currentUser;

  List<Map<String, double>> formattedPoints = points.map((LatLng point) {
    return {
      'latitude': point.latitude,
      'longitude': point.longitude,
    };
  }).toList();

// Luego puedes pasar formattedPoints a tu método saveMeasures.

  if (user != null) {
    // Obtener el UID del usuario
    String uid = user.uid;

    // Guardar la información junto con el UID del usuario en Firestore
    await db.collection('Medidas').add({
      "Nombre": name,
      "Posiciones": formattedPoints,
      "Area": area,
      "UID": uid, // Agregar el UID del usuario como un campo
    });
  } else {
    // Manejar el caso en el que no haya usuario autenticado
    print("No hay usuario autenticado.");
  }
}

Future<void> deleteMesure(String uid) async {
  await db.collection("Medidas").doc(uid).delete();
}
