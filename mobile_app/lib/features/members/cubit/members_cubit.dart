import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'members_state.dart';

class MembersCubit extends Cubit<MembersState> {
  static const _uuid = Uuid();

  MembersCubit() : super(const MembersInitial());

  Future<void> loadMembers() async {
    emit(const MembersLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const MembersLoaded([
      KingdomMember(
        id: '1',
        name: 'Head of House',
        email: 'admin@hearth.local',
        role: MemberRole.king,
        isAdmin: true,
      ),
    ]));
  }

  Future<void> inviteMember(String email, MemberRole role) async {
    final current = state;
    if (current is! MembersLoaded) return;
    final updated = List<KingdomMember>.from(current.members)
      ..add(KingdomMember(
        id: _uuid.v4(),
        name: email.split('@').first,
        email: email,
        role: role,
      ));
    emit(MembersLoaded(updated));
  }

  Future<void> updateRole(String memberId, MemberRole newRole) async {
    final current = state;
    if (current is! MembersLoaded) return;
    final updated = current.members.map((m) {
      if (m.id == memberId) {
        return KingdomMember(
            id: m.id, name: m.name, email: m.email, role: newRole, isAdmin: m.isAdmin);
      }
      return m;
    }).toList();
    emit(MembersLoaded(updated));
  }
}
