import 'package:crypto_detail/data/constant/constants.dart';
import 'package:crypto_detail/data/models/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CryptoScreen extends StatefulWidget {
  CryptoScreen({super.key, required this.cryptoList});

  List<Crypto> cryptoList;

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  List<Crypto>? cryptoList;
  DateTime? lastPressed;
  bool isSearchEmpty = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cryptoList = widget.cryptoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: _getAppBar(),
      body: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          final maxDuration = Duration(seconds: 2);
          final isWarning =
              lastPressed == null || now.difference(lastPressed!) > maxDuration;

          if (isWarning) {
            lastPressed = DateTime.now();
            final snakBar = SnackBar(
              content: Text('Double Tap To Close'),
              duration: maxDuration,
            );

            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(snakBar);

            return false;
          } else {
            return true;
          }
        },
        child: getBody(),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return AppBar(
      title: Text(
        'کیرپتوبازار',
        style: TextStyle(fontFamily: 'morabaee'),
      ),
      backgroundColor: blackColor,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  Widget getBody() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                onChanged: (value) {
                  _getSearchResult(value);
                },
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
                maxLines: 1,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-z]'))
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: greenColor,
                  hintText: 'نام ارز مورد نظر را وارد کنید',
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: 'morabaee',
                    fontSize: 19.5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isSearchEmpty,
            child: Text(
              'درحال آپدیت رمزارزها ...',
              style: TextStyle(
                color: greenColor,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: greenColor,
              backgroundColor: blackColor,
              onRefresh: () async {
                var freshData = await _getFreshData();

                setState(() {
                  cryptoList = freshData;
                });
              },
              child: ListView.builder(
                itemCount: cryptoList!.length,
                itemBuilder: (context, index) {
                  return _getListTileItem(cryptoList![index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getListTileItem(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.name,
        style: TextStyle(color: greenColor),
      ),
      subtitle: Text(
        crypto.symbol,
        style: TextStyle(color: greyColor),
      ),
      leading: SizedBox(
        width: 30.0,
        child: Center(
          child: Text(
            crypto.rank.toString(),
            style: TextStyle(color: greyColor),
          ),
        ),
      ),
      trailing: SizedBox(
        width: 150.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(color: greyColor, fontSize: 16.0),
                ),
                Text(
                  crypto.changePercent24Hr.toStringAsFixed(2),
                  style: TextStyle(
                    color: _getLast24HrChangesColor(crypto.changePercent24Hr),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.0),
            _getTrailingIcon(crypto.changePercent24Hr)
          ],
        ),
      ),
    );
  }

  Widget _getTrailingIcon(double last24HrChange) {
    if (last24HrChange <= 0) {
      return Icon(
        Icons.trending_down,
        color: redColor,
        size: 25.0,
      );
    } else {
      return Icon(
        Icons.trending_up,
        color: greenColor,
        size: 25.0,
      );
    }
  }

  Color _getLast24HrChangesColor(double last24HrChanges) {
    if (last24HrChanges < 0) {
      return redColor;
    } else if (last24HrChanges > 0) {
      return greenColor;
    } else {
      return greyColor;
    }
  }

  Future<List<Crypto>> _getFreshData() async {
    int howMany = 0;
    try {
      var response = await Dio().get('https://api.coincap.io/v2/assets');
      List<Crypto> cryptoList = response.data['data']
          .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
          .toList();
      howMany++;
      return cryptoList;
    } catch (e) {
      if (howMany > 1) {
        final snakBar = SnackBar(
          content: Text('Check Your internet Connection'),
          duration: Duration(seconds: 2),
        );

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(snakBar);
      } else if (howMany > 2) {
        final snakBar = SnackBar(
          content: Text('Check Your VPN Connection'),
          duration: Duration(seconds: 2),
        );

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(snakBar);
      }
      return _getFreshData();
    }
  }

  Future<void> _getSearchResult(String searchText) async {
    List<Crypto> cryptoListBySearch = [];
    if (searchText.isEmpty) {
      setState(() {
        isSearchEmpty = true;
      });
      cryptoListBySearch = await _getFreshData();
      setState(() {
        isSearchEmpty = false;
        cryptoList = cryptoListBySearch;
      });
    }
    cryptoListBySearch = cryptoList!.where((element) {
      return element.name.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    setState(() {
      cryptoList = cryptoListBySearch;
    });
  }
}
