import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapeo de Terrenos'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          // Ajuste de la imagen aquí
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/imagen1.jpg',
                width: MediaQuery.of(context).size.width *
                    0.3, // Establecer el ancho deseado
                fit: BoxFit.contain, // Ajustar la imagen al contenedor
              ),
            ),
          ),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.location_city, 'Quito - Ecuador'),
          Consumer<ApplicationState>(
            builder: (context, appState, _) => AuthFunc(
                loggedIn: appState.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                }),
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header("Calculo del area de un terreno"),
        ],
      ),
    );
  }
}
