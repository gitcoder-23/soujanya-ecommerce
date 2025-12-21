import 'package:martfury/src/service/base_service.dart';

class UserService extends BaseService {
  Future<void> requestAccountDeletion({String? reason}) async {
    final Map<String, Object> payload = {};

    if (reason != null && reason.trim().isNotEmpty) {
      payload['reason'] = reason.trim();
    }

    await post('/api/v1/ecommerce/delete-account', payload);
  }

  Future<void> verifyAccountDeletion({required String verificationCode}) async {
    await post('/api/v1/ecommerce/delete-account/verify', {
      'verification_code': verificationCode,
    });
  }
}
