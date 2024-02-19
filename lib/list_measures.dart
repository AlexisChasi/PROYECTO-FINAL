import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gtk_flutter/service/firebase_service.dart';

class MeasurementsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Mediciones'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Medidas')
            .where('UID',
                isEqualTo:
                    user?.uid) // Filtrar por el UID del usuario autenticado
            .snapshots(),
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
              child: Text('No hay mediciones almacenadas'),
            );
          }

          return ListView(
            padding: EdgeInsets.all(8),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Toma: ${data['Nombre']}'),
                  leading: Icon(Icons.description), // Ejemplo de icono
                  onTap: () {
                    _showMeasureDetailsDialog(context, data);
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _confirmDeleteDialog(
                          context,
                          document
                              .id); // Llama al método para mostrar el diálogo de confirmación de eliminación
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showMeasureDetailsDialog(
      BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Medida'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Área: ${data['Area']}'),
              Text('Puntos: ${data['Posiciones']}'),
              // Agrega más detalles según tus datos
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDialog(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar este elemento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async{
                await deleteMesure(
                    documentId); // Llama al método para eliminar el elemento
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
