import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonWidgets {
  // button
  Widget button(
    String name,
    Function function,
    Color buttonColor,
    Color textColor,
    double width,
    double height,
  ) {
    return ElevatedButton(
      onPressed: () => function(),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        textStyle: const TextStyle(fontSize: 15.0, fontFamily: "Poppins"),
        minimumSize: Size(width, height),
      ),
      child: Text(name),
    );
  }

  // no icon input
  Widget noIconnInput(
    TextEditingController deviceName,
    String inputHintText,
    type,
  ) {
    return TextField(
      // onSubmitted: submitDeviceNameFunction(),
      keyboardType: type,
      controller: deviceName,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: inputHintText,
        contentPadding: const EdgeInsets.only(bottom: 7.0, left: 5.0),
      ),
      style: const TextStyle(fontSize: 16.0),
    );
  }

  SnackbarController errorSnackbar(String title, String message) {
    return Get.snackbar(
      title,
      message,
      // backgroundColor: const Color(0xff43b5e3),
      backgroundColor: Colors.white,
      borderWidth: 1.5,
      borderColor: const Color(0xff43b5e3),
      colorText: Colors.red,
      // margin: const EdgeInsets.all(30.0),
      borderRadius: 10.0,
      duration: const Duration(milliseconds: 1500),
      padding: const EdgeInsets.only(bottom: 18.0, left: 18.0),
      dismissDirection: DismissDirection.down,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
