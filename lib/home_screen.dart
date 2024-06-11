// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:diss_flutter_app/response_screen.dart';
import 'package:diss_flutter_app/service/ad_mod_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
  InputImage? inputImage;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _createRewardedAd();
  }

  Future _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _imageFile = File(pickedFile!.path);
      inputImage = InputImage.fromFilePath(pickedFile.path);
    });

    if (_imageFile != null && inputImage != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ResponseScreen(imageInput: inputImage!, imageFile: _imageFile!)));
      // _showRewardedAd();
    }
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdMobService.rewardedAdUnitId!,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
            onAdFailedToLoad: (error) {
              setState(() => _rewardedAd = null);
              Navigator.pop(context);
            }));
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createRewardedAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createRewardedAd();
      });
      _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => ResponseScreen(
                      imageInput: inputImage!, imageFile: _imageFile!))));
      _rewardedAd = null;
      print("lol");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(20, 20, 20, 1),
      appBar: AppBar(
        toolbarHeight: 70,
        title: Image.asset(
          'assets/images/Logo.png',
          height: 35,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 0, left: 30, right: 30, bottom: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.indigo.shade400, Colors.deepPurple]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text(
                        "Upload a Screenshot",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "or enter text manually",
                style: TextStyle(
                    color: Color.fromARGB(20, 20, 20, 1), fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }
}
