import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main_layout.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // User is logged in, now check role
          return FutureBuilder<UserModel?>(
            future: authService.currentUserData,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                String role = userSnapshot.data!.role;

                if (role == 'admin') {
                  return const AdminDashboard();
                } else if (role == 'seller') {
                  return const SellerDashboard();
                } else {
                  return const MainLayout(); // Default for buyer
                }
              }

              // Fallback if user data not found in Firestore
              return const LoginScreen();
            },
          );
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}

// Admin Dashboard with User Management
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Manage Users'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: authService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text("${user.email} • Role: ${user.role}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (newRole) async {
                    await authService.updateUserRole(user.uid, newRole);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Role ${user.name} update to $newRole')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'buyer', child: Text('As Buyer')),
                    const PopupMenuItem(value: 'seller', child: Text('As Seller')),
                    const PopupMenuItem(value: 'admin', child: Text('As Admin')),
                  ],
                  child: const Icon(Icons.edit_note, color: Colors.blue),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Placeholder for Seller Dashboard
class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => AuthService().signOut()),
      ]),
      body: const Center(child: Text('Welcome, Seller!')),
    );
  }
}
