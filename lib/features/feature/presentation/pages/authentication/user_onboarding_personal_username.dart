import 'package:dart_either/dart_either.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_tunnel_application_production/features/feature/data/data_sources/supabase_service.dart';

import '../../widgets/elevated_button_component.dart';
import '../../widgets/inputField_with_heading.dart';
import '../../widgets/top_bar_back_action.dart';

class OnBoardingUsernamePage extends StatefulWidget {
  const OnBoardingUsernamePage({super.key});

  @override
  State<OnBoardingUsernamePage> createState() => _OnBoardingUsernamePageState();
}

class _OnBoardingUsernamePageState extends State<OnBoardingUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();

  Future<Either<Exception, void>> uploadToDatabase() async {
    try {
      await supabaseManager.supabaseClient.from("profiles").update({
        "username": _usernameController.text,
        "finishedOnBoarding": true,
      }).eq(
        "id",
        supabaseManager.user?.id,
      );
      return const Either.right(null);
    } catch (e) {
      return Either.left(
          Exception("Unexpected error occured while uploading data"));
    }
  }

  void getUsername() async {
    final uploadResult = await uploadToDatabase();
    uploadResult.fold(
        ifRight: (r) =>
            {GoRouter.of(context).go("/signup/onboarding-tunnel-mac")},
        ifLeft: (l) => {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l.toString()),
                backgroundColor: const Color.fromARGB(156, 255, 1, 1),
              ))
            });
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
                                controller: _usernameController,
                                heading: "How should we call you?",
                                placeHolder: "Username",
                              )),
                        ])),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: ElevatedButtonComponent(
                          onPressed: () {
                            getUsername();
                          },
                          text: "Next",
                        )),
                  ],
                ))));
    ;
  }
}
