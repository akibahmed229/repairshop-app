import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:repair_shop/features/chat/presentation/pages/chat_room_page.dart';
import 'package:repair_shop/features/chat/presentation/pages/chat_search_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  void initState() {
    super.initState();
    // 1. Connect Socket
    context.read<ChatBloc>().add(ChatConnectSocket());
    // 2. Fetch Conversations (You'll need to add this event to your Bloc)
    // context.read<ChatBloc>().add(ChatGetConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        centerTitle: false, // WhatsApp style is usually left-aligned
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Loader();
          }

          // Mocking a list of conversations for now.
          // Replace this logic once your 'ChatConversationsLoaded' state is ready.
          final hasMessages = false;

          if (!hasMessages) {
            return _buildEmptyState();
          }

          return ListView.separated(
            itemCount: 10, // Example count
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              return _buildChatTile(
                context,
                name: "John Doe",
                lastMessage: "Is the repair finished?",
                time: "10:30 AM",
                userId: "user_123",
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat_search_fab',
        backgroundColor: AppPallete.gradient2,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatSearchPage()),
          );
        },
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: AppPallete.greyColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            "No messages yet",
            style: TextStyle(fontSize: 18, color: AppPallete.greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required String name,
    required String lastMessage,
    required String time,
    required String userId,
  }) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatRoomPage(otherUserId: userId, otherUserName: name),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppPallete.gradient3.withOpacity(0.2),
        child: Text(
          name[0],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppPallete.greyColor),
      ),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
