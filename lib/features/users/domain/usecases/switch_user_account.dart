import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class SwitchUserAccount
    implements Usecase<UserEntities, SwitchUserAccountParams> {
  final UserRepository userRepository;

  const SwitchUserAccount({required this.userRepository});

  @override
  Future<Either<Failure, UserEntities>> call(
    SwitchUserAccountParams params,
  ) async {
    return await userRepository.switchAccount(id: params.id);
  }
}

class SwitchUserAccountParams {
  String id;

  SwitchUserAccountParams({required this.id});
}
