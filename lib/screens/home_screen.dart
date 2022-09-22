import 'package:MyUsedPots/constants.dart';
import 'package:MyUsedPots/screens/just_read_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final poemProvider = StateProvider<String>((ref) {
  return "";
}, name: "poemProvider");

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController poemFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: File a GitHub issue on this - this seems to be required even tho it probably should be inhibited from the theme
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("MyUsedPots"),
        actions: [
          IconButton(
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: "My Used Pots",
                  applicationLegalese:
                      "MUP is a tool that makes memorizing poems easier\n(the name's an anagram of \"study poems\")",
                  useRootNavigator: true,
                );
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => const LicensePage(),
                //     ));
              },
              icon: const Icon(Icons.info_outline))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: poemFieldController,
                textAlignVertical: TextAlignVertical.top,
                expands: true,
                maxLines: null,
                minLines: null,
                style: GoogleFonts.dmMono(
                    color: Theme.of(context).colorScheme.onBackground),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "Enter the poem here",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          poemFieldController.text = defaultPoem;
                        });
                      },
                      child: const Text("Use default")),
                  if (!kReleaseMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              poemFieldController.text = poemDebug;
                            });
                          },
                          icon: const Icon(Icons.bug_report_outlined),
                          label: const Text("Use debug")),
                    )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return FloatingActionButton(
              onPressed: () {
                // update the value first
                ref.read(poemProvider.notifier).state =
                    poemFieldController.text;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const JustReadScreen()));
              },
              child: const Icon(Icons.done_outlined));
        },
      ),
    );
  }
}
