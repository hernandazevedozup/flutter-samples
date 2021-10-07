// @dart=2.9
// the code above forces this file to be built without nullsafe feature
// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:beagle/beagle.dart';
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_design_system.dart';


Map<String, ComponentBuilder> myCustomComponents = {
  'custom:loading': (element, _, __) {
    return Center(
      key: element.getKey(),
      child: const Text('My custom loading.'),
    );
  }
};

Map<String, ActionHandler> myCustomActions = {
  'custom:log': ({action,view,element,context}) {
    debugPrint(action?.getAttributeValue('message')?.toString());
  }
};

/// The entrypoint for the flutter module.
void main() {
  // This call ensures the Flutter binding has been set up before creating the
  // MethodChannel-based model.
  WidgetsFlutterBinding.ensureInitialized();
  final localhost = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  final model = CounterModel();
  BeagleSdk.init(
    baseUrl: 'http://$localhost:8080',
    environment:
    kDebugMode ? BeagleEnvironment.debug : BeagleEnvironment.production,
    components: {...defaultComponents, ...myCustomComponents},
    actions: {...defaultActions},
    logger: DefaultLogger(),
    designSystem: AppDesignSystem(),
  );

  runApp(ChangeNotifierProvider.value(
      value: model,
      child: const MaterialApp(home: BeagleSampleApp(showExit: true))
  ));

}


/// A simple model that uses a [MethodChannel] as the source of truth for the
/// state of a counter.
///
/// Rather than storing app state data within the Flutter module itself (where
/// the native portions of the app can't access it), this module passes messages
/// back to the containing app whenever it needs to increment or retrieve the
/// value of the counter.
class CounterModel extends ChangeNotifier {
  CounterModel() {
    _channel.setMethodCallHandler(_handleMessage);
    _channel.invokeMethod<void>('requestCounter');
  }

  final _channel = const MethodChannel('dev.flutter.example/counter');

  int _count = 0;

  int get count => _count;

  void increment() {
    _channel.invokeMethod<void>('incrementCounter');
  }

  Future<dynamic> _handleMessage(MethodCall call) async {
    if (call.method == 'reportCounter') {
      _count = call.arguments as int;
      notifyListeners();
    }
  }
}

/// The "app" displayed by this module.
///
/// It offers two routes, one suitable for displaying as a full screen and
/// another designed to be part of a larger UI.class MyApp extends StatelessWidget {
class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Module Title',
      routes: {
        '/': (context) => const FullScreenView(),
        '/mini': (context) => const Contents(),
      },
    );
  }
}

/// Wraps [Contents] in a Material [Scaffold] so it looks correct when displayed
/// full-screen.
class FullScreenView extends StatelessWidget {
  const FullScreenView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full-screen Flutter'),
      ),
      body: const BeagleSampleApp(showExit: true),
    );
  }
}

/// The actual content displayed by the module.
///
/// This widget displays info about the state of a counter and how much room (in
/// logical pixels) it's been given. It also offers buttons to increment the
/// counter and (optionally) close the Flutter view.
class Contents extends StatelessWidget {
  final bool showExit;

  const Contents({this.showExit = false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaInfo = MediaQuery.of(context);

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          const Positioned.fill(
            child: Opacity(
              opacity: .25,
              child: FittedBox(
                fit: BoxFit.cover,
                child: FlutterLogo(),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Window is ${mediaInfo.size.width.toStringAsFixed(1)} x '
                      '${mediaInfo.size.height.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(height: 16),
                Consumer<CounterModel>(
                  builder: (context, model, child) {
                    return Text(
                      'Taps: ${model.count}',
                      style: Theme.of(context).textTheme.headline5,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<CounterModel>(
                  builder: (context, model, child) {
                    return ElevatedButton(
                      onPressed: () => model.increment(),
                      child: const Text('Tap me!'),
                    );
                  },
                ),
                if (showExit) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(animated: true),
                    child: const Text('Exit this screen'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class BeagleSampleApp extends StatelessWidget {
  const BeagleSampleApp({this.showExit = false,Key key}) : super(key: key);
  final bool showExit;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beagle Sample',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        indicatorColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<CounterModel>(
                builder: (context, model, child) {
                  return ElevatedButton(
                    onPressed: () => _openBeagleScreen(context, model),
                    child: const Text('Start beagle flow'),
                  );
                },
              ),
              if (showExit) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => SystemNavigator.pop(animated: true),
                  child: const Text('Exit this screen'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _openBeagleScreen(BuildContext context, CounterModel model) {
    model.increment();
    BeagleSdk.openScreen(route: RemoteView('/components'), context: context);
  }
}
