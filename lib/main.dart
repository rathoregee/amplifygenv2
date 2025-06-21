import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_api/amplify_api.dart';
import 'amplify_outputs.dart';
import 'models/ModelProvider.dart';
import 'models/Todo.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _configureAmplify();
    runApp(const MyApp());
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(options: APIPluginOptions(modelProvider: ModelProvider.instance)),
    ]);
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: const SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                SignOutButton(),
                Expanded(child: TodoScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _uuid = const Uuid();
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  Future<void> _refreshTodos() async {
    try {
      final request = ModelQueries.list(Todo.classType);
      final response = await Amplify.API.query(request: request).response;
      if (response.hasErrors) {
        safePrint('Query errors: ${response.errors}');
        return;
      }
      setState(() {
        _todos = response.data!.items.whereType<Todo>().toList();
      });
    } on ApiException catch (e) {
      safePrint('Query failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add Random Todo'),
        onPressed: () async {
          final newTodo = Todo(
            id: _uuid.v4(),
            content: "Random Todo ${DateTime.now().toIso8601String()}",
            isDone: false,
          );
          final req = ModelMutations.create(newTodo);
          final res = await Amplify.API.mutate(request: req).response;
          if (res.hasErrors) {
            safePrint('Creating Todo failed.');
          } else {
            safePrint('Creating Todo successful.');
          }
          await _refreshTodos();
        },
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text(
                "The list is empty.\nAdd some items by clicking the floating action button.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (ctx, index) {
                final todo = _todos[index];
                return Dismissible(
                  key: UniqueKey(),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      final req = ModelMutations.delete(todo);
                      final res = await Amplify.API.mutate(request: req).response;
                      if (res.hasErrors) {
                        safePrint('Deleting Todo failed: ${res.errors}');
                        return false;
                      }
                      await _refreshTodos();
                      return true;
                    }
                    return false;
                  },
                  child: CheckboxListTile.adaptive(
                    value: todo.isDone,
                    title: Text(todo.content!),
                    onChanged: (checked) async {
                      final req = ModelMutations.update(todo.copyWith(isDone: checked!));
                      final res = await Amplify.API.mutate(request: req).response;
                      if (res.hasErrors) {
                        safePrint('Updating Todo failed: ${res.errors}');
                      } else {
                        safePrint('Updating Todo successful.');
                        await _refreshTodos();
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
