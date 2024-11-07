import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  List<Widget> _soundWidgetList = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 122, 122, 122),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _soundWidgetList.add(SoundWidget());
            });
          },
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _soundWidgetList,
            ),
        ),
      ),
    );
  }
}

//widget to handle each individual sound that the user wants to create
class SoundWidget extends StatefulWidget {
  const SoundWidget({super.key});

  @override
  State<SoundWidget> createState() => _SoundWidgetState();
}

class _SoundWidgetState extends State<SoundWidget> {
  //variables and stored data for the specific sound go here
  final TextEditingController _controller = TextEditingController();
  final player = AudioPlayer();
  String fileName = 'file name here';
  FilePickerResult? result;
  double volume = 1.0;

  @override
  void dispose() {
    //clean up controller if the widget gets deleted (still need to impliment widget deletion)

    _controller.dispose();
    super.dispose();
  }

  void UpdateText(String newText) { //called to update text when a file is selected
    setState(() {
      fileName = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container( //base box with drop shadow
          height: 200,
          width: 300,
          margin: const EdgeInsets.only(left: 30, top: 20, right: 10, bottom: 50),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 199, 199, 199),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        Positioned( //agonizingly structured text box for sound name
          top: 20,
          left: 30,
          child: SizedBox(
            height: 100,
            width: 250,
            child: 
            TextField(
              controller: _controller,
              //expands: true,
              decoration: const InputDecoration(
                labelText: 'Sound Name',
                icon: Icon(Icons.music_note),
              ),
            ),
          ),
        ),
        Positioned( //file select
            top: 80,
            left: 60,
            child: Container(
              height: 100,
              width: 250,
              child: Wrap(
                spacing: 10,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(fontSize: 18.00),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                    result = await FilePicker.platform.pickFiles(type: FileType.audio); //we are politely asking for audio files only please
                    if (result != null) {
                      UpdateText(result!.files.first.name); //update text to reflect file selection
                      await player.setSource(DeviceFileSource(result!.files.first.path!)); //we know theres a valid path returned here, set the path to be played by the audio player
                    }
                    }, 
                    child: 
                    const Text('Select File')
                  )
                ],
              ),
            )
          ),
        Positioned( //buttons to play and control audio
          top: 120,
          left: 45,
          child: Container(
            height: 100,
            width: 300,
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await player.resume();
                  }, 
                  child: const Text('Play')
                ),
                Slider(
                  value: volume, 
                  min: 0,
                  max: 1,
                  divisions: 100,
                  label: (volume*100).round().toString(),
                  onChanged: (double value) async {
                    setState(() {
                      volume = value;
                    });
                    await player.setVolume(volume);
                  }
                )
              ],
            ),
          )
          )
      ],
    );
  }
}
