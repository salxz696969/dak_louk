import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/ui/widgets/common/my_app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.instance.init();
  runApp(const MyApp());
}
