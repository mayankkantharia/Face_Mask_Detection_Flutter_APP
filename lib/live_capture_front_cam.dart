// ignore_for_file: unnecessary_null_comparison

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'constants.dart';
import 'main.dart';

class LiveCaptureFront extends StatefulWidget {
  const LiveCaptureFront({Key? key}) : super(key: key);

  @override
  _LiveCaptureFrontState createState() => _LiveCaptureFrontState();
}

class _LiveCaptureFrontState extends State<LiveCaptureFront> {
  late CameraImage cameraImage;
  late CameraController cameraController;
  String result = "";

  initFrontCamera() {
    cameraController = CameraController(cameras[1], ResolutionPreset.high);
    cameraController.initialize().then((value) {
      if (!mounted) return;
      setState(() {
        cameraController.startImageStream((imageStream) {
          cameraImage = imageStream;
          runModel();
        });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/label1.txt");
  }

  runModel() async {
    if (cameraImage != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.6,
        asynch: true,
      );
      recognitions?.forEach((element) {
        setState(() {
          result = element["label"].toString().substring(1);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initFrontCamera();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Face Mask Detector',
            style: kAppBarTextStyle,
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              width: MediaQuery.of(context).size.width,
              child: !cameraController.value.isInitialized
                  ? Container()
                  : AspectRatio(
                      aspectRatio: cameraController.value.aspectRatio,
                      child: CameraPreview(cameraController),
                    ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
