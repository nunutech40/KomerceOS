import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/widgets/card_feed_empty.dart';
import 'package:komtim_partner/features/superapp/features/team/feed/bloc/feed_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/feed/widget/card_feed.dart';

class TeamFeedSection extends StatelessWidget {
  /// Callback dipanggil dengan feedId ketika card ditekan.
  /// Navigasi ditangani oleh caller (HomeTeamCubit), bukan widget ini.
  final void Function(String feedId)? onFeedTap;

  const TeamFeedSection({Key? key, this.onFeedTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state.status == RequestStatus.loading && state.feedList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBase),
            ),
          );
        }

        final Widget feedContent;

        if (state.feedList.isEmpty) {
          feedContent = const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: CardFeedEmpty(
              image: 'assets/images/team/empty_state_feed.svg',
              title: 'Belum ada informasi terbaru',
              body: 'Pantau terus section ini untuk update terkini dari Komtim.',
            ),
          );
        } else {
          final previewFeeds = state.feedList.take(3).toList();
          feedContent = SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: previewFeeds.length,
              itemBuilder: (context, index) {
                final feed = previewFeeds[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: CardFeed(
                    ontap: () => onFeedTap?.call(feed.id.toString()),
                    images: feed.image ?? '',
                    tagTalent: feed.visibility ?? '',
                    title: feed.title ?? '',
                    date: feed.publishedAt ?? '',
                    nametalent: feed.participants,
                  ),
                );
              },
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Informasi Terkini',
                style: AppTypography.bodyLgSemiBold.copyWith(
                  color: AppColors.alwaysBlack,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            feedContent,
            const SizedBox(height: AppSpacing.sm),
          ],
        );
      },
    );
  }
}
