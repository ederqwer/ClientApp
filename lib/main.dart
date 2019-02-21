import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'secondpage.dart';

void main() => runApp(MyApp());

Future getAppPath() async => await getApplicationDocumentsDirectory();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClientApp',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(
        title: 'Inicio',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name;
  String ip;
  String path;
  bool flagInput;
  _MyHomePageState() {
    flagInput = true;
    getData();
  }

  getData() async {
    Directory appDocDir = await getAppPath();
    path = appDocDir.path;

    String filePath = '$path/file.txt';
    bool yes;
    await File(filePath).exists().then((bool val) {
      yes = val;
    });

    if (yes)
      await File(filePath).readAsString().then((String contents) {
        setState(() {
          flagInput = false;
          
          name = contents;
        });
      });
  }

  initApp() {
    String filePath = '$path/file.txt';

    File myFile = new File(filePath);
    myFile.writeAsString(name);
    //print(ip);
    Future<Socket> s = Socket.connect(ip, 100);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (c) => SecondRoute(
                  updateList: UpdateList(fsocket: s, name: name),
                )));
  }

  get getController {
    TextEditingController controller = new TextEditingController(text: name);
    controller.addListener(() {
      name = controller.text;
    });

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    Widget input = (flagInput)
        ? TextField(
            onChanged: (text) {
              setState(() {
                name = text;
              });
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: 'Nombre completo'),
          )
        : TextFormField(
            decoration: InputDecoration(labelText: 'Nombre completo'),
            controller: getController,
          );
    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: input,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: TextField(
                      onChanged: (text) {
                        setState(() {
                          ip = text;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: 'Ej. 192.168.0.10',
                          helperText: 'Se usara puerto 100 por defecto',
                          labelText: 'Dirección IP del servidor'),
                    ),
                  ),
                  RaisedButton.icon(
                    color: Colors.teal.shade800,
                    icon: Icon(
                      Icons.input,
                      color: Colors.white,
                    ),
                    label:
                        Text('Ingresar', style: TextStyle(color: Colors.white)),
                    onPressed: initApp,
                  ),
                ],
              ),
            ))),
      ),
    );
  }
}
