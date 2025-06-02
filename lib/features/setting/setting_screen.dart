import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:osm_navigation/features/auth/auth_viewmodel.dart';
import 'package:osm_navigation/features/auth/screens/login_screen.dart';
import 'package:osm_navigation/Core/providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.logout();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isDarkMode = context.watch<AppState>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF00811F),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (authViewModel.isAuthenticated) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  Icons.account_circle,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  'Account Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(
                  'View and manage your account',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Theme(
                      data: Theme.of(context).copyWith(
                        dialogTheme: DialogTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: AlertDialog(
                        backgroundColor: Theme.of(context).dialogBackgroundColor,
                        titlePadding: const EdgeInsets.all(24),
                        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        title: Text(
                          'Account Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                'Username',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              subtitle: Text(
                                authViewModel.username ?? 'N/A',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.email,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                'Email',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              subtitle: Text(
                                authViewModel.email ?? 'N/A',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            child: const Text('Close'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _logout(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Not Logged In',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Log in to access your account features',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LoginScreen(isDialog: false),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00811F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Login/Register'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Dark Mode',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (bool value) {
                  context.read<AppState>().toggleDarkMode();
                },
                activeColor: const Color(0xFF00811F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
