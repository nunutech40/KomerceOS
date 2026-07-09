import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/enum_status.dart';
import '../../../common/styles.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/widgets/custom_desc_field.dart';
import '../../../common/global/widgets/custom_text_field.dart';
import '../../../common/utils/custom_date_format.dart';
import '../../../core/domain/entities/profile_model.dart';
import '../bloc/profile_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileInfoUpdatePage extends StatefulWidget {
  const ProfileInfoUpdatePage({Key? key}) : super(key: key);

  @override
  _ProfileInfoUpdatePageState createState() => _ProfileInfoUpdatePageState();
}

class _ProfileInfoUpdatePageState extends State<ProfileInfoUpdatePage>
    with ErrorHandlingMixin {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfilePageDidload());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == RequestStatus.failure) {
          handleFailureState(context, state, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(Strings.label_profile_info,
                style: AppTypography.interSemiBold16),
            leading: IconButton(
              icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
              onPressed: () {
                AppRouter.router.pop();
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: (state.status == RequestStatus.loading)
                    ? _buildProfileShimmer()
                    : (state.status == RequestStatus.success)
                        ? Column(
                            children: [
                              const SizedBox(height: 11),
                              ProfileRow(profileData: state.profileData),
                              bodyProfile(state.profileData),
                            ],
                          )
                        : Container(), // Empty container for non-loading, non-success state
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          profileRowShimmer(),
          bodyProfileShimmer(),
        ],
      ),
    );
  }

  Widget bodyProfile(ProfileModel? profileData) {
    return Column(
      children: [
        const SizedBox(height: 34.0),
        CustomTextField(
          isEnable: false,
          label: Strings.label_no_telp,
          hint: '087****8',
          onChanged: null,
          onlyNumbers: true,
          textValue: profileData?.noTelp ?? '',
        ),
        const SizedBox(height: 24.0),
        CustomTextField(
          isEnable: false,
          label: Strings.label_username,
          hint: 'kikoviano',
          onChanged: null,
          textValue: profileData?.username ?? '',
        ),
        const SizedBox(height: 24.0),
        CustomTextField(
          isEnable: false,
          label: Strings.label_email,
          hint: 'gerardus@gmail.com',
          onChanged: null,
          textValue: profileData?.email ?? '',
        ),
        const SizedBox(height: 24.0),
        CustomDescriptionField(
          isEnable: false,
          label: Strings.label_address,
          hint: 'Jln, Somba No. 5 Salatiga, Jawa Tengah',
          onChanged: null,
          textValue: profileData?.address ?? '',
        ),
        const SizedBox(height: 24.0),
        CustomTextField(
          isEnable: false,
          label: Strings.label_join_date,
          hint: '01 Januari 2020',
          onChanged: null,
          textValue: CustomDateFormat.convertToDateFormatOnlyDate(
              profileData?.joinDate ?? ''),
        ),
        const SizedBox(height: 24.0),
        CustomTextField(
          isEnable: false,
          label: Strings.label_rek_owner_name,
          hint: 'BRI',
          onChanged: null,
          textValue: profileData?.bankOwnerName ?? '',
        ),
        const SizedBox(height: 24.0),
        CustomTextField(
          isEnable: false,
          label: Strings.label_bank_name,
          hint: 'BRI',
          onChanged: null,
          textValue: profileData?.bankName ?? '',
        ),
        const SizedBox(height: 24.0),
        CustomTextField(
          isEnable: false,
          label: Strings.label_rek_num,
          hint: '2138393936753',
          onChanged: null,
          onlyNumbers: true,
          textValue: profileData?.bankAccountNumber ?? '',
        ),
        const SizedBox(height: 32.0)
      ],
    );
  }

  Widget bodyProfileShimmer() {
    return Column(
      children: [
        const SizedBox(height: 34.0),
        _shimmerTextField(),
        const SizedBox(height: 24.0),
        _shimmerTextField(),
        const SizedBox(height: 24.0),
        _shimmerTextField(),
        const SizedBox(height: 24.0),
        _shimmerTextField(), // This could be a bit longer for description
        const SizedBox(height: 24.0),
        _shimmerTextField(),
        const SizedBox(height: 24.0),
        _shimmerTextField(),
        const SizedBox(height: 24.0),
        _shimmerTextField(),
        const SizedBox(height: 32.0)
      ],
    );
  }

  Widget _shimmerTextField() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 20.0,
        color: Colors.white,
      ),
    );
  }

  Widget profileRowShimmer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 100.0, // Approximate size of the profile picture
              height: 100.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.0), // For circle shape
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120.0, // Approximate width of name
              height: 20.0,
              color: Colors.white,
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 50.0, // Approximate width of id
              height: 20.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final ProfileModel? profileData;

  const ProfileRow({Key? key, this.profileData}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final name = profileData?.fullname ?? 'Loading...';
    final id = profileData?.id.toString() ?? 'Loading...';
    final imageUrlNetwork = profileData?.photoProfileUrl;

    final imageUrl =
        'https://placehold.jp/34A853/ffffff/150x150.png?text=${getInitials(name)}';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ProfileAvatar(
            backgroundImage: imageUrl,
            foregroundImage: imageUrlNetwork,
          ),
          const SizedBox(height: 16.0),
          ProfileDetails(
            name: name,
            id: id,
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String backgroundImage;
  final String? foregroundImage;

  const ProfileAvatar(
      {Key? key, required this.backgroundImage, required this.foregroundImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.0, // Set the desired width
      height: 100.0, // Set the desired height
      child: CircleAvatar(
        backgroundImage: NetworkImage(backgroundImage),
        foregroundImage: NetworkImage(foregroundImage ?? ''),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: AppTypography.semiBold16,
        ),
        const SizedBox(height: 5),
        Text(id, style: AppTypography.regular12),
      ],
    );
  }
}
