import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/auth/domain/repository/auth_repository.dart';

class CurrentUser implements Usecase<UserEntities, NoParams> {
  final AuthRepository authRepository;
  const CurrentUser({required this.authRepository});

  @override
  Future<Either<Failure, UserEntities>> call(NoParams params) async {
    return await authRepository.currentUserData();
  }
}
