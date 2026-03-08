import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/enums/user_enum.dart';
import 'package:fruitesdashboard/core/services/shared_prefs_singelton.dart';


class RoleCubit extends Cubit<UserRole> {
  RoleCubit() : super(UserRole.employee) {
    _loadRole();
  }

  // تحميل الدور المحفوظ من ذاكرة الجهاز
  void _loadRole() {
    String savedRole = Prefs.getString("user_role");
    if (savedRole.isNotEmpty) {
      try {
        emit(UserRole.values.firstWhere((e) => e.name == savedRole));
      } catch (e) {
        emit(UserRole.employee);
      }
    }
  }

  // تغيير الدور وحفظه فوراً
  void setRole(UserRole role) {
    Prefs.setString("user_role", role.name);
    emit(role);
  }

  // دوال مساعدة للتحقق من الصلاحيات في أي مكان بالتطبيق
  bool get isManager => state == UserRole.manager;
  bool get canEdit => state != UserRole.employee;
}