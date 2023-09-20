import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/data_sources/supabase_service.dart';
import '../../widgets/elevated_button_component.dart';
import '../../widgets/inputField_with_heading.dart';
import '../../widgets/top_bar_back_action.dart';

class RetreiveTunnelMACPage extends StatefulWidget {
  const RetreiveTunnelMACPage({super.key});

  @override
  State<RetreiveTunnelMACPage> createState() => _RetreiveTunnelMACPageState();
}

class _RetreiveTunnelMACPageState extends State<RetreiveTunnelMACPage> {
  final TextEditingController _macAddressController = TextEditingController();

  late final dynamic pinTunnelID;

  Future<Either<Exception, bool>> checkMacInDatabase() async {
    try {
      final databaseResponse = await supabaseManager.supabaseClient
          .from("pintunnel")
          .select()
          .eq("mac_address", _macAddressController.text);
      if (databaseResponse.length == 0) {
        throw Either.left(Exception("No device with such a MAC address"));
      } else {
        pinTunnelID = databaseResponse[0]["id"];
        return Either.right(databaseResponse.length > 0);
      }
    } catch (e) {
      return Either.left(Exception(e.toString()));
    }
  }

  void updateProfile() async {
    final Either databaseResponse = await checkMacInDatabase();

    databaseResponse.fold(
        ifRight: (r) async => {
              if (r)
                {
                  await supabaseManager.supabaseClient
                      .from("profiles")
                      .update({"pintunnel_id": pinTunnelID}).eq(
                          "id", supabaseManager.user?.id),
                  GoRouter.of(context).go("/dashboard/:email")
                }
            },
        ifLeft: (l) => {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l.toString()),
                backgroundColor: const Color.fromARGB(156, 255, 1, 1),
              ))
            });
  }

  @override
  void dispose() {
    super.dispose();
    _macAddressController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const TopBarBackAction(),
        body: Center(
            child: FractionallySizedBox(
                widthFactor: 0.9,
                heightFactor: 0.8,
                child: Column(
                  children: [
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Connect a tunnel",
                            style: TextStyle(fontSize: 25, letterSpacing: 4),
                          )
                        ]),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 70, 0, 10),
                        child: Column(children: [
                          Container(
                              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: InputFieldWithHeading(
                                controller: _macAddressController,
                                heading: "Let's find your device",
                                placeHolder: "MAC Address",
                              )),
                        ])),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: ElevatedButtonComponent(
                          onPressed: () {
                            updateProfile();
                          },
                          text: "Next",
                        )),
                  ],
                ))));
  }
}
