import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

const kButtonColor = Colors.teal;
const kBackgroundColor = Color(0xFF111328);
const kHeightButton = 50.0;
final TextStyle kButtonTextStyle = GoogleFonts.ptSans(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);
final TextStyle kAppBarTextStyle = GoogleFonts.roboto(
  fontWeight: FontWeight.bold,
);

playSound() {
  final player = AudioCache();
  player.play('Mask Audio.mp3');
  return SizedBox(
    height: 0,
  );
}
