import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
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
  File _imageFile;
  List<ImageLabel> _labels;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print("Select Image");
          final imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
          print(imageFile);
          final image = FirebaseVisionImage.fromFile(imageFile);
          final imageLabeler = FirebaseVision.instance.imageLabeler();
          var labels = await imageLabeler.processImage(image);
          print("Got labels");
          print("\n\n\n\n\n\n\n\n");
          for (ImageLabel label in labels) {
            final String text = label.text;
            final String entityId = label.entityId;
            final double confidence = label.confidence;
            print("Found $text with a confidence of $confidence\n\n\n");
          }
          imageLabeler.close();
          if (mounted) {
            setState(() {
              _imageFile = imageFile;
              _labels = labels;
            });
          }
        },
        tooltip: 'Pick an image',
        child: Icon(Icons.add_a_photo),
      ),
      appBar: AppBar(
        title: Text("Image Labeler Demo"),
      ),
      body: ImageandFaces(
        imageFile: _imageFile,
        labels: _labels,
      ),
    );
  }
}

class ImageandFaces extends StatelessWidget {
  ImageandFaces({this.imageFile, this.labels});
  final File imageFile;
  final List<ImageLabel> labels;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Container(
              constraints: BoxConstraints.expand(),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: ListView.builder(
                itemCount: labels.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(
                      "Item: ${labels[index].text} Confidence: ${labels[index].confidence}");
                }),
          ),
        ],
      ),
    );
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);
  final Face face;
  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text('(${pos.top}, ${pos.left}), (${pos.bottom}, ${pos.right})'),
    );
  }
}
