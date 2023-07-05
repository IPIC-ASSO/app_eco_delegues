import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GrosPlan extends StatefulWidget {
  final String url;

  GrosPlan({Key? key,  required this.url})
      :super(key: key);


  @override
  _GrosPlanState createState() => _GrosPlanState();
}

class _GrosPlanState extends State<GrosPlan> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold (
        body: Center(
            child: CachedNetworkImage(
              imageUrl: widget.url,
            ),
          ),

      ),
      onTap: () {Navigator.pop(context);},
    );
  }
}