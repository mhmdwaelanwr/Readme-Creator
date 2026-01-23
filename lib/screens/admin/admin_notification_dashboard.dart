import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminNotificationDashboard extends StatefulWidget {
  const AdminNotificationDashboard({super.key});

  @override
  State<AdminNotificationDashboard> createState() => _AdminNotificationDashboardState();
}

class _AdminNotificationDashboardState extends State<AdminNotificationDashboard> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  // Replace with your FCM Server Key or use a Cloud Function (Recommended)
  // For security, it's better to trigger this via a Firestore collection or Cloud Function
  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      // Store in Firestore to trigger a Cloud Function (Best Practice)
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'title': _titleController.text,
        'body': _bodyController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // A cloud function can pick this up
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification request sent to Firestore!')),
        );
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Notification Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Notification Body'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _isSending
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _sendNotification,
                    icon: const Icon(Icons.send),
                    label: const Text('Send to All Users'),
                  ),
            const Divider(height: 40),
            const Text('Notification Logs', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('admin_notifications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      return ListTile(
                        title: Text(data['title']),
                        subtitle: Text(data['body']),
                        trailing: Text(data['status'] ?? 'sent'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
