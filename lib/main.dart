import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=70813c46";

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.white, primaryColor: Colors.black),
    debugShowCheckedModeBanner: false,
  ));
}

Future<Map<String, dynamic>> getData() async {
  final response = await http.get(Uri.parse(request));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Erro ao carregar dados");
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  void _realChanged(String text) {
    double real = double.tryParse(text) ?? 0.0;
    dolarController.text = (real / (dolar ?? 1)).toStringAsFixed(2);
    euroController.text = (real / (euro ?? 1)).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.tryParse(text) ?? 0.0;
    realController.text = (dolar * (this.dolar ?? 1)).toStringAsFixed(2);
    euroController.text = (dolar * (this.dolar ?? 1) / (euro ?? 1)).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.tryParse(text) ?? 0.0;
    realController.text = (euro * (this.euro ?? 1)).toStringAsFixed(2);
    dolarController.text = (euro * (this.euro ?? 1) / (dolar ?? 1)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(" MultiMoedas"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar dados :(",
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                     const Icon(
                        Icons.monetization_on_rounded, 
                        size: 50.0,
                        color:Colors.black,
                      ),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      const Divider(),
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      const Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function(String) onChanged) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(color: Colors.black, fontSize: 25.0),
    onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
