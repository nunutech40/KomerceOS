import 'package:equatable/equatable.dart';
import '../domain/entities/setting_profile.dart';

abstract class SettingProfileEvent extends Equatable {
  const SettingProfileEvent();
  @override
  List<Object?> get props => [];
}

class SettingProfileFetchRequested extends SettingProfileEvent {
  const SettingProfileFetchRequested();
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
