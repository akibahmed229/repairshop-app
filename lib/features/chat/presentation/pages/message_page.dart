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
  // 1. Local Cache: Keeps the list on screen while reloading in background
  List<dynamic> _currentConversations = [];

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatConnectSocket());
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
          // FIX: Allow 'ChatFailure' so the page can rebuild and remove the loader
          return current is ChatConversationsLoaded ||
              current is ChatLoading ||
              current is ChatFailure;
        },
        builder: (context, state) {
          // 2. Update Cache if we have new data
          if (state is ChatConversationsLoaded) {
            _currentConversations = state.conversations;
          }

          // 3. Loading Logic: Only show Loader if we have NO data to show
          if (state is ChatLoading && _currentConversations.isEmpty) {
            return const Loader();
          }

          // 4. Failure Logic: If offline & empty, show Retry button
          if (state is ChatFailure && _currentConversations.isEmpty) {
            return _buildErrorState(state.toString());
          }

          // 5. Empty Logic: If loaded but list is empty
          if (_currentConversations.isEmpty) {
            return _buildEmptyState();
          }

          // 6. Success Logic: Show the list (cached or fresh)
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ChatBloc>().add(ChatConversations());
            },
            child: ListView.separated(
              itemCount: _currentConversations.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(left: 16, right: 26),
                child: Divider(height: 1),
              ),
              itemBuilder: (context, index) {
                final chat = _currentConversations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildChatTile(
                    context,
                    name: chat.otherUserName,
                    lastMessage: chat.lastMessage,
                    time: formatDateByMMMYYYY(chat.time),
                    userId: chat.otherUserId,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat_search_tab',
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Trigger a full reload
              context.read<ChatBloc>().add(ChatConversations());
            },
            child: const Text("Retry"),
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
        // 7. Navigation Wait Logic
        await Navigator.push(context, ChatRoomPage.route(userId, name));

        if (context.mounted) {
          // Silent refresh: Updates the cached list in background without spinner
          context.read<ChatBloc>().add(ChatConversations(isSilent: true));
        }
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppPallete.gradient3.withValues(alpha: 0.2),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
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
