import 'package:dargo/core/ioc/ioc_container.dart';

class OmnipresentIoC {
  static late IoCContainer? ioc;

  static void setIoc(IoCContainer context) {
    ioc = context;
  }

  static T? inject<T>({BeanScope? scope, String? qualifier}) {
    try {
      return ioc?.inject<T>(scope: scope, qualifier: qualifier);
    } catch (e) {
      return null;
    }
  }
}
