// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:face_mask_detection_updated/constants.dart';
import 'package:face_mask_detection_updated/live_capture_back_cam.dart';
import 'package:face_mask_detection_updated/live_capture_front_cam.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  late File _image;
  late List _output;
  final imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  detectimage(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _output = prediction!;
      loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }

  _pickimageCamera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  _pickimageGallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Face Mask Detector',
            style: kAppBarTextStyle,
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 25),
            Center(
              child: Container(
                height: 140,
                width: 140,
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/mask1.png',
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'Mask Detector',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  height: kHeightButton,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: kButtonColor,
                      shape: const StadiumBorder(),
                    ),
                    child: Text('Capture', style: kButtonTextStyle),
                    onPressed: () {
                      _pickimageCamera();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: kButtonColor,
                      shape: const StadiumBorder(),
                    ),
                    child: Text('Gallery', style: kButtonTextStyle),
                    onPressed: () {
                      _pickimageGallery();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: kButtonColor,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Live Capture Back Camera',
                      style: kButtonTextStyle,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LiveCaptureBack(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: kButtonColor,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Live Capture Front Camera',
                      style: kButtonTextStyle,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LiveCaptureFront(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            loading != true
                ? Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          padding: const EdgeInsets.all(15),
                          child: Image.file(_image),
                        ),
                        _output != null
                            ? Text(
                                (_output[0]['label']).toString().substring(2),
                                style: kButtonTextStyle,
                              )
                            : const Text(''),
                        (_output[0]['label']).toString().substring(2) ==
                                'No Mask'
                            ? playSound()
                            : const SizedBox(
                                height: 0,
                              ),
                        _output != null
                            ? Text(
                                'Percentage: ' +
                                    (_output[0]['confidence'] * 100)
                                        .round()
                                        .toString(),
                                style: kButtonTextStyle,
                              )
                            : const Text(''),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
