import 'package:equatable/equatable.dart';
import '../../domain/entities/aplikasiku_entity.dart';

class AplikasiItemResponse extends Equatable {
  final bool? active;
  final bool? verified;
  final bool? learnMore;
  final String? deepLink;
  final String? status;
  final String? logoUrl;

  const AplikasiItemResponse({
    this.active,
    this.verified,
    this.learnMore,
    this.deepLink,
    this.status,
    this.logoUrl,
  });

  factory AplikasiItemResponse.fromJson(Map<String, dynamic> json) {
    return AplikasiItemResponse(
      active: json['active'],
      verified: json['verified'],
      learnMore: json['learn_more'],
      deepLink: json['deep_link'],
      status: json['status'],
      logoUrl: json['logo_url'],
    );
  }

  AplikasiItemEntity toEntity(String key) {
    return AplikasiItemEntity(
      key: key,
      active: active ?? false,
      verified: verified ?? false,
      learnMore: learnMore ?? false,
      deepLink: deepLink ?? '',
      status: status ?? '',
      logoUrl: logoUrl ?? '',
    );
  }

  @override
  List<Object?> get props => [
        active,
        verified,
        learnMore,
        deepLink,
        status,
        logoUrl,
      ];
}

class AplikasikuResponse extends Equatable {
  final AplikasiItemResponse? isKomship;
  final AplikasiItemResponse? isKompack;
  final AplikasiItemResponse? isKomtim;
  final AplikasiItemResponse? isKomchat;
  final AplikasiItemResponse? isKomcard;
  final AplikasiItemResponse? isKomform;
  final AplikasiItemResponse? isKomplace;
  final AplikasiItemResponse? isKomclass;
  final AplikasiItemResponse? isPumkm;
  final AplikasiItemResponse? isKomads;
  final AplikasiItemResponse? isKomed;

  const AplikasikuResponse({
    this.isKomship,
    this.isKompack,
    this.isKomtim,
    this.isKomchat,
    this.isKomcard,
    this.isKomform,
    this.isKomplace,
    this.isKomclass,
    this.isPumkm,
    this.isKomads,
    this.isKomed,
  });

  factory AplikasikuResponse.fromJson(Map<String, dynamic> json) {
    return AplikasikuResponse(
      isKomship: json['is_komship'] != null ? AplikasiItemResponse.fromJson(json['is_komship']) : null,
      isKompack: json['is_kompack'] != null ? AplikasiItemResponse.fromJson(json['is_kompack']) : null,
      isKomtim: json['is_komtim'] != null ? AplikasiItemResponse.fromJson(json['is_komtim']) : null,
      isKomchat: json['is_komchat'] != null ? AplikasiItemResponse.fromJson(json['is_komchat']) : null,
      isKomcard: json['is_komcard'] != null ? AplikasiItemResponse.fromJson(json['is_komcard']) : null,
      isKomform: json['is_komform'] != null ? AplikasiItemResponse.fromJson(json['is_komform']) : null,
      isKomplace: json['is_komplace'] != null ? AplikasiItemResponse.fromJson(json['is_komplace']) : null,
      isKomclass: json['is_komclass'] != null ? AplikasiItemResponse.fromJson(json['is_komclass']) : null,
      isPumkm: json['is_pumkm'] != null ? AplikasiItemResponse.fromJson(json['is_pumkm']) : null,
      isKomads: json['is_komads'] != null ? AplikasiItemResponse.fromJson(json['is_komads']) : null,
      isKomed: json['is_komed'] != null ? AplikasiItemResponse.fromJson(json['is_komed']) : null,
    );
  }

  List<AplikasiItemEntity> toEntityList() {
    final list = <AplikasiItemEntity>[];
    if (isKomship != null) list.add(isKomship!.toEntity('komship'));
    if (isKompack != null) list.add(isKompack!.toEntity('kompack'));
    if (isKomtim != null) list.add(isKomtim!.toEntity('komtim'));
    if (isKomchat != null) list.add(isKomchat!.toEntity('komchat'));
    if (isKomcard != null) list.add(isKomcard!.toEntity('komcards'));
    if (isKomform != null) list.add(isKomform!.toEntity('komform'));
    if (isKomplace != null) list.add(isKomplace!.toEntity('komplace'));
    if (isKomclass != null) list.add(isKomclass!.toEntity('komclass'));
    if (isPumkm != null) list.add(isPumkm!.toEntity('pumkm'));
    if (isKomads != null) list.add(isKomads!.toEntity('komads'));
    if (isKomed != null) list.add(isKomed!.toEntity('komed'));
    return list;
  }

  @override
  List<Object?> get props => [
        isKomship,
        isKompack,
        isKomtim,
        isKomchat,
        isKomcard,
        isKomform,
        isKomplace,
        isKomclass,
        isPumkm,
        isKomads,
        isKomed,
      ];
}
