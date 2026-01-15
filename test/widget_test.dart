// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hggzk/app.dart';
import 'package:hggzk/core/bloc/app_bloc.dart';
import 'package:hggzk/injection_container.dart' as di;

void main() {
  late Directory hiveTempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    hiveTempDir = await Directory.systemTemp.createTemp('hggzk_hive_test_');
    Hive.init(hiveTempDir.path);

    await di.init();
    AppBloc.initialize();
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveTempDir.existsSync()) {
      await hiveTempDir.delete(recursive: true);
    }
  });

  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HggzkApp());
    await tester.pump();

    // Verify that app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
