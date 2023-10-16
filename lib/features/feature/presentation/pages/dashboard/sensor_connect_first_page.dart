import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_tunnel_application_production/features/feature/presentation/widgets/top_bar_back_action.dart';

class SensorConnectFirstPage extends StatefulWidget {
  const SensorConnectFirstPage({super.key});

  @override
  State<SensorConnectFirstPage> createState() => _SensorConnectFirstPageState();
}

class _SensorConnectFirstPageState extends State<SensorConnectFirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const TopBarBackAction(),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Image(
                image: AssetImage("assets/pintunnel_image.png"),
                width: 359,
                height: 280,
              ),
              SizedBox(height: 10),
              Container(
                width: 359,
                height: 253,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFFD9D9D9),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("•", style: TextStyle(fontSize: 70)),
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("STEP 1",
                                  style: GoogleFonts.jetBrainsMono(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 0.1,
                                      fontWeight: FontWeight.w500
                                    )
                                  )),
                                  Text(
                                      "urna, id lacinia lorem molestie suscipit. In id sea",
                                      style: GoogleFonts.inter(
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 0.04,
                                        )
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "•",
                            style: TextStyle(fontSize: 70),
                          ),
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("STEP 2",
                                  style: GoogleFonts.jetBrainsMono(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 0.1,
                                      fontWeight: FontWeight.w500
                                    )
                                  )),
                                  Text(
                                      "urna, id lacinia lorem molestie suscipit. In id sea",
                                      style: GoogleFonts.inter(
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 0.04,
                                        )
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "•",
                            style: TextStyle(fontSize: 70),
                          ),
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("STEP 3",
                                  style: GoogleFonts.jetBrainsMono(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 0.1,
                                      fontWeight: FontWeight.w500
                                    )
                                  )),
                                  Text(
                                      "urna, id lacinia lorem molestie suscipit. In id sea",
                                      style: GoogleFonts.inter(
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 0.04,
                                        )
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 194,
                height: 44,
                child:  ElevatedButton(
                  child: Text(
                    "Next",
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontSize: 29,
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      GoRouter.of(context).push("/sensorConnectSecondPage");
                    });
                  },
                ),
              ),
            ],
          ),
        ));
  }
}