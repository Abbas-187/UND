import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';

class VoiceAIWidget extends StatefulWidget {
  final Function(String) onSpeechResult;

  const VoiceAIWidget({Key? key, required this.onSpeechResult})
      : super(key: key);

  @override
  _VoiceAIWidgetState createState() => _VoiceAIWidgetState();
}

class _VoiceAIWidgetState extends State<VoiceAIWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    // TODO: Add permission handling using permission_handler package
    // var status = await Permission.microphone.request();
    // if (status != PermissionStatus.granted) {
    //   print("Microphone permission not granted");
    //   return;
    // }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.finalResult) {
              widget.onSpeechResult(_text);
              _isListening = false; // Stop listening after final result
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      onPressed: _listen,
      tooltip: 'Voice Input',
    );
  }
}
