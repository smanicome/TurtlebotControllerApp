import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';

/// The second page
/// First person view of the field in the background
/// Joystick to move the robot
class ControllerPage extends StatefulWidget {
  final Socket inputControlSocket;
  final Socket cameraStreamSocket;

  const ControllerPage({
    key,
    required this.cameraStreamSocket,
    required this.inputControlSocket,
  }) : super(key: key);

  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  // Data read from the socket
  final List<int> _imageStreamData = [];
  // Data of the image to display
  Uint8List _imgData = Uint8List.fromList([]);
  // Size of the next image to read
  int _sizeOfNextImage = 0;
  // Stream socket listener
  late StreamSubscription _streamListener;
  // Values to display on screen
  double angle = 0;
  double speed = 0;
  bool _canSendInput = true;
  Timer _stopper = Timer(const Duration(seconds: 0), () {});
  Timer _delayer = Timer(const Duration(seconds: 0), () {});

  late final JoystickView _joystick;

  // Cancel timers and listener and close sockets
  @override
  void dispose() {
    widget.inputControlSocket.close();
    widget.cameraStreamSocket.close();
    _streamListener.cancel();
    _stopper.cancel();
    _delayer.cancel();

    super.dispose();
  }

  void _handleImageStream(List<int> event) {
    setState(() {
      _imageStreamData.addAll(event);
      // if image size unknown, read size
      if (_sizeOfNextImage == 0) {
        // if there is enough data to read size, read it
        if (_imageStreamData.length > 8) {
          // read int on 64 bytes
          _sizeOfNextImage = ByteData.sublistView(
            Uint8List.fromList(
              _imageStreamData.sublist(0, 8),
            ),
            0,
            8,
          ).getInt64(0);
          // remove read data
          _imageStreamData.removeRange(0, 8);
        }
      }
      // if image size know, read image
      if (_sizeOfNextImage != 0) {
        // if there is enough data to read image, read it
        if (_imageStreamData.length >= _sizeOfNextImage) {
          _imgData =
              Uint8List.fromList(_imageStreamData.sublist(0, _sizeOfNextImage));
          // remove read data
          _imageStreamData.removeRange(0, _sizeOfNextImage);
          // image was read, so sets size of next to zero
          _sizeOfNextImage = 0;
        }
      }
    });
  }

  void _handleInputChange(double angle, double speed) {
    // Delay after each movement updates to not jam
    if(!_canSendInput) return;
    _canSendInput = false;
    _delayer = Timer(const Duration(milliseconds: 500), () {
      _canSendInput = true;
    });

    // Send data to server
    var msg = Float32List.fromList([speed, angle]).buffer.asByteData();
    widget.inputControlSocket.add(msg.buffer.asInt8List());

    // After a period of inactivity, makes the robot stop
    if(_stopper.isActive) _stopper.cancel();
    _stopper = Timer(const Duration(seconds: 2), () {
      var msg = Float32List.fromList([0.0, 0.0]).buffer.asByteData();
      widget.inputControlSocket.add(msg.buffer.asInt8List());
    });
  }

  @override
  void initState() {
    // Initialise joystick here to avoid flickering
    _joystick = JoystickView(
      showArrows: false,
      backgroundColor: Colors.blueGrey.withOpacity(0.7),
      innerCircleColor: Colors.blueGrey.withOpacity(0.7),
      onDirectionChanged: _handleInputChange,
    );

    // Start listening to image stream
    _streamListener = widget.cameraStreamSocket.listen(_handleImageStream);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Image.memory(
                  _imgData,
                  gaplessPlayback: true, // prevent image flickering
                ),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: Text(
                  "Angle: $angle, Speed: $speed",
                  textScaleFactor: 2,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                )
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: _joystick,
              )
            ],
          ),
        ),
      ),
    );
  }
}
