import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:repair_shop/features/chat/presentation/pages/chat_room_page.dart';

class ChatSearchPage extends StatefulWidget {
  const ChatSearchPage({super.key});

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      context.read<ChatBloc>().add(
        ChatSearchUsers(_searchController.text.trim()),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by email..',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
          ),
          onSubmitted: (_) => _onSearch(),
        ),
        actions: [
          IconButton(onPressed: _onSearch, icon: const Icon(Icons.search)),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.failure) {
            showSnackBar(context, state.errorMessage ?? "Search failed");
          }
        },
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return const Loader();
          }

          if (state.users.isNotEmpty) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppPallete.gradient2,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.email),
                  onTap: () {
                    Navigator.push(
                      context,
                      ChatRoomPage.route(user.id, user.name),
                    );
                  },
                );
              },
            );
          }

          // Initial state or no results
          return Center(
            child: Text(
              state.status == ChatStatus.success && state.users.isEmpty
                  ? "No users found."
                  : "Search for users to start chatting",
              style: const TextStyle(color: AppPallete.greyColor),
            ),
          );
        },
      ),
    );
  }
}
