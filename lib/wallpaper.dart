import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper/fullscreen.dart';

class Wallpaper extends StatefulWidget {
  const Wallpaper({super.key});

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  void initState() {
    super.initState();
    initBannerAd();
    fetchapi();
  }

  late BannerAd bannerAd;
  bool isAdLoaded = false;
  var adUnit = "ca-app-pub-3940256099942544/9214589741"; // teating id

  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnit,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print(error);
        },
      ),
      request: AdRequest(),
    );
    bannerAd.load();
  }

  List images = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchapi();
  // }

  Future<void> fetchapi() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=80&page=$page'),
        headers: {
          'Authorization':
              'QNlVccChudAMvS5SiGcJE67a8sT4frsJfpnlHF9nZSTMYCsZNwqACktn'
        },
      );

      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);
        setState(() {
          images.addAll(result['photos']);
          isLoading = false;
          hasMore = result['photos'].length == 80;
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void loadmore() {
    if (hasMore) {
      setState(() {
        page++;
      });
      fetchapi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                childAspectRatio: 2 / 3,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreen(
                          imageurl: images[index]['src']['large2x'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.white,
                    child: Image.network(
                      images[index]['src']['tiny'],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && hasMore)
            InkWell(
              onTap: loadmore,
              child: Container(
                height: 60,
                width: double.infinity,
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'LOAD MORE...',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: isAdLoaded
          ? SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
              child: AdWidget(ad: bannerAd),
            )
          : SizedBox(),
    );
  }
}
