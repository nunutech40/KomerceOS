import 'package:equatable/equatable.dart';
import '../domain/entities/setting_profile.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';

abstract class SettingProfileEvent extends Equatable {
  const SettingProfileEvent();
  @override
  List<Object?> get props => [];
}

class SettingProfileFetchRequested extends SettingProfileEvent {
  const SettingProfileFetchRequested();
}

class SettingProfileGlobalLoaded extends SettingProfileEvent {
  final SuperappProfileModel profile;
  const SettingProfileGlobalLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SettingProfileChanged extends SettingProfileEvent {
  final SettingProfile draft;
  const SettingProfileChanged(this.draft);
  @override
  List<Object?> get props => [draft];
}

class SettingProfileSaveRequested extends SettingProfileEvent {
  const SettingProfileSaveRequested();
}

class SettingAccountProfileUpdateRequested extends SettingProfileEvent {
  const SettingAccountProfileUpdateRequested();
}

class SettingBusinessProfileUpdateRequested extends SettingProfileEvent {
  const SettingBusinessProfileUpdateRequested();
}

class SettingBusinessSectorsRequested extends SettingProfileEvent {
  const SettingBusinessSectorsRequested();
}

class SettingBusinessLocationsRequested extends SettingProfileEvent {
  final String keyword;
  const SettingBusinessLocationsRequested(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

class SettingBusinessLocationsDebounced extends SettingProfileEvent {
  final String keyword;
  const SettingBusinessLocationsDebounced(this.keyword);
  @override
  List<Object?> get props => [keyword];
}
