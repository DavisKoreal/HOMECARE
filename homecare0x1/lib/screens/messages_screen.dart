import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/message.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Mock messages
  final List<Message> _messages = [
    Message(
      id: '1',
      senderId: 'caregiver1',
      receiverId: 'family1',
      content: 'Client is doing well today.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    Message(
      id: '2',
      senderId: 'family1',
      receiverId: 'caregiver1',
      content: 'Thank you for the update!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
  ];

  void _sendMessage(String senderId) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _messages.add(
          Message(
            id: (_messages.length + 1).toString(),
            senderId: senderId,
            receiverId: senderId == 'caregiver1' ? 'family1' : 'caregiver1',
            content: _messageController.text,
            timestamp: DateTime.now(),
            isRead: false,
          ),
        );
        _messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.user?.id ?? 'unknown';
    final isFamilyMember = currentUserId.startsWith('family');

    return ModernScreenLayout(
      title: 'Messages',
      showBackButton:
          !isFamilyMember, // Hide default back button for family members
      leading: isFamilyMember
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, Routes.familyPortal),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Communicate with caregivers or family',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _messages.isEmpty
                        ? const Center(child: Text('No messages found'))
                        : ListView.builder(
                            reverse: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message =
                                  _messages[_messages.length - 1 - index];
                              final isSentByCurrentUser =
                                  message.senderId == currentUserId;
                              return Align(
                                alignment: isSentByCurrentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSentByCurrentUser
                                        ? AppTheme.primaryBlue
                                        : AppTheme.neutral100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.content,
                                        style: TextStyle(
                                          color: isSentByCurrentUser
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('h:mm a')
                                            .format(message.timestamp),
                                        style: TextStyle(
                                          color: isSentByCurrentUser
                                              ? Colors.white70
                                              : AppTheme.neutral600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a message' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ModernButton(
                    text: 'Send',
                    icon: Icons.send,
                    width: 100.0, // Explicit width to avoid layout issues
                    onPressed: () => _sendMessage(currentUserId),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
