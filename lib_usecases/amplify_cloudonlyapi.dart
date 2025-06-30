// import 'package:flutter/material.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_api/amplify_api.dart';
// import 'models/ModelProvider.dart';
// import 'package:uuid/uuid.dart';

// class TodoScreen extends StatefulWidget {
//   const TodoScreen({super.key});
//   @override
//   State<TodoScreen> createState() => _TodoScreenState();
// }

// class _TodoScreenState extends State<TodoScreen> {
//   final _uuid = const Uuid();
//   List<Todo> _todos = [];

//   @override
//   void initState() {
//     super.initState();
//     refreshTodos();
//   }

//   Future<void> refreshTodos() async {
//     try {
//       final request = ModelQueries.list(Todo.classType);
//       final response = await Amplify.API.query(request: request).response;
//       if (response.hasErrors) {
//         safePrint('Query errors: ${response.errors}');
//         return;
//       }
//       setState(() {
//         _todos = response.data!.items.whereType<Todo>().toList();
//       });
//     } on ApiException catch (e) {
//       safePrint('Query failed: $e');
//     }
//   }

//   Future<void> _addRandomTodo() async {
//     final newTodo = Todo(
//       id: _uuid.v4(),
//       content: "Random Todo ${DateTime.now().toIso8601String()}",
//       isDone: false,
//     );

//     try {
//       final request = ModelMutations.create(newTodo);
//       final response = await Amplify.API.mutate(request: request).response;
//       final createdTodo = response.data;
//       if (response.hasErrors || createdTodo == null) {
//         safePrint('Errors creating Todo: ${response.errors}');
//         return;
//       }
//       safePrint('Successfully created Todo: ${createdTodo.content}');
//     } on ApiException catch (e) {
//       safePrint('Mutation failed: $e');
//     }

//     await refreshTodos();
//   }

//   Future<void> _clearAllTodos() async {
//     try {
//       for (final todo in _todos) {
//         final request = ModelMutations.delete(todo);
//         final response = await Amplify.API.mutate(request: request).response;
//         if (response.hasErrors) {
//           safePrint('Could not delete todo ${todo.id}: ${response.errors}');
//         }
//       }
//       safePrint('Finished clearing todos.');
//     } on ApiException catch (e) {
//       safePrint('Clearing todos failed: $e');
//     }
//     await refreshTodos();
//   }

//   Future<void> onTodoChanged(bool checked, Todo todo) async {
//     final req = ModelMutations.update(todo.copyWith(isDone: checked));
//     final res = await Amplify.API.mutate(request: req).response;
//     if (res.hasErrors) {
//       safePrint('Updating Todo failed: ${res.errors}');
//     } else {
//       safePrint('Updating Todo successful.');
//       await refreshTodos();
//     }
//   }

//   Future<bool> onDismissed(DismissDirection direction, Todo todo) async {
//     if (direction == DismissDirection.endToStart) {
//       final req = ModelMutations.delete(todo);
//       final res = await Amplify.API.mutate(request: req).response;
//       if (res.hasErrors) {
//         safePrint('Deleting Todo failed: ${res.errors}');
//         return false;
//       }
//       await refreshTodos();
//       return true;
//     }
//     return false;
//   }

//   Widget buildTodoItem(BuildContext context, int index) {
//     final todo = _todos[index];
//     return Dismissible(
//       key: UniqueKey(),
//       confirmDismiss: (direction) => onDismissed(direction, todo),
//       child: CheckboxListTile.adaptive(
//         value: todo.isDone,
//         title: Text(todo.content ?? ''),
//         onChanged: (checked) {
//           if (checked != null) {
//             onTodoChanged(checked, todo);
//           }
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.amberAccent,
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: _clearAllTodos,
//             tooltip: 'Clear Todo list',
//             child: const Icon(Icons.delete_forever),
//           ),
//           const SizedBox(height: 16),
//           FloatingActionButton.extended(
//             label: const Text('Add Random Todo'),
//             onPressed: _addRandomTodo,
//           ),
//         ],
//       ),
//       body: _todos.isEmpty
//           ? const Center(
//               child: Text(
//                 "The list is empty.\nAdd some items by clicking the floating action button.",
//                 textAlign: TextAlign.center,
//               ),
//             )
//           : ListView.builder(
//               itemCount: _todos.length,
//               itemBuilder: buildTodoItem,
//             ),
//     );
//   }
// }
