import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Setting feature names retained for existing callers.
class ProfileFormCard extends DsFormCard {
  const ProfileFormCard({super.key, required super.children});
}

class ProfileFormRow extends DsFormRow {
  const ProfileFormRow({
    super.key,
    required super.label,
    required super.child,
    super.requiredField,
  });
}
