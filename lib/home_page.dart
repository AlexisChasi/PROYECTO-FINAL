import 'package:firebase_auth/firebase_auth.dart' // new
    hide
        EmailAuthProvider,
        PhoneAuthProvider; // new
import 'package:flutter/material.dart'; // new
import 'package:provider/provider.dart'; // new

import 'app_state.dart'; // new
import 'src/authentication.dart'; // new
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
          Image.asset('assets/imagen1.jpg'),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.location_city, 'Quito - Ecuador'),
          // Add from here
          Consumer<ApplicationState>(
            builder: (context, appState, _) => AuthFunc(
                loggedIn: appState.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                }),
          ),
          // to here
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
