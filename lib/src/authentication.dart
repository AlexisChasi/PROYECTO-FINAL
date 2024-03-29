// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtk_flutter/admin_user_create.dart';
import 'package:gtk_flutter/google_maps_screen.dart';
import 'package:gtk_flutter/list_measures.dart';

import 'widgets.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({
    Key? key,
    required this.loggedIn,
    required this.signOut,
    required this.isTopographer,
    required this.isActive,
  }) : super(key: key);

  final bool loggedIn;
  final bool isTopographer;
  final bool isActive;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 8),
          child: StyledButton(
            onPressed: () {
              !loggedIn ? context.push('/sign-in') : signOut();
            },
            child: !loggedIn
                ? const Text('Iniciar Sesión')
                : const Text('Cerrar Sesión'),
          ),
        ),
        Visibility(
          visible: loggedIn && isActive,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: StyledButton(
              onPressed: () {
                context.push('/profile');
              },
              child: const Text('Perfil'),
            ),
          ),
        ),
        Visibility(
          visible: loggedIn && isActive && isTopographer,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: StyledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoogleMapsScreen(
                      key: UniqueKey(),
                    ), // Asegúrate de pasar una Key
                  ),
                );
              },
              child: const Text('Mapeo'),
            ),
          ),
        ),
        Visibility(
          visible: loggedIn && isActive && isTopographer,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: StyledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MeasurementsListScreen(), // Asegúrate de pasar una Key
                  ),
                );
              },
              child: const Text('Tomas'),
            ),
          ),
        ),
        Visibility(
          visible: loggedIn && !(isTopographer) && isActive,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: StyledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminManageUsersScreen(),
                  ),
                );
              },
              child: const Text('Gestion Usuarios'),
            ),
          ),
        ),
        Visibility(
          visible: loggedIn && !(isActive),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Text(
              'Tu cuenta está desactivada',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
