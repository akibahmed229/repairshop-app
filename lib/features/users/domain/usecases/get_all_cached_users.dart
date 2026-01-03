import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class GetAllCachedUsers implements Usecase<List<UserEntities>, NoParams> {
  final UserRepository userRepository;

  const GetAllCachedUsers({required this.userRepository});

  @override
  Future<Either<Failure, List<UserEntities>>> call(NoParams params) async {
    return await userRepository.getAllCachedUsers();
  }
}
