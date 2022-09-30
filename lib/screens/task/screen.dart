import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_used_pots/screens/task/state.dart';
import 'package:my_used_pots/widgets/utils.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: BrandedAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer(
            builder: (context, ref, child) => LinearProgressIndicator(
              value: (ref.watch(currentLearningStep) /
                  ref.watch(allLearningSteps)),
            ),
          ),
          Expanded(
            child: StandardPadding(
              multiplier: 2,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer(
                      builder: ((context, ref, child) => Text(
                            ref.watch(messageProvider),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                          ))),
                  Expanded(
                    child: StandardPadding(
                      Card(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: StandardPadding(
                          SingleChildScrollView(
                            child: Consumer(
                              builder: (context, ref, child) => SelectableText(
                                ref.watch(contentToRead),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return FloatingActionButton(
            onPressed: () {
              var linesToReadState = ref.read(linesToRead);
              var plength = ref.read(poemLines).length;
              if (ref.read(finished)) {
                Navigator.pop(context);
                return;
              }

              ref
                  .read(currentLearningStep.state)
                  .update((state) => state + linesToReadState);
              ref.read(currentLine.notifier).state += linesToReadState;
              // dev.log("new cLine $currentLineState");

              if (ref.read(currentLine) >= plength) {
                dev.log("need to update toread");
                ref.read(linesToRead.state).state += 1;
                ref.read(currentLine.state).state = 0;
              }
            },
            child: const Icon(Icons.navigate_next_outlined),
          );
        },
      ),
    );
  }
}
