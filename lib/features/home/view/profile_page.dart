import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/pages/custom_circular_indicator.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/features/home/bloc/profile_page_bloc.dart';

import '../../../common/enum_status.dart';
import '../../../common/global/mixin/pop_up_pin_page.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/router/router_utils.dart';
import '../../../common/global/widgets/confirmation_dialog.dart';
import '../../../common/global/widgets/custom_outline_button.dart';
import '../../../common/global/widgets/custom_tile.dart';
import '../../../core/domain/entities/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with ErrorHandlingMixin, PopUpPin {
  var _bloc;
  ProfileModel? dataProfile;
  bool isLoadingGetProfile = false;

  @override
  void initState() {
    super.initState();

    _initializeBloc();

    // Invoke Bloc event after initial frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.add(const ProfilePageDidload());
    });
  }

  void _initializeBloc() {
    _bloc = context.read<ProfilePageBloc>();
  }

  @override
  Widget build(BuildContext context) {
    void showPopUp() {
      AppRouter.router
          .push(PAGES.pinPage.screenPath, extra: {'pinType': 'setPin'});
      Navigator.of(context).pop();
    }

    void showPopUpUpdatePin() {
      AppRouter.router.push(PAGES.pinPage.screenPath,
          extra: {'pinType': 'verifyPin', 'doJobFor': 'changePin'});
      Navigator.of(context).pop();
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                automaticallyImplyLeading: false,
              ),
              Expanded(
                child: BlocConsumer<ProfilePageBloc, ProfilePageState>(
                  listener: (context, state) {
                    if (state.status == RequestStatus.success) {
                      switch (state.operation) {
                        case 'logoutState':
                          break;
                        case 'checkPinExist':
                          if (state.pinData?.isExist ?? false) {
                            showPopUpNotYetSetPin(
                              context,
                              'Mengubah PIN',
                              'Mengubah PIN saat ini akan mengubah semua \nPIN yang ada pada product komerce.\nYakin untuk melanjutkan ? ',
                              'assets/images/ic_disapointed.svg',
                              'Lanjutkan',
                              onButtonPressed: showPopUpUpdatePin,
                            );
                          } else {
                            showPopUpNotYetSetPin(
                              context,
                              'Kamu Belum Membuat PIN',
                              'PIN digunakan untuk melindungi akun kamu. Yuk buat sekarang',
                              'assets/images/ilustrated-setpin.svg',
                              'Buat PIN',
                              onButtonPressed: showPopUp,
                            );
                          }
                          break;
                      }
                    } else if (state.status == RequestStatus.failure) {
                      handleFailureState(context, state, state.message);
                    }
                  },
                  builder: (context, state) {
                    if (state.operation == 'getProfile') {
                      switch (state.status) {
                        case RequestStatus.loading:
                          isLoadingGetProfile = true;
                          break;

                        case RequestStatus.success:
                          isLoadingGetProfile = false;
                          dataProfile = state.profileData;
                          break;

                        default:
                          isLoadingGetProfile = false;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          isLoadingGetProfile
                              ? _ProfileRowPlaceholder()
                              : ProfileRow(
                                  imageUrlNetwork: dataProfile?.photoProfileUrl,
                                  name: dataProfile?.fullname ?? '',
                                  id: dataProfile?.id.toString() ?? '0',
                                ),
                          const SizedBox(height: 32.0),
                          CustomTile(
                            title: Strings.label_information,
                            leadingIcon: SvgPicture.asset(
                                'assets/images/ic-profile-circle.svg'),
                            trailingIcon: SvgPicture.asset(
                                'assets/images/ic-arrow-right.svg'),
                            onTap: () => AppRouter.router
                                .push(PAGES.profileInfo.screenPath),
                          ),
                          CustomTile(
                            title: Strings.label_change_pass,
                            leadingIcon: SvgPicture.asset(
                                'assets/images/ic-security-safe.svg'),
                            trailingIcon: SvgPicture.asset(
                                'assets/images/ic-arrow-right.svg'),
                            onTap: () => AppRouter.router
                                .push(PAGES.changePassword.screenPath),
                          ),
                          CustomTile(
                            title: 'Atur PIN',
                            leadingIcon:
                                SvgPicture.asset('assets/images/ic-lock.svg'),
                            trailingIcon: SvgPicture.asset(
                                'assets/images/ic-arrow-right.svg'),
                            onTap: () {
                              final mainBloc = context.read<ProfilePageBloc>();
                              mainBloc.add(const NextPressedButtonEvent());
                            },
                          ),
                          CustomTile(
                            title: Strings.label_unhire_talent,
                            leadingIcon:
                                state.profileData?.accountStatus == "off"
                                    ? SvgPicture.asset(
                                        'assets/images/ic-unhire-note.svg',
                                        colorFilter: const ColorFilter.mode(
                                            inActiveGray, BlendMode.srcIn))
                                    : SvgPicture.asset(
                                        'assets/images/ic-unhire-note.svg'),
                            trailingIcon:
                                state.profileData?.accountStatus == "off"
                                    ? SvgPicture.asset(
                                        'assets/images/ic-arrow-right.svg',
                                        colorFilter: const ColorFilter.mode(
                                            inActiveGray, BlendMode.srcIn))
                                    : SvgPicture.asset(
                                        'assets/images/ic-arrow-right.svg'),
                            onTap: () =>
                                state.profileData?.accountStatus == "off"
                                    ? null
                                    : AppRouter.router
                                        .push(PAGES.unhirePage.screenPath),
                            isActive: state.profileData?.accountStatus == "off"
                                ? false
                                : true,
                          ),
                          const SizedBox(height: 24.0),
                          SizedBox(
                            width: double.infinity,
                            child: CustomOutlineButton(
                              text: Strings.label_logout,
                              onPressed: () {
                                final mainBloc =
                                    context.read<ProfilePageBloc>();
                                showLogoutConfirmation(context, mainBloc);
                              },
                              icon: SvgPicture.asset(
                                  'assets/images/ic-logout.svg'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const LoadingOverlayWidget(), // This is your new widget
        ],
      ),
    );
  }

  Widget _ProfileRowPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 60.0, // approximate width of your Profile picture
            height: 60.0, // approximate height of your Profile picture
            color: f4Gray,
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width:
                    MediaQuery.of(context).size.width * 0.6, // estimated width
                height: 20.0, // estimated height for name
                color: f4Gray,
              ),
              const SizedBox(height: 8.0),
              Container(
                width: MediaQuery.of(context).size.width *
                    0.4, // estimated width for ID
                height: 14.0, // estimated height for ID
                color: f4Gray,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showLogoutConfirmation(BuildContext context, ProfilePageBloc mainBloc) {
    ConfirmationDialog.show(
      context,
      onYesPressed: () {
        mainBloc.add(const LogoutButtonPressedEvent());
        Navigator.of(context).pop();
      },
      onNoPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}

class LoadingOverlayWidget extends StatelessWidget {
  const LoadingOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfilePageBloc, ProfilePageState>(
        builder: (context, state) {
      if ((state.operation == 'logoutState' ||
              state.operation == 'checkPinExist') &&
          state.status == RequestStatus.loading) {
        return _buildLoadingOverlay();
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black38,
        child: const Center(
          child: FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: CustomCircularIndicator(),
          ),
        ),
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final String name;
  final String id;
  final String? imageUrlNetwork;

  const ProfileRow(
      {Key? key,
      required this.name,
      required this.id,
      required this.imageUrlNetwork})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ProfileAvatar(
          backgroundImage: imageUrlNetwork ??
              'https://placehold.jp/34A853/ffffff/150x150.png?text=${getInitials(name)}',
        ),
        const SizedBox(width: 10),
        ProfileDetails(
          name: name,
          id: id,
        ),
      ],
    );
  }

  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'No Name';
    }

    final names = name.trim().split(" ");
    if (names.isEmpty) {
      return 'No Name'; // return 'No Name' if names list is empty
    }

    if (names.length > 1) {
      final firstName = names[0];
      final lastName = names[names.length - 1];
      return "${firstName[0]}${lastName[0]}";
    } else {
      return names[0]
          [0]; // access the first character of the first item in names list
    }
  }

  Color getRandomColor() {
    final random = Random();
    final colorCode = random.nextInt(0xFFFFFF);
    return Color(colorCode).withValues(alpha: 1.0);
  }
}

class ProfileAvatar extends StatelessWidget {
  final String backgroundImage;

  const ProfileAvatar({Key? key, required this.backgroundImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.0, // Set the desired width
      height: 60.0, // Set the desired height
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: backgroundImage,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final String name;
  final String id;

  const ProfileDetails({Key? key, required this.name, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // Make the text bold
          ),
        ),
        const SizedBox(height: 5),
        Text(id, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
