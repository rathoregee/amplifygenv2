import 'dart:async';
import 'dart:io'; // Required for file operations

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'models/ModelProvider.dart';

// Assuming this screen's code is in 'lib/amplify.dart' as per your error log.
// You can rename the class if you wish.
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // State variables
  List<Todo> _todos = [];
  int _cloudCount = 0;
  bool _isPremiumAccount = false;
  bool _isSyncEnabled = false;

  // Keep track of the Hub subscription to cancel it when the widget is disposed
  StreamSubscription<HubEvent>? _hubSub;

  @override
  void initState() {
    super.initState();
    _configureLogging();
    _initialize();
  }

  /// Bundles async initialization steps.
  Future<void> _initialize() async {
    // Set up listeners first to catch all events
    _observeDataStoreEvents();
    _observeTodos();

    // Request permissions (good practice for some file operations)
    await _requestPermissions();

    // Check user status to determine if sync should be enabled by default
    await _checkUserStatus();

    // Fetch initial data from the local store
    await _fetchTodos();

    // If the user is premium, start the DataStore sync engine
    if (_isPremiumAccount) {
      await _toggleSync(true);
    }
  }

  @override
  void dispose() {
    // Cancel the Hub subscription to prevent memory leaks
    _hubSub?.cancel();
    super.dispose();
  }

  void _configureLogging() {
    // Optional: Enables verbose logging for DataStore, useful for debugging
    AmplifyLogger.category(Category.dataStore).logLevel = LogLevel.verbose;
  }

  Future<void> _requestPermissions() async {
    // Request storage permission.
    await Permission.storage.request();
  }

  /// Checks Cognito user attributes to see if the account is premium.
  Future<void> _checkUserStatus() async {
    try {
      final attrs = await Amplify.Auth.fetchUserAttributes();
      final premium = attrs.firstWhere(
        (a) => a.userAttributeKey.key == 'custom:isPremiumAccount',
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.custom('isPremiumAccount'),
          value: 'false',
        ),
      );
      if (mounted) {
        setState(() {
          _isPremiumAccount = premium.value.toLowerCase() == 'true';
          _isSyncEnabled = _isPremiumAccount;
        });
      }
    } catch (e) {
      safePrint('Error fetching user status: $e');
    }
  }

  /// Listens for local changes to the Todo model and refreshes the UI.
  void _observeTodos() {
    Amplify.DataStore.observe(Todo.classType).listen((_) {
      safePrint('Received a local DataStore event. Refreshing list.');
      _fetchTodos();
    });
  }

  /// Listens for DataStore hub events like sync status.
  void _observeDataStoreEvents() {
    _fetchTodos();
  }

  /// Fetches all Todo items from the local DataStore repository.
  Future<void> _fetchTodos() async {
    try {
      final list = await Amplify.DataStore.query(Todo.classType);
      list.sort((a, b) => (a.createdAt ?? TemporalDateTime(DateTime(0)))
          .compareTo(b.createdAt ?? TemporalDateTime(DateTime(0))));

      if (mounted) {
        setState(() {
          _todos = list;
          if (_isSyncEnabled) {
            _cloudCount = list.length;
          }
        });
      }
    } catch (e) {
      safePrint('Fetch failed: $e');
    }
  }

  /// Toggles the DataStore sync engine on or off.
  Future<void> _toggleSync(bool shouldSync) async {
    if (!mounted) return;
    try {
      if (shouldSync) {
        safePrint('🔁 Starting DataStore sync...');
        await Amplify.DataStore.start();
      } else {
        safePrint('🛑 Stopping DataStore sync...');
        await Amplify.DataStore.stop();
        if (mounted) setState(() => _cloudCount = 0);
      }
      if (mounted) setState(() => _isSyncEnabled = shouldSync);
    } catch (e) {
      safePrint('Error toggling sync: $e');
    }
  }

  Future<void> _addRandomTodo() async {
    final newTodo = Todo(
      content: 'Item [${DateTime.now().toIso8601String()}]',
      isDone: false,
    );
    try {
      await Amplify.DataStore.save(newTodo);
      safePrint('Added a new Todo');
    } catch (e) {
      safePrint('Add failed: $e');
    }
  }

  Future<void> _clearAllTodos() async {
    try {
      // Loop through the list to delete items one by one.
      for (final todo in _todos) {
        await Amplify.DataStore.delete(todo);
      }
      safePrint('Cleared all Todos.');
    } catch (e) {
      safePrint('Clear all failed: $e');
    }
  }

  Future<void> _updateTodoStatus(Todo t, bool done) async {
    try {
      await Amplify.DataStore.save(t.copyWith(isDone: done));
      safePrint('Updated Todo: ${t.id}');
    } catch (e) {
      safePrint('Update failed: $e');
    }
  }

  Future<bool> _deleteTodo(Todo t) async {
    try {
      await Amplify.DataStore.delete(t);
      safePrint('Deleted Todo: ${t.id}');
      return true;
    } catch (e) {
      safePrint('Delete failed: $e');
      return false;
    }
  }

  Widget buildTodoItem(BuildContext c, int i) {
    final t = _todos[i];
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _deleteTodo(t),
      child: CheckboxListTile.adaptive(
        value: t.isDone ?? false,
        title: Text(t.content ?? 'No Content'),
        onChanged: (v) => v != null ? _updateTodoStatus(t, v) : null,
      ),
    );
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.ListView(
          children: _todos.map((t) {
            // Handle the nullable bool with a default value.
            final status = (t.isDone ?? false) ? 'Completed' : 'Pending';
            return pw.Text('${t.content} [$status]');
          }).toList(),
        ),
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/todo_list.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Saved PDF to: $filePath'),
      ));

      await OpenFilex.open(filePath);
    } catch (e) {
      safePrint('Error exporting PDF: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error exporting PDF: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _downloadToExcel() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel export is not yet implemented.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPDF,
            tooltip: 'Export PDF',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _downloadToExcel,
            tooltip: 'Export Excel',
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Text(_isPremiumAccount ? 'Premium' : 'Standard'),
              Switch(
                value: _isSyncEnabled,
                onChanged: _isPremiumAccount ? (v) => _toggleSync(v) : null,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Local: ${_todos.length}'),
                    Text('Cloud: $_cloudCount'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'clear-fab',
            onPressed: _clearAllTodos,
            tooltip: 'Clear All',
            child: const Icon(Icons.delete_forever),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'add-random-fab',
            onPressed: _addRandomTodo,
            label: const Text('Add Random'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text(
              'The list is empty.\nAdd some items to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ))
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: buildTodoItem,
            ),
    );
  }
}