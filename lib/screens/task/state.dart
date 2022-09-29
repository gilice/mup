import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final contentToRead = StateProvider.autoDispose((ref) {
  var ltR = ref.watch(linesToRead);
  var cL = ref.watch(currentLine);
  var allLines = ref.watch(poemLines);

  var toDisplay = kReleaseMode
      ? ""
      : "${ref.watch(currentLearningStep)}/${ref.watch(allLearningSteps)}";

  for (var i = cL; i < min(cL + ltR, allLines.length); i++) {
    toDisplay += "\n${allLines[i]}";
  }

  return toDisplay;
});

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
  var i = 0;
  while (i < allElements.length) {
    var tr = allElements[i].trim();
    if (tr.isEmpty || tr == '\n') {
      allElements[i - 1] += " 🛑";
      allElements.removeAt(i);
    }

    i += 1;
  }

  return allElements;
}, name: "poemLines");
// Modified: 2022-09-29T18:38:15.656Z
