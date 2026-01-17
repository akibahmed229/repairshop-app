import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/chat/presentation/bloc/chat_bloc.dart';

class ChatRoomPage extends StatefulWidget {
  static route(String otherUserId, String otherUserName) => MaterialPageRoute(
    builder: (context) =>
        ChatRoomPage(otherUserId: otherUserId, otherUserName: otherUserName),
  );

  final String otherUserId;
  final String otherUserName;

  const ChatRoomPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch history when entering the room
    context.read<ChatBloc>().add(ChatGetHistory(widget.otherUserId));
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(
        ChatSendMessage(receiverId: widget.otherUserId, content: text),
      );
      _messageController.clear();
      // Optional: Scroll to bottom after sending
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName), centerTitle: false),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Chat List
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state.status == ChatStatus.failure) {
                    showSnackBar(
                      context,
                      state.errorMessage ?? "Error sending message",
                    );
                  }
                },
                builder: (context, state) {
                  // Show loader only on first-time fetch (when list is empty)
                  if (state.status == ChatStatus.loading &&
                      state.messages.isEmpty) {
                    return const Loader();
                  }

                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        "Say Hello! 👋",
                        style: TextStyle(color: AppPallete.greyColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Keep newest at the bottom
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final bool isMine = message.isMine;

                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMine
                                ? AppPallete.gradient2
                                : AppPallete.borderColor.withAlpha(50),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMine ? 16 : 0),
                              bottomRight: Radius.circular(isMine ? 0 : 16),
                            ),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isMine
                                  ? Colors.white
                                  : Colors.white, // Adjust based on your theme
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // 2. Input Field
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPallete.backgroundColor,
        border: Border(
          top: BorderSide(color: AppPallete.borderColor.withAlpha(30)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: AppPallete.borderColor.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: AppPallete.gradient2,
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
