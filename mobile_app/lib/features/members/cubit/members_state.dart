import 'package:equatable/equatable.dart';

enum MemberRole { king, queen, chef, prince, princess, guest }

extension MemberRoleExt on MemberRole {
  String get label {
    switch (this) {
      case MemberRole.king:    return 'King';
      case MemberRole.queen:   return 'Queen';
      case MemberRole.chef:    return 'Chef';
      case MemberRole.prince:  return 'Prince';
      case MemberRole.princess: return 'Princess';
      case MemberRole.guest:   return 'Guest';
    }
  }
}

class KingdomMember extends Equatable {
  final String id;
  final String name;
  final String email;
  final MemberRole role;
  final bool isAdmin;

  const KingdomMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [id, name, email, role, isAdmin];
}

abstract class MembersState extends Equatable {
  const MembersState();
  @override
  List<Object?> get props => [];
}

class MembersInitial extends MembersState {
  const MembersInitial();
}
class MembersLoading extends MembersState {
  const MembersLoading();
}
class MembersLoaded extends MembersState {
  final List<KingdomMember> members;
  const MembersLoaded(this.members);
  @override
  List<Object?> get props => [members];
}
class MembersFailure extends MembersState {
  final String message;
  const MembersFailure(this.message);
  @override
  List<Object?> get props => [message];
}
