import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/providers/theme_provider.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_icon_button.dart';
import 'package:delivery_apps/core/services/firebase_auth_service.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/profile/screen/edit_profile.dart';
import 'package:delivery_apps/features/profile/screen/login_view.dart';
import 'package:delivery_apps/features/home/screen/main_screen.dart';
import 'package:delivery_apps/features/profile/screen/change_password_screen.dart';
import 'package:delivery_apps/features/profile/screen/shipper_registration_view.dart';
import 'package:delivery_apps/features/profile/screen/restaurant_registration_view.dart';
import 'package:delivery_apps/features/home/screen/address_list_screen.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  final FirebaseAuthService _firebaseService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      user = UserModel(
          id: 0,
          uid: fbUser.uid,
          name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
          email: fbUser.email ?? '',
          role: UserRole.USER,
          createdAt: DateTime.now());
    }
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final currentUser = await BackendService().getMe();
      if (mounted) setState(() => user = currentUser);
    } catch (e) {
      // Fallback already handled in initState
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final themeProvider = ThemeProviderScope.of(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: AppColor.container(context),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SafeArea(
                  child: Row(
                    children: [
                      RoundIconCircle(
                        icon: const Icon(Icons.arrow_back_ios_new_outlined),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        ),
                      ),
                      const Spacer(),
                      Text("Profile",
                          style: AppTextStyle.body(context,
                              color: AppColor.textTitle(context))),
                      const Spacer(),
                      RoundIconCircle(
                          onTap: () {},
                          icon: const Icon(Icons.settings_outlined)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: AppColor.inputFill(context),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            width: media.width * 0.35,
                            height: media.width * 0.35,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(media.width * 0.175),
                              color: AppColor.container(context),
                            ),
                            child: ClipOval(
                              child: user?.avatarUrl != null &&
                                      user!.avatarUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: user!.avatarUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : Image.asset("assets/image/avata.jpg",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity),
                            ),
                          ),
                        Text(
                            user?.name ?? "New Guest",
                          style: AppTextStyle.body(context,
                              fontSize: 20,
                              color: AppColor.textTitle(context)),
                        ),
                        Text(
                          user?.email ?? "",
                          style: AppTextStyle.body(context,
                              fontSize: 15,
                              color: AppColor.textSecondary(context)),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                                if (user != null)
                                  _menuItem(context, Icons.edit_outlined,
                                      "Edit profile", onTap: () async {
                                    final result =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              EditProfileScreen(user: user!)),
                                    );
                                    if (result == true) {
                                      _getCurrentUser();
                                    }
                                  }),
                                const SizedBox(height: 10),
                              _menuItem(
                                  context,
                                  Icons.favorite_border_outlined,
                                  "Favorite",
                                  onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => const MainScreen(
                                                initialIndex: 2)),
                                      )),
                              const SizedBox(height: 10),
                              _menuItem(context, Icons.location_on_outlined,
                                  "Location",
                                    onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const AddressListScreen()),
                                        )),
                                if (user?.role == UserRole.USER) ...[
                                  const SizedBox(height: 10),
                                  _menuItem(context, Icons.delivery_dining,
                                      "Register as Shipper",
                                      onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ShipperRegistrationView()),
                                          )),
                                  const SizedBox(height: 10),
                                  _menuItem(context, Icons.storefront,
                                      "Open a Restaurant",
                                      onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const RestaurantRegistrationView()),
                                          )),
                                ],
                              const SizedBox(height: 10),
                                // _menuItem(
                                //     context, Icons.history_outlined, "History",
                                //     onTap: () {}),
                                // const SizedBox(height: 10),
                                // _menuItem(
                                //     context, Icons.error_outline, "About",
                                //     onTap: () {}),
                              const SizedBox(height: 10),
                              _DarkModeToggle(
                                  provider: themeProvider,
                                  onToggle: () =>
                                      themeProvider.toggleTheme(context),
                              ),
                                // const SizedBox(height: 10),
                                // _menuItem(
                                //     context, Icons.lock_outlined, "Change password",
                                //     onTap: () => Navigator.of(context).push(
                                //           MaterialPageRoute(
                                //               builder: (_) =>
                                //                   const ChangePasswordScreen()),
                                //         )),
                              const SizedBox(height: 10),
                              _menuItem(context, Icons.logout_outlined, "Log out",
                                  onTap: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginView()),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label,
      {required VoidCallback onTap}) {
    return RoundIconButton(
      preIcon: icon,
      onPress: onTap,
      txt: Text(label,
          style: AppTextStyle.body(context,
              fontSize: 18, color: AppColor.textBody(context))),
    );
  }
}

class _DarkModeToggle extends StatelessWidget {
  final ThemeProvider provider;
  final VoidCallback onToggle;

  const _DarkModeToggle({required this.provider, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    bool isSys = provider.isSystem;
    bool isD = provider.isDark ||
        (isSys && MediaQuery.of(context).platformBrightness == Brightness.dark);

    String label = isSys ? "System Mode" : (isD ? "Dark Mode" : "Light Mode");
    IconData iconData = isSys
        ? Icons.settings_system_daydream
        : (isD ? Icons.dark_mode : Icons.light_mode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColor.textSecondary(context).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(iconData,
                  size: 27, color: AppColor.primary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: AppTextStyle.body(context,
                        fontSize: 18, color: AppColor.textBody(context))),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isD,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppColor.primary(context),
                  activeTrackColor:
                      AppColor.primary(context).withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

