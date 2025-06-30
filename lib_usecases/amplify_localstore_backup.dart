// import 'package:flutter/material.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'models/ModelProvider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:aws_amplify_app/local_mobile_store.dart';


// class TodoScreen extends StatefulWidget {
//   const TodoScreen({super.key});
//   @override
//   State<TodoScreen> createState() => _TodoScreenState();
// }

// class _TodoScreenState extends State<TodoScreen> {
//   final _localStore = LocalMobileStore<Todo>(modelType: Todo.classType);
//   final _uuid = const Uuid();
//   List<Todo> _todos = [];

//   @override
//   void initState() {
//     super.initState();
//     refreshTodos();
//   }

//   Future<void> refreshTodos() async {
//     try {
//       final storeRows = await _localStore.readAll();
//       setState(() {
//         _todos = storeRows.map((row) => row.item).toList();
//       });
//     } catch (e) {
//       safePrint('Error reading todos from local store: $e');
//     }
//   }

//   Future<void> _addRandomTodo() async {
//     try {
//       final newTodo = Todo(
//         id: _uuid.v4(),
//         content: "Random Todo ${DateTime.now().toIso8601String()}",
//         isDone: false,
//       );

//       final newRow = StoreRow(id: newTodo.id, item: newTodo);
//       await _localStore.create(newRow);

//       safePrint('Successfully created Todo locally: ${newTodo.content}');
//       await refreshTodos();
//     } catch (e) {
//       safePrint('Failed to create todo locally: $e');
//     }
//   }

//   Future<void> _clearAllTodos() async {
//     try {
//       await _localStore.clear();
//       safePrint('Finished clearing todos locally.');
//       await refreshTodos();
//     } catch (e) {
//       safePrint('Clearing todos locally failed: $e');
//     }
//   }

//   Future<void> onTodoChanged(bool checked, Todo todo) async {
//     try {
//       final updatedTodo = todo.copyWith(isDone: checked);
//       final updatedRow = StoreRow(id: updatedTodo.id, item: updatedTodo);
//       await _localStore.update(updatedRow);
//       safePrint('Updating Todo successful locally.');
//       await refreshTodos();
//     } catch (e) {
//       safePrint('Updating Todo locally failed: $e');
//     }
//   }

//   Future<bool> onDismissed(DismissDirection direction, Todo todo) async {
//     if (direction == DismissDirection.endToStart) {
//       try {
//         await _localStore.delete(todo.id);
//         await refreshTodos();
//         return true;
//       } catch (e) {
//         safePrint('Deleting Todo locally failed: $e');
//         return false;
//       }
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