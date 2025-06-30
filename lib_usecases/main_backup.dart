// import 'package:flutter/material.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_authenticator/amplify_authenticator.dart';
// import 'package:aws_amplify_app/theme/theme.dart';
// import 'package:aws_amplify_app/views/menu.dart';
// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:amplify_api/amplify_api.dart';
// import 'amplify_outputs.dart';
// import 'models/ModelProvider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await configureAmplify();
//     runApp(const StateFullApp());
//     //debug purpopse
//     //runApp(const DebugMode());
//   } on AmplifyException catch (e) {
//     runApp(Text("Error configuring Amplify: ${e.message}"));
//   }
// }

// class StateFullApp extends StatelessWidget {
//   const StateFullApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Authenticator(
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         builder: Authenticator.builder(),        
//         home: const  HomePage(),
//         theme: appTheme
//       ),
//     );
//   }
// }

// Future<void> configureAmplify() async {
//   try {
//     await Amplify.addPlugins([
//       AmplifyAuthCognito(),
//       AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance)),
//     ]);
//     await Amplify.configure(amplifyConfig);
//     safePrint('Successfully configured');
//     var user = await Amplify.Auth.getCurrentUser();
//     safePrint('User object :  $user');

//   } on Exception catch (e) {
//     safePrint('Error configuring Amplify: $e');
//   }
// }


// class DebugMode extends StatelessWidget {
//     const DebugMode({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Authenticator(
//       child: MaterialApp(
//       debugShowCheckedModeBanner: false,
//       builder: Authenticator.builder(),        
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Hello World App'),
//         ),
//         body: const Center(
//           child: Text('Hello World'),
//         ),
//       ),
//     )
//     );
//   }
// }