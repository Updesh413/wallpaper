import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

class FullScreen extends StatefulWidget {
  final String imageurl;
  const FullScreen({super.key, required this.imageurl});

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  bool _isLoading = false;
  String _message = '';

  Future<void> setwallpaper() async {
    setState(() {
      _isLoading = true;
      _message = 'Setting wallpaper...';
    });

    try {
      int location = WallpaperManager.HOME_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageurl);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);

      setState(() {
        _isLoading = false;
        _message =
            result ? 'Wallpaper set successfully!' : 'Failed to set wallpaper.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Image.network(widget.imageurl),
              ),
            ),
            if (_isLoading) CircularProgressIndicator(),
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _message,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            InkWell(
              onTap: () {
                setwallpaper();
              },
              child: Container(
                height: 60,
                width: double.infinity,
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Set Wallpaper',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
