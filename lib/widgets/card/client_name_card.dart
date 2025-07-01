import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'package:jaguar_x_print/models/contact_model.dart';

class ClientNameCard extends StatelessWidget {
  final Contact contact;
  final String page;

  const ClientNameCard({
    super.key,
    required this.contact,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: color3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: Adaptive.w(95),
          padding: EdgeInsets.symmetric(horizontal: Adaptive.w(4), vertical: 12),
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Partie Nom avec limite de largeur
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: Adaptive.w(4)),
                  child: Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: Adaptive.sp(20),
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),

              // Partie Pagination
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Page",
                      style: TextStyle(
                        fontSize: Adaptive.sp(14),
                        color: whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      page,
                      style: TextStyle(
                        fontSize: Adaptive.sp(20),
                        color: whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}