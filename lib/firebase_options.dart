// ---------------------------------------------------------------------------
// ARCHIVO DE CONFIGURACIÓN DE FIREBASE
//
// Este archivo tiene la misma forma que genera `flutterfire configure`.
// Los valores "REEMPLAZAR_..." son marcadores de posición: mientras sigan
// presentes, la aplicación arranca en modo local y NO intenta inicializar
// Firebase.
//
// Para conectarla a tu proyecto:
//   1. Crea el proyecto y registra la app Android en Firebase Console.
//   2. Ejecuta:  flutterfire configure
//   3. Selecciona el proyecto y la plataforma android.
//   4. Este archivo se sobrescribe con las credenciales reales.
//
// No escribas credenciales a mano ni las subas a un repositorio público.
// ---------------------------------------------------------------------------
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Configuración de Firebase por plataforma.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'Wallet UNSAAC se distribuye solo para Android. '
      'Plataforma detectada: $defaultTargetPlatform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrlqAGZdUtsSMzQokd9chG6KLQYglluGQ',
    appId: '1:1051167575652:android:57d24710fa5348c666d971',
    messagingSenderId: '1051167575652',
    projectId: 'pro-sylph-463700-a2',
    storageBucket: 'pro-sylph-463700-a2.firebasestorage.app',
  );
}
