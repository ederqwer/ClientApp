import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'dart:convert' show utf8;

class Info {
  String s;
  String d;
  bool sendType;
  String sender;
  Info(this.sender, this.s, this.d, this.sendType);
}

class UpdateList {
  String name;
  Future<Socket> fsocket;
  // final List<Info> widgets = [];
  bool si = true;
  UpdateList({this.name, this.fsocket}) {
    if (si) {
      si = false;
      fsocket.then((socket) {
        socket.write(name);
      });
    }
  }
}

class SecondRoute extends StatelessWidget {
  final UpdateList updateList;
  const SecondRoute({Key key, this.updateList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBar appbar = AppBar(
      backgroundColor: Colors.teal.shade800,
      title: Text("ClientApp"),
    );

    SecondPage segundaPagina = SecondPage(updateList: this.updateList);
    String s = "";
    TextEditingController controller = TextEditingController();
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      appBar: appbar,
      body: ListView(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85 -
                    appbar.preferredSize.height,
                minHeight: MediaQuery.of(context).size.height * 0.85 -
                    appbar.preferredSize.height),
            child: segundaPagina,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: TextField(
                    controller: controller,
                    onChanged: (msg) {
                      s = msg;
                    },
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje',
                    ),
                  ),
                )),
                FloatingActionButton(
                  child: Icon(Icons.send),
                  tooltip: 'Enviar',
                  backgroundColor: Colors.teal.shade600,
                  onPressed: () {
                    //print(s);
                    updateList.fsocket.then((value) {
                      value.write(s);
                      controller.clear();
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  final UpdateList updateList;

  const SecondPage({Key key, this.updateList}) : super(key: key);
  @override
  SecondPageState createState() {
    return SecondPageState();
  }
}

class SecondPageState extends State<SecondPage> {
  bool si = true;
  final List<Info> widgets = [];
  dataHandler(data) {
    String s = String.fromCharCodes(data).trim();

    s = utf8.decode(data);
    //print('--->'+s);
    setState(() {
      //  print(widget.updateList.widgets.length);

      String sender;
      String nombre = widget.updateList.name;
      if (s.contains("#")) {
        List<String> lista = s.split('#');
        sender = lista[0];
        s = lista[1];
      } else {
        sender = "Server";
      }
      //print(sender +" -- >>> "+nombre);
      widgets.add(Info((sender==nombre)?'Tú':sender, s,
          formatDate(DateTime.now(), [HH, ':', nn, ' ', am]), 
          (sender==nombre)?true:false));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (si)
      widget.updateList.fsocket.then((socket) {
        socket.listen(dataHandler, cancelOnError: false);
      });
    si = false;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            reverse: true,
            child: Column(
              children: widgets.map((info) {
                return Align(
                  alignment: info.sendType
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        info.sendType ? 55 : 20, 0, info.sendType ? 20 : 55, 0),
                    child: Card(
                      elevation: 1,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            Container(
                              child: Text(
                                info.sender,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 50,
                                ),
                                child: Text(
                                  info.s,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            //),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 300,
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  info.d,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
