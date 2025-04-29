import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class PopUpWidget extends StatelessWidget {
  const PopUpWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: HexColor("ffffff"),
      content: Container(
        width: 35,
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Payment Will be made in person once item is pysically observed',
                style: GoogleFonts.actor(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  height: 45,
                  minWidth: 100,
                  padding: EdgeInsets.all(8.0),
                  color: Color.fromARGB(255, 255, 0, 0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancle',
                    style: GoogleFonts.actor(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                MaterialButton(
                  height: 45,
                  minWidth: 120,
                  padding: EdgeInsets.all(8.0),
                  color: Color.fromARGB(255, 0, 255, 8),
                  onPressed: () {},
                  child: Text(
                    'Send Request',
                    style: GoogleFonts.actor(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
