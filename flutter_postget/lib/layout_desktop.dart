import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class LayoutDesktop extends StatefulWidget {
  const LayoutDesktop({super.key, required this.title});

  final String title;

  @override
  State<LayoutDesktop> createState() => _LayoutDesktopState();
}

class _LayoutDesktopState extends State<LayoutDesktop> {
  TextEditingController _textController = TextEditingController();
  TextEditingController _receivedMessageController = TextEditingController();
  // Return a custom button
  Widget buildCustomButton(String buttonText, VoidCallback onPressedAction) {
    return SizedBox(
      width: 150, // Amplada total de l'espai
      child: Align(
        alignment: Alignment.centerRight, // Alineació a la dreta
        child: CDKButton(
          style: CDKButtonStyle.normal,
          isLarge: false,
          onPressed: onPressedAction,
          child: Text(buttonText),
        ),
      ),
    );
  }

  // Funció per seleccionar un arxiu
  Future<File> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      throw Exception("No s'ha seleccionat cap arxiu.");
    }
  }

  // Funció per carregar l'arxiu seleccionat amb una sol·licitud POST
  Future<void> uploadFile(AppData appData) async {
    try {} catch (e) {
      if (kDebugMode) {
        print("Excepció (uploadFile): $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            width: 600, // Ajustar el ancho total del contenedor
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Área de mensajes
                Expanded(
                  child: ListView.builder(
                    itemCount: appData.messages?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.android),
                        title: Text(appData.messages?[index] ?? ""),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _receivedMessageController.text.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.android),
                        title: Text(_receivedMessageController.text[index]),
                      );
                    },
                  ),
                ),

                SizedBox(
                    height:
                        30), // Separación entre la lista de mensajes y el resto de los elementos

                // Barra para poner texto
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                onSubmitted: (text) {
                                  _sendMessage(appData);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Escribe tu mensaje...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    8), // Separación entre la barra de texto y los botones
                            // Botón para subir un archivo
                            buildIconButton(Icons.file_upload, () async {
                              await uploadFile(appData);
                            }),
                            SizedBox(width: 8), // Separación entre los botones
                            // Botón de enviar
                            buildIconButton(Icons.send, () {
                              _sendMessage(appData);
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para agregar mensaje y limpiar la barra de texto
  // Método _sendMessage modificado
  // Función para agregar mensaje y limpiar la barra de texto
  Future<void> _sendMessage(AppData appData) async {
    String texto = _textController.text;
    if (texto.isNotEmpty) {
      // Crear un JSON con la pregunta y el mensaje
      Map<String, dynamic> jsonBody = {
        "type": "test",
        "mensaje": texto,
      };

      // Convertir el JSON a una cadena
      String jsonString = json.encode(jsonBody);

      appData.addMessage(texto);

      // Enviar la cadena JSON al servidor
      var response = await appData.sendTextToServer(appData.url, jsonString);
      // Simular escritura de la respuesta letra por letra
      int contador = 0;

      // Parsear el JSON de la respuesta
      Map<String, dynamic> jsonResponse = json.decode(response);

      // Obtener el mensaje del JSON de la respuesta
      String mensaje = jsonResponse["mensaje"];
      print(mensaje);

      print(mensaje.length);
      for (int i = 0; i < mensaje.length; i++) {
        if (contador == 0) {
          appData.addMessage(mensaje.substring(i));
          contador++;
        }
        appData.addTextToMessage(1, mensaje.substring(0, i + 1));

        appData.notifyListeners();
        await Future.delayed(const Duration(
            milliseconds:
                10)); // Notificar a los escuchadores para actualizar la interfaz
      }
      _textController.clear();
    }
  }
}

// Función para crear un botón con icono
Widget buildIconButton(IconData icon, VoidCallback onPressedAction) {
  return IconButton(
    onPressed: onPressedAction,
    icon: Icon(icon),
  );
}
