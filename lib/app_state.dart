import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  bool _isTopographer = false;
  bool get isTopographer => _isTopographer;

  bool _isActive = false; // Variable para almacenar el estado de la cuenta
  bool get isActive => _isActive;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _checkUserRole(user.uid);
        _checkUserStatus(user.uid);
      } else {
        _loggedIn = false;
        _isTopographer =
            false; // Reiniciar el estado del rol cuando el usuario no esté autenticado
        _isActive = false;
      }
      notifyListeners();
    });
  }

  Future<Object?> _getUserData(String uid) async {
    // Obtener el documento de usuario desde Firestore
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      // Devolver los datos del usuario como un mapa
      return userSnapshot.data();
    }
    // Si el usuario no existe, devuelve null
    return null;
  }

  Future<void> _checkUserRole(String uid) async {
    // Obtener los datos del usuario
    Map<String, dynamic>? userData =
        (await _getUserData(uid)) as Map<String, dynamic>?;
    print(userData);

    if (userData != null) {
      // Verificar si el usuario tiene el rol de "topógrafo"
      _isTopographer = userData['role'] == 'Topografo';
      notifyListeners();
    }
  }

  Future<void> _checkUserStatus(String uid) async {
    // Obtener el documento de usuario desde Firestore
    Map<String, dynamic>? userData =
        (await _getUserData(uid)) as Map<String, dynamic>?;
    print(userData);

    if (userData != null) {
      _isActive = !(userData['estado'] == false);
      notifyListeners();
    } else {
      _isActive = true;
      notifyListeners();
    }
  }
}
