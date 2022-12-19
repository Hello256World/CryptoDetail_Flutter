import 'package:crypto_detail/data/constant/constants.dart';
import 'package:crypto_detail/data/models/crypto.dart';
import 'package:crypto_detail/pages/crypto_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('images/logo.png'),
            ),
            SpinKitWave(
              color: Colors.white,
              size: 40.0,
            ),
          ],
        ),
      ),
    );
  }

  void getData() async {
    try {
      var response = await Dio().get('https://api.coincap.io/v2/assets');
      List<Crypto> cryptoList = response.data['data']
          .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
          .toList();

      await Future.delayed(
        Duration(seconds: 3),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CryptoScreen(
            cryptoList: cryptoList,
          ),
        ),
      );
    } catch (e) {
      final snakBar = SnackBar(
        content: Text('Check Your internet Connection'),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snakBar);

      await Future.delayed(Duration(seconds: 2));

      getData();
    }
  }
}
