import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';


class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  List<CameraDescription> _cameras = [];
  late FaceDetector _faceDetector;
  List<Face> _faces = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetection();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeFaceDetection() async {
    _faceDetector = GoogleMlKit.vision.faceDetector();
  }

  Future<void> _disposeCamera() async {
    await _controller.dispose();
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _detectFaces() async {
    final image = await _picker.pickImage(source: ImageSource.camera); // Capture an image from the camera
    if (image == null) {
      return;
    }

    final inputImage = InputImage.fromFilePath(image.path);
    final result = await _faceDetector.processImage(inputImage);

    setState(() {
      _faces = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera and Face Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            )
                : CircularProgressIndicator(),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: _detectFaces,
              child: Text('Detect Faces'),
            ),

            SizedBox(height: 16),

            // Display detected faces here using the '_faces' list
            Text('Detected Faces: ${_faces.length}'),
            for (final face in _faces)
              Text('Face Bounding Box: ${face.boundingBox}'),
          ],
        ),
      ),
    );
  }
}
