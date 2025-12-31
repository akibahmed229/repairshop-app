import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/auth/domain/repository/auth_repository.dart';

class SyncFcmDeviceToken implements Usecase<String, SyncFcmDeviceTokenParams> {
  final AuthRepository authRepository;
  const SyncFcmDeviceToken({required this.authRepository});

  @override
  Future<Either<Failure, String>> call(SyncFcmDeviceTokenParams params) async {
    return await authRepository.syncFcmDeviceToken(fcmToken: params.fcmToken);
  }
}

class SyncFcmDeviceTokenParams {
  String fcmToken;

  SyncFcmDeviceTokenParams({required this.fcmToken});
}
