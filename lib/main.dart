import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
import 'package:signature/signature.dart';
import 'package:pdf/widgets.dart' as pw;

void main() => runApp(MyApp());

/// example widget showing how to use signature widget
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final pdf = pw.Document();
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.grey,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () {
      print('onDrawEnd called!');
    },
  );

  generatePdf(data) async {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
            child: pw.Container(
                decoration: pw.BoxDecoration(
                    image: pw.DecorationImage(image: pw.MemoryImage(data))))),
      ),
    );
    final path = (await getExternalStorageDirectory()).path;
    // final file = File('$path/output.pdf');
    // List<int> bytel = pdf.readAsBytes();
    // await file.writeAsBytes(pdf, flush: true);

    final file = File('$path/example.pdf');
// List<int> bytes = file.save();
    // pdf.dispose();

    // saveAndLaunchFile(file, 'Output.pdf');
    print(path);
    await file.writeAsBytes(await pdf.save());
    OpenFile.open('$path/example.pdf');
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: ListView(
            children: <Widget>[
              Container(
                height: 100,
                child: const Center(
                  child: Text('Please sign below:'),
                ),
              ),
              //SIGNATURE CANVAS
              Signature(
                controller: _controller,
                height: 300,
                backgroundColor: Colors.lightBlueAccent,
              ),
              //OK AND CLEAR BUTTONS
              Container(
                decoration: const BoxDecoration(color: Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //SHOW EXPORTED IMAGE IN NEW ROUTE
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.blue,
                      onPressed: () async {
                        if (_controller.isNotEmpty) {
                          final Uint8List data = await _controller.toPngBytes();
                          if (data != null) {
                            ImageProvider image = Image.memory(data).image;
                            generatePdf(data);
                            // await Navigator.of(context).push(
                            //   MaterialPageRoute<void>(
                            //     builder: (BuildContext context) {
                            //       return Scaffold(
                            //         appBar: AppBar(),
                            //         body: Center(
                            //           child: Container(
                            //             color: Colors.grey[300],
                            //             child: Image.memory(data),
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // );
                          }
                        }
                      },
                    ),
                    //CLEAR CANVAS
                    IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _controller.clear());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
