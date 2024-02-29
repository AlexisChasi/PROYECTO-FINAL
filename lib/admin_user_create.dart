import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtk_flutter/service/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminManageUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topografos'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              _registerNewUser(context);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los datos'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No hay usuarios'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Nombre: ${data['nombre']}'),
                subtitle: Text('Rol: ${data['role']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _confirmDeleteUser(context, document.id);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.visibility),
                      onPressed: () {
                        // URL de Google Maps con la ubicación en tiempo real
                        String googleMapsUrl =
                            "https://www.google.com/maps/search/?api=1&query=Googleplex&query_place_id=ChIJVYBZvgoxj4ARkvPR3wQIlf0";

                        // Verifica si la URL se puede lanzar
                        canLaunch(googleMapsUrl).then((bool canLaunch) {
                          if (canLaunch) {
                            // Abre la URL
                            launch(googleMapsUrl);
                          } else {
                            // Si no se puede lanzar la URL, muestra un mensaje de error
                            print('No se pudo abrir la URL de Google Maps');
                          }
                        }).catchError((err) {
                          // Maneja el error si ocurre
                          print('Error al lanzar la URL de Google Maps: $err');
                        });
                      },
                    ),

                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editStatusUser(context, document.id);
                      },
                    ),
                    // Agregar más opciones de gestión según sea necesario
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deleteUserTopo(userId);
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _registerNewUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String email = '';
        String password = '';
        String nombre = '';

        return AlertDialog(
          title: Text('Registrar Nuevo Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nombre Usuario'),
                onChanged: (value) => nombre = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                onChanged: (value) => email = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onChanged: (value) => password = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                newUserTopo(email, password,
                    nombre); // Llama a la función para crear un nuevo usuario
              },
              child: Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  void _viewUserDetails(BuildContext context, String userId) {
    // Implementar la lógica para ver en detalle el usuario
    // Esto podría ser navegando a una pantalla de detalle del usuario
  }

  void _editStatusUser(BuildContext context, String userId) {
    bool estado = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Estado del Usuario"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Selecciona el estado de la cuenta:"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Desactivado"),
                      Switch(
                        value: estado,
                        onChanged: (newValue) {
                          setState(() {
                            estado = newValue;
                          });
                        },
                      ),
                      Text("Activado"),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                statusUser(estado, userId);
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
