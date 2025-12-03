import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
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
  List<TechNoteEntities> notes = [];
  @override
  void initState() {
    super.initState();
    context.read<TechNoteBloc>().add(TechNotesSyncEvent());
    context.read<TechNoteBloc>().add(TechNotesGetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TechNotes'), centerTitle: true),
      body: BlocConsumer<TechNoteBloc, TechNoteState>(
        listener: (context, state) {
          if (state is TechNoteFailure) {
            showSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is TechNoteLoading) {
            return const Loader();
          }

          if (state is TechNotesGetSuccess) {
            noteCount = state.notes.length;
            notes = state.notes;
          }

          // Default widget when no condition matches
          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<TechNoteBloc>();

              // 1. Trigger Sync
              bloc.add(TechNotesSyncEvent());

              // 2. get the notes
              bloc.add(TechNotesGetEvent());

              // Wait for the reload to complete.
              // You might want to listen to state changes or
              // delay here for UX smoothness.
              await Future.delayed(
                const Duration(milliseconds: 500),
              ); // Delay for UX
            },

            child: Scrollbar(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];

                  return TechNoteCard(note: note);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
