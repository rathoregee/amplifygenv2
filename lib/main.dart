import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
//import 'package:aws_amplify_app/theme/theme.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:aws_amplify_app/views/menu.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplify_outputs.dart';
import 'models/ModelProvider.dart';
import 'package:amplify_datastore/amplify_datastore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await configureAmplify();
    runApp(const StateFullApp());
    //debug purpopse
    //runApp(const DebugMode());
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

class StateFullApp extends StatelessWidget {
  const StateFullApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: Authenticator.builder(),        
        home: const  HomePage(),
        //theme: appTheme
      ),
    );
  }
}

Future<void> configureAmplify() async {
  try {
  
    final logger = AmplifyLogger('AmplifyApp');
    logger.logLevel = LogLevel.verbose;
    logger.verbose('🔍 Verbose logging initialized.');

    safePrint('Configuring...');
    await Amplify.addPlugins([
      AmplifyAPI(),
      AmplifyAuthCognito(),
      //Important this code wont run without emulator becuase AmplifyDataStore not supported for web (like when you one on chrome browser)
      AmplifyDataStore(modelProvider: ModelProvider.instance),
    ]);    

    await Amplify.configure(amplifyConfig);
    safePrint('Amplify configured with DataStore');   
    var user = await Amplify.Auth.getCurrentUser();
    safePrint('User getCurrentUser :  $user');

    Amplify.Hub.listen(HubChannel.DataStore, (HubEvent hubEvent) {
      final eventName = hubEvent.eventName;
      final payload = hubEvent.payload;

      switch (eventName) {
        case 'modelSynced':
          final modelPayload = payload as ModelSyncedEvent;
          safePrint(
              '🔁 Model synced: ${modelPayload.modelName}, synced items: $modelPayload, full sync: ${modelPayload.isFullSync}');
          break;

        case 'ready':
          safePrint('✅ DataStore is ready and fully synced with cloud.');
          break;

        case 'syncQueriesStarted':
          safePrint('🔄 Sync queries started.');
          break;

        case 'subscriptionsEstablished':
          safePrint('🔌 Subscriptions established.');
          break;

        default:
          safePrint('📡 Hub Event: $eventName');
      }
    });

  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class DebugMode extends StatelessWidget {
    const DebugMode({super.key});
  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: Authenticator.builder(),        
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World App'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    )
    );
  }
}