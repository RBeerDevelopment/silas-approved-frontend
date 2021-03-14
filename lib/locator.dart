import 'package:get_it/get_it.dart';
import 'localStorageHandler.dart';

GetIt locator = GetIt.instance;

Future setupLocator() async {
  var localStorageHandler = await LocalStorageHandler.getInstance();
  locator.registerSingleton<LocalStorageHandler>(localStorageHandler);
}