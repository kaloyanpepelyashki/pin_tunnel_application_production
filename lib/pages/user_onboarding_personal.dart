import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_tunnel_application_production/classes/supabase_service.dart';
import 'package:pin_tunnel_application_production/components/inputField_with_heading.dart';
import 'package:pin_tunnel_application_production/components/top_bar_back_action.dart';
import "package:timezone/standalone.dart" as tz;

import '../classes/user_class.dart';
import '../components/elevated_button_component.dart';

class OnBoardingPersonalDataPage extends StatefulWidget {
  const OnBoardingPersonalDataPage({super.key});

  @override
  State<OnBoardingPersonalDataPage> createState() =>
      _OnBoardingPersonalDataPageState();
}

class _OnBoardingPersonalDataPageState
    extends State<OnBoardingPersonalDataPage> {
  //Inut field TextEditing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final _userProfile = userProfile;

  void uploadToDatabase() async {
    debugPrint("id: ${supabaseManager.user?.id}");
    tz.Location utc = tz.getLocation('UTC');
    await supabaseManager.supabaseClient.from("profiles").update({
      "email": supabaseManager.user?.email,
      "first_name": _nameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
      "updated_at": tz.TZDateTime.from(DateTime.now(), utc).toIso8601String(),
    }).eq("id", supabaseManager.user?.id);

    await supabaseManager.supabaseClient.from("tunnels").insert([
      {"owner_id": supabaseManager.user?.id}
    ]);
  }

  void populateUserProfile() {
    _userProfile.onboarding(
        _nameController.text.trim(),
        _lastNameController.text.trim(),
        supabaseManager.user?.email,
        DateTime.now(),
        supabaseManager.user?.id);
  }

  void getPersonalData() async {
    uploadToDatabase();
    populateUserProfile();
    GoRouter.of(context).go("/signup/onboarding-tunnel-mac");
  }

  @override
  void initState() {
    super.initState();
    _userProfile.empty();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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
                    const Text(
                      "Title",
                      style: TextStyle(fontSize: 40, letterSpacing: 17),
                    ),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 70, 0, 10),
                        child: Column(children: [
                          Container(
                              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: InputFieldWithHeading(
                                controller: _nameController,
                                heading: "A little bit about you",
                                placeHolder: "Name",
                              )),
                          Container(
                              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: TextField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                      hintText: "Last name",
                                      enabledBorder: OutlineInputBorder())))
                        ])),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: ElevatedButtonComponent(
                          onPressed: () {
                            getPersonalData();
                          },
                          text: "Next",
                        )),
                  ],
                ))));
    ;
  }
}