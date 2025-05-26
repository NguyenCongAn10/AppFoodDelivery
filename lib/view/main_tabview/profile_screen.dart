import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/roundIconCircle.dart';
import 'package:delivery_apps/common_widget/round_Icon_button.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/main_tabview/bottom_nav.dart';
import 'package:delivery_apps/view/main_tabview/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? currentUser = await _firebaseService.getCurrentUser();
    setState(() {
      user = currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: TColor.textfield,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  SafeArea(
                      child: Row(
                    children: [
                      RoundIconCircle(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ButtomNavigation(),
                          ));
                        },
                      ),
                      const Spacer(),
                      NormalText(color: Colors.black, txt: "Profile"),
                      const Spacer(),
                      RoundIconCircle(
                          onTap: () {},
                          icon: const Icon(Icons.settings_outlined))
                    ],
                  )),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Container(
                      width: media.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      child: Column(
                        spacing: 0,
                        children: [
                          const SizedBox(
                            height: 140,
                          ),
                          NormalText(
                            color: Colors.black,
                            txt: user?.displayName ?? "Nguyeen Cong An",
                            size: 20,
                          ),
                          NormalText(
                            color: Colors.black54,
                            txt: user?.email ?? "",
                            size: 15,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                spacing: 10,
                                children: [
                                  RoundIconButton(
                                    preIcon: Icons.edit,
                                    onPress: () {},
                                    txt: NormalText(
                                        color: Colors.black,
                                        txt: "Edit profile",
                                        size: 18),
                                  ),
                                  RoundIconButton(
                                    preIcon: Icons.favorite_border_outlined,
                                    onPress: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ButtomNavigation(
                                                  initialIndex: 2),
                                        ),
                                      );
                                    },
                                    txt: NormalText(
                                        color: Colors.black,
                                        txt: "Favorite",
                                        size: 18),
                                  ),
                                  RoundIconButton(
                                    preIcon: Icons.location_on_outlined,
                                    onPress: () {},
                                    txt: NormalText(
                                        color: Colors.black,
                                        txt: "Location",
                                        size: 18),
                                  ),
                                  RoundIconButton(
                                    preIcon: Icons.history_outlined,
                                    onPress: () {},
                                    txt: NormalText(
                                        color: Colors.black,
                                        txt: "History",
                                        size: 18),
                                  ),
                                  RoundIconButton(
                                    preIcon: Icons.error_outline,
                                    onPress: () {},
                                    txt: NormalText(
                                        color: Colors.black,
                                        txt: "About",
                                        size: 18),
                                  ),
                                  RoundIconButton(
                                    preIcon: Icons.lock_outlined,
                                    onPress: () {},
                                    txt: NormalText(
                                        color: Colors.black,
                                        txt: "Change password",
                                        size: 18),
                                  ),
                                  RoundIconButton(
                                    preIcon: Icons.logout_outlined,
                                    onPress: () {},
                                    txt: NormalText(
                                        color: Colors.black,
                                        txt: "Log out",
                                        size: 18),
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 110,
              left: (media.width - media.width * 0.35) / 2,
              child: Container(
                padding: const EdgeInsets.all(6),
                width: media.width * 0.35,
                height: media.width * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(media.width * 0.175),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    "assets/image/avata.jpg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
