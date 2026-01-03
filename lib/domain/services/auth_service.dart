import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/core/enums/role_enum.dart';
import 'package:dak_louk/domain/models/models.dart';

class AuthService {
  Future<Role?> login(LogInDTO dto) async {
    return await AppSession.instance.login(email: dto.email, password: dto.password);
  }

  Future<void> signUpUser(SignUpDTO dto) async {
    await AppSession.instance.signUpUser(
      username: dto.username,
      email: dto.email,
      password: dto.password,
      profileImageUrl: dto.profileImageUrl,
      bio: dto.bio,
      phone: dto.phone,
      address: dto.address,
    );
  }

  Future<void> logout() async {
    await AppSession.instance.logout();
  }
}
