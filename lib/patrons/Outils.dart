import 'dart:typed_data';

import 'package:app_eco_delegues/patrons/Message.dart';
import 'package:flutter/material.dart';

Widget errorContainer() {
  return Container(
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      //color: AppColors.greyColor2,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Image.asset(
      'assets/error.png',
      height: 200,
      width: 200,

    ),
  );
}

Widget imageDatum({required Uint8List datum, required onTap}){
  return OutlinedButton(
      onPressed: onTap(),
      child: Image.memory(
        datum,
        width: 200,
        height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, object, stackTrace) {
          print(stackTrace);
          print(object);
            return (errorContainer());
          }
      ));
}


Widget chatImage({required String imageSrc, required Function onTap,}) {
  return OutlinedButton(
    onPressed: ()=> onTap(),
    child: Image.network(
      imageSrc,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder:
          (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            //color: AppColors.greyColor2,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 200,
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              //color: AppColors.burgundy,
              value: loadingProgress.expectedTotalBytes != null &&
                  loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, object, stackTrace) {
        print(object);
        return (errorContainer());
      }
  ),
  );
  }


Widget messageBubble(
    {required String corps,
      required EdgeInsetsGeometry? margin,
      BorderRadius? bords,
      Color? color,
      Color? textColor}) {
  return Container(
    padding: const EdgeInsets.all(10),
    margin: margin,
    width: 250,
    decoration: BoxDecoration(
      color: color,
      borderRadius: bords??BorderRadius.zero,
    ),
    child: SelectableText(
      corps,
      style: TextStyle(fontSize: 16, color: textColor),
    ),
  );
}