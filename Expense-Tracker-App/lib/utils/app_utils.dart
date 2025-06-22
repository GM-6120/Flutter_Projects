import 'package:expence_dost/model/user_model.dart';
import 'package:get_storage/get_storage.dart';

class AppUtils {
static const String userDataKey = "userDataKey";
final getStorage = GetStorage();
static UserModel? data;

Future readUserData() async {
  final localData = await getStorage.read(userDataKey);
  if (localData != null) {
    return data = UserModel.fromJson(localData as Map<String, dynamic>);
  } else {
    return null;
  }
}

}
