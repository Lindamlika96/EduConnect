import 'package:educonnect_mobile/core/utils/session_manager.dart';


class LogoutUserUseCase {
  Future<void> execute() async {
    await SessionManager.clearSession();
  }
}
