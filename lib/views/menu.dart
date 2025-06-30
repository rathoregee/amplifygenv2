import 'package:flutter/material.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'journal-general.dart';
import 'reports.dart';
import 'more.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Material 3 App')),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Navigation')),             
              ListTile(
                title: const Text('JV'),
                onTap: () => _navigate(context, const JVPage()),
              ),
              ListTile(
                title: const Text('Reports'),
                onTap: () => _navigate(context, const ReportsPage()),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('More'),
              ),
              ListTile(
                title: const Text('More Link 1'),
                onTap: () => _navigate(context, const MoreLinksPage(title: 'More Link 1')),
              ),
              ListTile(
                title: const Text('More Link 2'),
                onTap: () => _navigate(context, const MoreLinksPage(title: 'More Link 2')),
              ),
            ],
          ),
        ),
        body: Center(child: Text('Welcome to the Material 3 App')),
        bottomNavigationBar: SafeArea(          
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _navigate(context, const JVPage()),
                child: const Text('JV'),
              ),
              ElevatedButton(
                onPressed: () => _navigate(context, const ReportsPage()),
                child: const Text('Reports'),
              ),
              ElevatedButton(
                onPressed: () => _navigate(context, const MoreLinksPage(title: 'More')),
                child: const Text('More'),
              ),
              ElevatedButton(
                onPressed: () => _navigate(context, SignOutButton()),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
