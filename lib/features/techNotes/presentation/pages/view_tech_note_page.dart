import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:repair_shop/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/add_tech_note_page.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_card.dart';

class ViewTechNotePage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const ViewTechNotePage());
  const ViewTechNotePage({super.key});

  @override
  State<ViewTechNotePage> createState() => _ViewTechNotePageState();
}

class _ViewTechNotePageState extends State<ViewTechNotePage> {
  int noteCount = 0;
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    context.read<TechNoteBloc>().add(TechNotesSyncEvent());
    context.read<TechNoteBloc>().add(TechNotesGetAllUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TechNotes'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view_rounded),
          ),
          NotificationBell(),
          const SizedBox(width: 10),
        ],
      ),
      body: BlocConsumer<TechNoteBloc, TechNoteState>(
        listener: (context, state) {
          if (state.status == TechNoteStatus.failure) {
            showSnackBar(context, state.message ?? "Error");
          }
        },
        builder: (context, state) {
          // If loading and we have NO data, show spinner
          if (state.status == TechNoteStatus.loading && state.notes.isEmpty) {
            return const Loader();
          }

          // If failed and we have NO data, show error
          if (state.status == TechNoteStatus.failure && state.notes.isEmpty) {
            return Center(child: Text(state.message ?? "Error loading notes"));
          }

          // Use the notes directly from the state
          final notes = state.notes;

          // Default widget when no condition matches
          return RefreshIndicator(
            onRefresh: () async {
              final techNoteBloc = context.read<TechNoteBloc>();
              final notificationBloc = context.read<NotificationBloc>();

              // Sync and Fetch TechNotes
              techNoteBloc.add(TechNotesSyncEvent());
              techNoteBloc.add(TechNotesGetAllUsersEvent());

              // 2. REFRESH NOTIFICATIONS
              // This will trigger the NotificationBell to rebuild automatically
              notificationBloc.add(NotificationSyncEvent());

              // Wait for the reload to complete.
              // You might want to listen to state changes or
              // delay here for UX smoothness.
              await Future.delayed(
                const Duration(milliseconds: 500),
              ); // Delay for UX
            },

            child: notes.isEmpty
                ? const Center(child: Text("No Notes Found"))
                : (isGridView ? _buildGridView(notes) : _buildListView(notes)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, AddTechNotePage.route());
        },
        backgroundColor: AppPallete.gradient2,
        child: const Icon(
          Icons.note_add_outlined,
          color: AppPallete.whiteColor,
        ),
      ),
    );
  }

  // Helper for List Layout
  Widget _buildListView(List<TechNoteEntities> notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) =>
          TechNoteCard(note: notes[index], isGridView: isGridView),
    );
  }

  // Helper for Grid Layout
  Widget _buildGridView(List<TechNoteEntities> notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        childAspectRatio: 0.9, // Adjust this based on TechNoteCard height
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) =>
          TechNoteCard(note: notes[index], isGridView: isGridView),
    );
  }
}
