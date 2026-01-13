import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
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
    context.read<ChatBloc>().add(ChatConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Team Chat"), centerTitle: true),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatFailure) {
            showSnackBar(context, state.toString());
          }
        },
        buildWhen: (previous, current) {
          // Ignore 'ChatRoomLoaded' state so this page doesn't go blank
          return current is ChatConversationsLoaded || current is ChatLoading;
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Loader();
          }

          if (state is ChatConversationsLoaded) {
            final conversations = state.conversations;

            if (conversations.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(ChatConversations());
              },
              child: ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsetsGeometry.only(left: 16, right: 26),
                  child: Divider(height: 1),
                ),
                itemBuilder: (context, index) {
                  final chat = conversations[index];
                  return Padding(
                    padding: EdgeInsetsGeometry.only(top: 8, bottom: 8),
                    child: _buildChatTile(
                      context,
                      name: chat.otherUserName,
                      lastMessage: chat.lastMessage,
                      // Passing the DateTime to a helper for formatting
                      time: formatDateByMMMYYYY(chat.time),
                      userId: chat.otherUserId,
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox(); // Default state
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
      onTap: () async {
        Navigator.push(context, ChatRoomPage.route(userId, name));

        if (context.mounted) {
          // This fetches new data but DOES NOT trigger the Loading screen
          context.read<ChatBloc>().add(ChatConversations(isSilent: true));
        }
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppPallete.gradient3.withValues(alpha: 0.2),
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
