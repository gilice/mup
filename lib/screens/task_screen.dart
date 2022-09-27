import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_used_pots/screens/home_screen.dart';

final allLearningSteps = Provider.autoDispose<int>((ref) {
  var linesLength = ref.read(poemLines).length;
  var ret = 0;
  for (var i = 1; i < linesLength; i++) {
    dev.log("$i*${(linesLength / i).ceil()}");
    ret += i * (linesLength / i).ceil();
  }
  return ret;
}, name: "allLearningSteps");

final currentLearningStep = StateProvider.autoDispose<int>((ref) {
  return 0;
}, name: "currentLearningStep");

final currentLine = StateProvider.autoDispose<int>((ref) {
  return 0;
}, name: "currentLine");

final finished = Provider.autoDispose<bool>((ref) {
  var ltr = ref.watch(linesToRead);
  var lineCount = ref.watch(poemLines).length;
  return ltr >= lineCount;
}, name: "finished");

final linesToRead = StateProvider.autoDispose<int>((ref) {
  return 1;
}, name: "linesToRead");

final messageProvider = Provider.autoDispose<String>((ref) {
  var finishedState = ref.watch(finished);
  var lines = ref.watch(linesToRead);
  if (!finishedState) {
    var multiple = lines > 1;
    return "Read the next ${multiple ? ("$lines lines") : "line"}, then close your eyes and recite ${multiple ? "them" : "it"} out loud.";
  } else {
    return "Congrats! You have finished!";
  }
}, name: "message");

final poemLines = StateProvider<List<String>>((ref) {
  var allElements = ref.watch(poemProvider).split("\n");

  allElements.removeWhere((element) {
    var tr = element.trim();
    return tr.isEmpty || tr == '\n';
  });
  return allElements;
}, name: "poemLines");

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
      appBar: AppBar(
        title: const Text("MyUsedPots"),
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                      child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Card(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Consumer(
                          builder: (context, ref, child) {
                            var ltR = ref.watch(linesToRead);
                            var cL = ref.watch(currentLine);
                            var allLines = ref.watch(poemLines);

                            var toDisplay = kReleaseMode
                                ? ""
                                : "${ref.watch(currentLearningStep)}/${ref.watch(allLearningSteps)}";

                            for (var i = cL;
                                i < min(cL + ltR, allLines.length);
                                i++) {
                              toDisplay += "\n${allLines[i]}";
                            }

                            return SingleChildScrollView(
                              child: SelectableText(
                                toDisplay,
                                style: GoogleFonts.dmMono(),
                                // style: GoogleFonts().d,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          // STUB: This is only for debugging
          ref.listen(
            linesToRead,
            (previous, next) {
              dev.log("linesToRead: $previous, $next");
            },
          );
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

              //setState(() {});
            },
            child: const Icon(Icons.navigate_next_outlined),
          );
        },
      ),
    );
  }
}
