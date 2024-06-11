// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:type_text/type_text.dart';
import 'api_client.dart';

class ResponseScreen extends StatefulWidget {
  static const String id = 'response_screen';
  final InputImage imageInput;
  final File imageFile;

  const ResponseScreen(
      {super.key, required this.imageInput, required this.imageFile});

  @override
  State<ResponseScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  String _extractedText = "";
  List<String> dissList = [];

  final ValueNotifier<bool> _loading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();

    processImage(widget.imageInput);
  }

  Future<void> processImage(inputImage) async {
    _loading.value = true;
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String extractedText = "";

    for (TextBlock block in recognizedText.blocks) {
      String blockText = "";

      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          // Extracted text from the image
          String text = element.text;

          // Check if the text contains only alphabets, digits, and spaces
          if (RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(text)) {
            blockText += text.trim() + " ";
          }
        }
      }

      // Remove extra spaces and add a new line for each block
      if (blockText.trim().isNotEmpty) {
        extractedText += blockText.trim() + "\n";
      }
    }

    _extractedText = extractedText.trim();
    print(_extractedText);
    var response = await ApiClient().post("diss", {"prompt": _extractedText});

    String diss = response.body.toString().trim();
    dissList.add(diss);

    _loading.value = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 70,
          title: Image.asset(
            'assets/images/Logo.png',
            height: 35,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent),
      backgroundColor: const Color.fromARGB(20, 20, 20, 1),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.lightbulb_outline_rounded),
        label: const Text('Get Diss Reply'),
        onPressed: () {
          HapticFeedback.heavyImpact();
          processImage(widget.imageInput);
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 30, right: 30, bottom: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 20, right: 20, bottom: 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        20), // Adjust the radius as needed
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9956FF)
                            .withOpacity(0.3), // Drop shadow color with opacity
                        spreadRadius: 2,
                        blurRadius: 60,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      widget.imageFile,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 1, width: 70, color: Colors.white),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "tap a reply to copy",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    Container(height: 1, width: 70, color: Colors.white),
                  ],
                ),
              ),
              Column(
                verticalDirection: VerticalDirection.up,
                children: [
                  const SizedBox(height: 50),
                  for (var i = 0; i < dissList.length; i++)
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: dissList[i]));
                        HapticFeedback.lightImpact();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 20, 20, 20),
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9956FF).withOpacity(
                                    0.2), // Drop shadow color with opacity
                                spreadRadius: 2,
                                blurRadius: 50,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TypeText(
                                duration: const Duration(seconds: 2),
                                dissList[i],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder(
                        valueListenable: _loading,
                        builder: (context, value, child) => _loading.value
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 20, 20, 20),
                                    borderRadius: BorderRadius.circular(
                                        20), // Adjust the radius as needed
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9956FF).withOpacity(
                                            0.3), // Drop shadow color with opacity
                                        spreadRadius: 2,
                                        blurRadius: 50,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10),
                                      child: SizedBox(
                                        width: 30,
                                        child: LoadingAnimationWidget.waveDots(
                                            color: Colors.white, size: 35),
                                      )),
                                ),
                              )
                            : const SizedBox()),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
