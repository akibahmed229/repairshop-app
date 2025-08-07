import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_card.dart';

class ViewTechNotePage extends StatefulWidget {
  const ViewTechNotePage({super.key});

  @override
  State<ViewTechNotePage> createState() => _ViewTechNotePageState();
}

class _ViewTechNotePageState extends State<ViewTechNotePage> {
  @override
  void initState() {
    super.initState();
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
            return Scrollbar(
              child: ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];

                  return TechNoteCard(note: note);
                },
              ),
            );
          }

          // Default widget when no condition matches
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
