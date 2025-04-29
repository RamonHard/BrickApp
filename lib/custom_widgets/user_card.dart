import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserCard extends StatelessWidget {
  UserCard(
      {Key? key,
      required this.agentName,
      required this.agentIMG,
      required this.agentPhone,
      required this.agentEmail,
      required this.houseDescription,
      required this.onTap})
      : super(key: key);
  final String agentName, agentIMG, agentPhone, agentEmail, houseDescription;
  final Function() onTap;
  final TextStyle style = GoogleFonts.actor(
      fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(agentIMG),
        ),
        title: Text(agentName, style: style),
        subtitle: Text(
          '${houseDescription} room',
          style: GoogleFonts.actor(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 109, 109, 109),
          ),
        ),
        trailing: Text(
          agentEmail,
          style: GoogleFonts.actor(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 109, 109, 109),
          ),
        ),
      ),
    );
  }
}
